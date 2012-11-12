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

#include <QCamera>
#include <QDebug>
#include <QMediaService>
#include <QVideoDeviceSelectorControl>

AdvancedCameraSettings::AdvancedCameraSettings(QObject *parent) :
    QObject(parent),
    m_activeCameraIndex(0),
    m_camera(0),
    m_deviceSelector(0)
{
}

QVideoDeviceSelectorControl* AdvancedCameraSettings::selectorFromCamera(QObject *cameraObject) const
{
    QVariant cameraVariant = cameraObject->property("mediaObject");
    if (!cameraVariant.isValid()) {
        qWarning() << "No valid mediaObject";
        return 0;
    }

    QCamera *camera = qvariant_cast<QCamera*>(cameraVariant);
    if (!camera) {
        qWarning() << "No valid camera passed";
        return 0;
    }

    QMediaService *service = camera->service();
    if (!service) {
        qWarning() << "Camera has no Mediaservice";
        return 0;
    }

    QMediaControl *control = service->requestControl(QVideoDeviceSelectorControl_iid);
    if (!control) {
        qWarning() << "No device select support";
        return 0;
    }

    QVideoDeviceSelectorControl *selector = qobject_cast<QVideoDeviceSelectorControl*>(control);
    if (!selector) {
        qWarning() << "No video device select support";
        return 0;
    }

    return selector;
}

QObject* AdvancedCameraSettings::camera() const
{
    return m_camera;
}

int AdvancedCameraSettings::activeCameraIndex() const
{
    return m_activeCameraIndex;
}

void AdvancedCameraSettings::setCamera(QObject *camera)
{
    if (camera != m_camera) {
        QVideoDeviceSelectorControl* selector = selectorFromCamera(camera);
        if (selector) {
            m_deviceSelector = selector;
            m_camera = camera;
            Q_EMIT cameraChanged();
            m_deviceSelector->setSelectedDevice(m_activeCameraIndex);
        }
    }
}

void AdvancedCameraSettings::setActiveCameraIndex(int index)
{
    if (index != m_activeCameraIndex) {
        m_activeCameraIndex = index;
        Q_EMIT activeCameraIndexChanged();
        if (m_deviceSelector) {
            m_deviceSelector->setSelectedDevice(m_activeCameraIndex);
        }
    }
}
