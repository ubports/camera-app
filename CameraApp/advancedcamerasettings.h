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

#ifndef ADVANCEDCAMERASETTINGS_H
#define ADVANCEDCAMERASETTINGS_H

#include <QObject>
#include <QCamera>
#include <QVideoDeviceSelectorControl>

class AdvancedCameraSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY (QObject* camera READ camera WRITE setCamera NOTIFY cameraChanged)
    Q_PROPERTY (int activeCameraIndex READ activeCameraIndex WRITE setActiveCameraIndex
                NOTIFY activeCameraIndexChanged)

public:
    explicit AdvancedCameraSettings(QObject *parent = 0);
    QObject* camera() const;
    int activeCameraIndex() const;
    void setCamera(QObject* camera);
    void setActiveCameraIndex(int index);

Q_SIGNALS:
    void cameraChanged();
    void activeCameraIndexChanged();

private:
    QVideoDeviceSelectorControl* selectorFromCamera(QObject *camera) const;

    QObject* m_camera;
    QVideoDeviceSelectorControl* m_deviceSelector;
    int m_activeCameraIndex;
};

#endif // ADVANCEDCAMERASETTINGS_H
