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
#include <QtMultimedia/QCameraExposureControl>
#include <QGuiApplication>
#include <QScreen>

#include <cmath>

// Definition of this enum value is duplicated in qtubuntu-camera
static const QCameraExposure::ExposureMode ExposureHdr = static_cast<QCameraExposure::ExposureMode>(QCameraExposure::ExposureModeVendor + 1);

AdvancedCameraSettings::AdvancedCameraSettings(QObject *parent) :
    QObject(parent),
    m_cameraObject(0),
    m_camera(0),
    m_deviceSelector(0),
    m_viewFinderControl(0),
    m_cameraFlashControl(0),
    m_cameraExposureControl(0),
    m_imageEncoderControl(0),
    m_videoEncoderControl(0),
    m_cameraInfoControl(0),
    m_hdrEnabled(false)
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

    return control;
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

QCameraExposureControl* AdvancedCameraSettings::exposureControlFromCamera(QCamera *camera) const
{
    QMediaControl *control = mediaControlFromCamera(camera, QCameraExposureControl_iid);
    QCameraExposureControl *exposureControl = qobject_cast<QCameraExposureControl*>(control);

    if (exposureControl == 0) {
        qWarning() << "No exposure control support";
    }

    return exposureControl;
}

QImageEncoderControl* AdvancedCameraSettings::imageEncoderControlFromCamera(QCamera *camera) const
{
    QMediaControl *control = mediaControlFromCamera(camera, QImageEncoderControl_iid);
    QImageEncoderControl *imageEncoderControl = qobject_cast<QImageEncoderControl*>(control);

    if (imageEncoderControl == 0) {
        qWarning() << "No image encoder control support";
    }

    return imageEncoderControl;
}

QVideoEncoderSettingsControl* AdvancedCameraSettings::videoEncoderControlFromCamera(QCamera *camera) const
{
    QMediaControl *control = mediaControlFromCamera(camera, QVideoEncoderSettingsControl_iid);
    QVideoEncoderSettingsControl *videoEncoderControl = qobject_cast<QVideoEncoderSettingsControl*>(control);

    if (videoEncoderControl == 0) {
        qWarning() << "No video encoder settings control support";
    }

    return videoEncoderControl;
}

QCameraInfoControl* AdvancedCameraSettings::cameraInfoControlFromCamera(QCamera *camera) const
{
    QMediaControl *control = mediaControlFromCamera(camera, QCameraInfoControl_iid);
    QCameraInfoControl *infoControl = qobject_cast<QCameraInfoControl*>(control);

    if (infoControl == 0) {
        qWarning() << "No info control support";
    }

    return infoControl;
}

QObject* AdvancedCameraSettings::camera() const
{
    return m_cameraObject;
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
            connect(m_deviceSelector, SIGNAL(selectedDeviceChanged(int)),
                    this, SLOT(onSelectedDeviceChanged(int)));
        }

        Q_EMIT cameraChanged();
    }
}

void AdvancedCameraSettings::onSelectedDeviceChanged(int index)
{
    Q_UNUSED(index);

    m_videoSupportedResolutions.clear();

    Q_EMIT resolutionChanged();
    Q_EMIT maximumResolutionChanged();
    Q_EMIT fittingResolutionChanged();
    Q_EMIT hasFlashChanged();
    Q_EMIT videoSupportedResolutionsChanged();
}

