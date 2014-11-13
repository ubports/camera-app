/*
 * Copyright (C) 2012 Canonical, Ltd.
 *
 * Authors:
 *  Ugo Riboni <ugo.riboni@canonical.com>
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

#ifndef CAMERAAPPLICATION_H
#define CAMERAAPPLICATION_H

#include <QtQuick/QQuickView>
#include <QGuiApplication>

class QDate;

class CameraApplication : public QGuiApplication
{
    Q_OBJECT
    Q_PROPERTY(bool desktopMode READ isDesktopMode CONSTANT)
    Q_PROPERTY(QString picturesLocation READ picturesLocation CONSTANT)
    Q_PROPERTY(QString videosLocation READ videosLocation CONSTANT)
    Q_PROPERTY(QString temporaryLocation READ temporaryLocation CONSTANT)
    Q_PROPERTY(bool removableStoragePresent READ removableStoragePresent NOTIFY removableStoragePresentChanged)
    Q_PROPERTY(QString removableStorageLocation READ removableStorageLocation CONSTANT)
    Q_PROPERTY(QString removableStoragePicturesLocation READ removableStoragePicturesLocation CONSTANT)
    Q_PROPERTY(QString removableStorageVideosLocation READ removableStorageVideosLocation CONSTANT)

public:
    CameraApplication(int &argc, char **argv);
    virtual ~CameraApplication();
    bool setup();
    bool isDesktopMode() const;
    QString picturesLocation() const;
    QString videosLocation() const;
    QString temporaryLocation() const;
    bool removableStoragePresent() const;
    QString removableStorageLocation() const;
    QString removableStoragePicturesLocation() const;
    QString removableStorageVideosLocation() const;

Q_SIGNALS:
    void removableStoragePresentChanged();

private:
    QScopedPointer<QQuickView> m_view;
};

#endif // CAMERAAPPLICATION_H
