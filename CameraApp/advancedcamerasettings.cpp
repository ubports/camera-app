/*
 * Copyright (C) 2012 Canonical, Ltd.
 *
 * Authors:
 *  Guenter Schwann <guenter.schwann@canonical.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "advancedcamerasettings.h"

#include <QDebug>
#include <QtMultimedia/QCamera>
#include <QtMultimedia/QCameraControl>
#include <QtMultimedia/QMediaService>
#include <QtMultimedia/QVideoDeviceSelectorControl>
#include <QtMultimedia/QCameraFlashControl>

AdvancedCameraSettings::AdvancedCameraSettings(QObject *parent) :
    QObject(parent),
    m_activeCameraIndex(0),
    m_cameraObject(0),
    m_camera(0),
    m_deviceSelector(0),
    m_viewFinderControl(0)
{
}

QCamera* AdvancedCameraSettings::cameraFromCameraObject(QObject* cameraObject) const
{
    QVariant cameraVariant = cameraObject->property("mediaObject");
    if (!cameraVariant.isValid()) {
        qWarning() << "No valid mediaObject";
        return 0;
    }

    QCamera *camera = qvariant_cast<QCamera*>(cameraVariant);
    if (camera == 0) {
        qWarning() << "No valid camera passed";
        return 0;
    }

    return camera;
}

QMediaControl* AdvancedCameraSettings::mediaControlFromCamera(QCamera *camera, const char* iid) const
{
    if (camera == 0) {
        return 0;
    }

    QMediaService *service = camera->service();
    if (service == 0) {
        qWarning() << "Camera has no Mediaservice";
        return 0;
    }

    QMediaControl *control = service->requestControl(iid);
    if (control == 0) {
        qWarning() << "No media control support for" << iid;
        return 0;
    }

}

QVideoDeviceSelectorControl* AdvancedCameraSettings::selectorFromCamera(QCamera *camera) const
{
    QMediaControl *control = mediaControlFromCamera(camera, QVideoDeviceSelectorControl_iid);
    if (control == 0) {
        return 0;
    }

    QVideoDeviceSelectorControl *selector = qobject_cast<QVideoDeviceSelectorControl*>(control);
    if (selector == 0) {
        qWarning() << "No video device selector support";
        return 0;
    }

    return selector;
}

QCameraViewfinderSettingsControl* AdvancedCameraSettings::viewfinderFromCamera(QCamera *camera) const
{
    QMediaControl *control = mediaControlFromCamera(camera, QCameraViewfinderSettingsControl_iid);
    if (control == 0) {
        return 0;
    }

    QCameraViewfinderSettingsControl *selector = qobject_cast<QCameraViewfinderSettingsControl*>(control);
    if (selector == 0) {
        qWarning() << "No viewfinder settings support";
        return 0;
    }

    return selector;
}

QCameraControl *AdvancedCameraSettings::camcontrolFromCamera(QCamera *camera) const
{
    QMediaControl *control = mediaControlFromCamera(camera, QCameraControl_iid);
    if (control == 0) {
        return 0;
    }

    QCameraControl *camControl = qobject_cast<QCameraControl*>(control);
    if (camControl == 0) {
        qWarning() << "No camera control support";
        return 0;
    }

    return camControl;
}

QCameraFlashControl *AdvancedCameraSettings::flashControlFromCamera(QCamera *camera) const
{
    QMediaControl *control = mediaControlFromCamera(camera, QCameraFlashControl_iid);
    QCameraFlashControl *flashControl = qobject_cast<QCameraFlashControl*>(control);

    if (flashControl == 0) {
        qWarning() << "No flash control support";
    }

    return flashControl;
}

QObject* AdvancedCameraSettings::camera() const
{
    return m_cameraObject;
}

int AdvancedCameraSettings::activeCameraIndex() const
{
    return m_activeCameraIndex;
}

void AdvancedCameraSettings::setCamera(QObject *cameraObject)
{
    if (cameraObject != m_cameraObject) {
        m_cameraObject = cameraObject;

        if (m_camera != 0) {
            this->disconnect(m_camera, SIGNAL(stateChanged(QCamera::State)));
        }
        QCamera* camera = cameraFromCameraObject(cameraObject);
        m_camera = camera;
        if (m_camera != 0) {
            this->connect(m_camera, SIGNAL(stateChanged(QCamera::State)),
                          SLOT(onCameraStateChanged()));
            onCameraStateChanged();

            QVideoDeviceSelectorControl* selector = selectorFromCamera(m_camera);
            m_deviceSelector = selector;
            if (selector) {
                m_deviceSelector->setSelectedDevice(m_activeCameraIndex);
            }
        }

        Q_EMIT cameraChanged();
    }
}

void AdvancedCameraSettings::readCapabilities()
{
    m_viewFinderControl = viewfinderFromCamera(m_camera);
    m_cameraControl = camcontrolFromCamera(m_camera);
    if (m_cameraControl) {
        QObject::connect(m_cameraControl,
                         SIGNAL(captureModeChanged(QCamera::CaptureModes)),
                         this, SIGNAL(resolutionChanged()));
    }

    m_cameraFlashControl = flashControlFromCamera(m_camera);

    Q_EMIT resolutionChanged();
    Q_EMIT hasFlashChanged();
}

void AdvancedCameraSettings::onCameraStateChanged()
{
    if (m_camera->state() == QCamera::LoadedState || m_camera->state() == QCamera::ActiveState) {
        readCapabilities();
    }
}

void AdvancedCameraSettings::setActiveCameraIndex(int index)
{
    if (index != m_activeCameraIndex) {
        m_activeCameraIndex = index;
        if (m_deviceSelector) {
            m_deviceSelector->setSelectedDevice(m_activeCameraIndex);
        }
        Q_EMIT activeCameraIndexChanged();
        Q_EMIT resolutionChanged();
        Q_EMIT hasFlashChanged();
    }
}

QSize AdvancedCameraSettings::resolution() const
{
    if (m_viewFinderControl != 0) {
        QVariant result = m_viewFinderControl->viewfinderParameter(QCameraViewfinderSettingsControl::Resolution);
        if (result.isValid()) {
            return result.toSize();
        }
    }

    return QSize();
}

bool AdvancedCameraSettings::hasFlash() const
{
    if (m_cameraFlashControl) {
        return m_cameraFlashControl->isFlashModeSupported(QCameraExposure::FlashAuto)
            && m_cameraFlashControl->isFlashModeSupported(QCameraExposure::FlashOff)
            && m_cameraFlashControl->isFlashModeSupported(QCameraExposure::FlashOn);
    } else {
        return false;
    }
}