void AdvancedCameraSettings::readCapabilities()
{
    m_viewFinderControl = viewfinderFromCamera(m_camera);
    m_cameraControl = camcontrolFromCamera(m_camera);
    if (m_cameraControl) {
        QObject::connect(m_cameraControl,
                         SIGNAL(captureModeChanged(QCamera::CaptureModes)),
                         this, SIGNAL(resolutionChanged()));
        QObject::connect(m_cameraControl,
                         SIGNAL(captureModeChanged(QCamera::CaptureModes)),
                         this, SIGNAL(maximumResolutionChanged()));
        QObject::connect(m_cameraControl,
                         SIGNAL(captureModeChanged(QCamera::CaptureModes)),
                         this, SIGNAL(fittingResolutionChanged()));
    }

    m_cameraFlashControl = flashControlFromCamera(m_camera);
    m_cameraExposureControl = exposureControlFromCamera(m_camera);

    if (m_cameraExposureControl) {
        QVariant exposureMode = m_hdrEnabled ? QVariant::fromValue(ExposureHdr)
                                             : QVariant::fromValue(QCameraExposure::ExposureAuto);
        m_cameraExposureControl->setValue(QCameraExposureControl::ExposureMode, exposureMode);
        QObject::connect(m_cameraExposureControl,
                         SIGNAL(actualValueChanged(int)),
                         this, SLOT(onExposureValueChanged(int)));
    }

    m_imageEncoderControl = imageEncoderControlFromCamera(m_camera);
    m_videoEncoderControl = videoEncoderControlFromCamera(m_camera);
    m_cameraInfoControl = cameraInfoControlFromCamera(m_camera);
    m_videoSupportedResolutions.clear();

    Q_EMIT resolutionChanged();
    Q_EMIT maximumResolutionChanged();
    Q_EMIT fittingResolutionChanged();
    Q_EMIT hasFlashChanged();
    Q_EMIT hasHdrChanged();
    Q_EMIT hdrEnabledChanged();
    Q_EMIT encodingQualityChanged();
    Q_EMIT videoSupportedResolutionsChanged();
}

void AdvancedCameraSettings::onCameraStateChanged()
{
    if (m_camera->state() == QCamera::LoadedState || m_camera->state() == QCamera::ActiveState) {
        readCapabilities();
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

QSize AdvancedCameraSettings::imageCaptureResolution() const
{
    if (m_imageEncoderControl != 0) {
        return m_imageEncoderControl->imageSettings().resolution();
    }

    return QSize();
}

QSize AdvancedCameraSettings::videoRecorderResolution() const
{
    if (m_videoEncoderControl != 0) {
        return m_videoEncoderControl->videoSettings().resolution();
    }

    return QSize();
}

QSize AdvancedCameraSettings::maximumResolution() const
{
    if (m_imageEncoderControl) {
        QList<QSize> sizes = m_imageEncoderControl->supportedResolutions(
                                       m_imageEncoderControl->imageSettings());

        QSize maximumSize;
        long maximumPixels = 0;

        QList<QSize>::const_iterator it = sizes.begin();
        while (it != sizes.end()) {
            const long pixels = ((long)((*it).width())) * ((long)((*it).height()));
            if (pixels > maximumPixels) {
                maximumSize = *it;
                maximumPixels = pixels;
            }
            ++it;
        }

        return maximumSize;
    }

    return QSize();
}

float AdvancedCameraSettings::getScreenAspectRatio() const
{
    float screenAspectRatio;
    QScreen *screen = QGuiApplication::primaryScreen();
    Q_ASSERT(screen);
    const int kScreenWidth = screen->geometry().width();
    const int kScreenHeight = screen->geometry().height();
    Q_ASSERT(kScreenWidth > 0 && kScreenHeight > 0);

    screenAspectRatio = (kScreenWidth > kScreenHeight) ?
        ((float)kScreenWidth / (float)kScreenHeight) : ((float)kScreenHeight / (float)kScreenWidth);

    return screenAspectRatio;
}

QSize AdvancedCameraSettings::fittingResolution() const
{
    QList<float> prioritizedAspectRatios;
    prioritizedAspectRatios.append(getScreenAspectRatio());
    const float backAspectRatios[4] = { 16.0f/9.0f, 3.0f/2.0f, 4.0f/3.0f, 5.0f/4.0f };
    for (int i=0; i<4; ++i) {
        if (!prioritizedAspectRatios.contains(backAspectRatios[i])) {
            prioritizedAspectRatios.append(backAspectRatios[i]);
        }
    }

    if (m_imageEncoderControl) {
        QList<QSize> sizes = m_imageEncoderControl->supportedResolutions(
                                       m_imageEncoderControl->imageSettings());

        QSize optimalSize;
        long optimalPixels = 0;

        if (!sizes.empty()) {
            float aspectRatio;

            // Loop over all reported camera resolutions until we find the highest
            // one that matches the current prioritized aspect ratio. If it doesn't
            // find one on the current aspect ration, it selects the next ratio and
            // tries again.
            QList<float>::const_iterator ratioIt = prioritizedAspectRatios.begin();
            while (ratioIt != prioritizedAspectRatios.end()) {
                // Don't update the aspect ratio when using this function for finding
                // the optimal thumbnail size as it will affect the preview window size
                aspectRatio = (*ratioIt);

                QList<QSize>::const_iterator it = sizes.begin();
                while (it != sizes.end()) {
                    const float ratio = (float)(*it).width() / (float)(*it).height();
                    const long pixels = ((long)((*it).width())) * ((long)((*it).height()));
                    const float EPSILON = 0.02;
                    if (fabs(ratio - aspectRatio) < EPSILON && pixels > optimalPixels) {
                        optimalSize = *it;
                        optimalPixels = pixels;
                    }
                    ++it;
                }
                if (optimalPixels > 0) break;
                ++ratioIt;
            }
        }

        return optimalSize;
    }

    return QSize();
}

QStringList AdvancedCameraSettings::videoSupportedResolutions()
{
    if (m_videoEncoderControl) {
        if (m_videoSupportedResolutions.isEmpty()) {
            QString currentDeviceName = m_deviceSelector->deviceName(m_deviceSelector->selectedDevice());
            QCamera::Position cameraPosition = m_cameraInfoControl->cameraPosition(currentDeviceName);
            QList<QSize> sizes = m_videoEncoderControl->supportedResolutions(
                                                m_videoEncoderControl->videoSettings());
            Q_FOREACH(QSize size, sizes) {
                // Workaround for bug https://bugs.launchpad.net/ubuntu/+source/libhybris/+bug/1408650
                // When using the front camera on krillin, using resolution 640x480 does
                // not work properly and results in stretched videos. Remove it from
                // the list of supported resolutions.
                if (cameraPosition == QCamera::FrontFace &&
                    size.width() == 640 && size.height() == 480) {
                    continue;
                }
                m_videoSupportedResolutions.append(QString("%1x%2").arg(size.width()).arg(size.height()));
            }
        }
        return m_videoSupportedResolutions;
    } else {
        return QStringList();
    }
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

bool AdvancedCameraSettings::hasHdr() const
{
    if (m_cameraExposureControl) {
        bool continuous;
        if (m_cameraExposureControl->isParameterSupported(QCameraExposureControl::ExposureMode)) {
            QVariantList range = m_cameraExposureControl->supportedParameterRange(QCameraExposureControl::ExposureMode, &continuous);
            return range.contains(QVariant::fromValue(ExposureHdr));
        }
    } else {
        return false;
    }
}

bool AdvancedCameraSettings::hdrEnabled() const
{
    return m_hdrEnabled;
}

void AdvancedCameraSettings::setHdrEnabled(bool enabled)
{
    if (enabled != m_hdrEnabled) {
        m_hdrEnabled = enabled;
        if (m_cameraExposureControl) {
            QVariant exposureMode = enabled ? QVariant::fromValue(ExposureHdr)
                                            : QVariant::fromValue(QCameraExposure::ExposureAuto);
            m_cameraExposureControl->setValue(QCameraExposureControl::ExposureMode, exposureMode);
        } else {
            Q_EMIT hdrEnabledChanged();
        }
    }
}

int AdvancedCameraSettings::encodingQuality() const
{
    if (m_imageEncoderControl) {
        return m_imageEncoderControl->imageSettings().quality();
    } else {
        return QMultimedia::NormalQuality;
    }
}

void AdvancedCameraSettings::setEncodingQuality(int quality)
{
    if (m_imageEncoderControl) {
        QImageEncoderSettings settings;
        settings.setQuality((QMultimedia::EncodingQuality)quality);
        m_imageEncoderControl->setImageSettings(settings);
    }
}

void AdvancedCameraSettings::onExposureValueChanged(int parameter)
{
    if (parameter == QCameraExposureControl::ExposureMode) {
        Q_EMIT hdrEnabledChanged();
    }
}
