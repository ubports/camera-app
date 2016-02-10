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

#include "cameraapplication.h"

#include <QtCore/QDir>
#include <QtCore/QUrl>
#include <QtCore/QDebug>
#include <QtCore/QStringList>
#include <QtCore/QLibrary>
#include <QtCore/QStandardPaths>
#include <QtCore/QDir>
#include <QDate>
#include <QQmlContext>
#include <QQmlEngine>
#include <QScreen>
#include <QStorageInfo>
#include <QtGui/QGuiApplication>

#include "config.h"

static void printUsage(const QStringList& arguments)
{
    qDebug() << "usage:"
             << arguments.at(0).toUtf8().constData()
             << "[-testability]";
}

CameraApplication::CameraApplication(int &argc, char **argv)
    : QGuiApplication(argc, argv)
{

    // The testability driver is only loaded by QApplication but not by QGuiApplication.
    // However, QApplication depends on QWidget which would add some unneeded overhead => Let's load the testability driver on our own.
    if (arguments().contains(QLatin1String("-testability")) ||
        qgetenv("QT_LOAD_TESTABILITY") == "1") {
        QLibrary testLib(QLatin1String("qttestability"));
        if (testLib.load()) {
            typedef void (*TasInitialize)(void);
            TasInitialize initFunction = (TasInitialize)testLib.resolve("qt_testability_init");
            if (initFunction) {
                initFunction();
            } else {
                qCritical("Library qttestability resolve failed!");
            }
        } else {
            qCritical("Library qttestability load failed!");
        }
    }
}

CameraApplication::~CameraApplication()
{
}

bool CameraApplication::isDesktopMode() const
{
  // Assume that platformName (QtUbuntu) with ubuntu
  // in name means it's running on device
  // TODO: replace this check with SDK call for formfactor
  QString platform = QGuiApplication::platformName();
  return !((platform == "ubuntu") || (platform == "ubuntumirclient"));
}


bool CameraApplication::setup()
{
    QGuiApplication::primaryScreen()->setOrientationUpdateMask(Qt::PortraitOrientation |
                Qt::LandscapeOrientation |
                Qt::InvertedPortraitOrientation |
                Qt::InvertedLandscapeOrientation);

    m_engine.reset(new QQmlApplicationEngine());
    m_engine->rootContext()->setContextProperty("application", this);
    m_engine->setBaseUrl(QUrl::fromLocalFile(cameraAppDirectory()));
    m_engine->addImportPath(cameraAppImportDirectory());
    qDebug() << "Import path added" << cameraAppImportDirectory();
    qDebug() << "Camera app directory" << cameraAppDirectory();
    m_engine->load(QUrl::fromLocalFile(sourceQml()));

    return true;
}

QString CameraApplication::picturesLocation() const
{
    QStringList locations = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation);
    if (locations.isEmpty()) {
        return QString();
    }
    QString location = locations.at(0) + "/" + QCoreApplication::applicationName();
    QDir dir;
    // Transition from old directory 'camera' to new one; see bug #1363112
    // https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1363112
    dir.rename(locations.at(0) + "/" + "camera", location);
    dir.mkpath(location);
    return location;
}

QString CameraApplication::videosLocation() const
{
    QStringList locations = QStandardPaths::standardLocations(QStandardPaths::MoviesLocation);
    if (locations.isEmpty()) {
        return QString();
    }
    QString location = locations.at(0) + "/" + QCoreApplication::applicationName();
    QDir dir;
    // Transition from old directory 'camera' to new one; see bug #1363112
    // https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1363112
    dir.rename(locations.at(0) + "/" + "camera", location);
    dir.mkpath(location);
    return location;
}

QString CameraApplication::temporaryLocation() const
{
    QStringList locations = QStandardPaths::standardLocations(QStandardPaths::TempLocation);
    if (locations.isEmpty()) {
        return QString();
    }
    QString location = locations.at(0);
    QDir dir;
    dir.mkpath(location);
    return location;
}

bool CameraApplication::removableStoragePresent() const
{
    return !removableStorageLocation().isEmpty();
}

QString CameraApplication::removableStorageLocation() const
{
    QString mediaRoot("/media/" + qgetenv("USER"));
    Q_FOREACH(QStorageInfo volume, QStorageInfo::mountedVolumes()) {
         if (volume.rootPath().startsWith(mediaRoot) &&
             volume.isValid() && volume.isReady()) {
            return volume.rootPath();
         }
    }

    return QString();
}

QString CameraApplication::removableStoragePicturesLocation() const
{
    QString storageLocation = removableStorageLocation();
    if (storageLocation.isEmpty()) {
        return QString();
    }

    QStringList locations = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation);
    QString pictureDir = QString(locations.at(0)).split("/").value(3);
    if (pictureDir.isEmpty()){
        return QString();
    }
    QString location = storageLocation + "/" + pictureDir + "/" + QCoreApplication::applicationName();
    QDir dir;
    dir.mkpath(location);
    return location;
}

QString CameraApplication::removableStorageVideosLocation() const
{
    QString storageLocation = removableStorageLocation();
    if (storageLocation.isEmpty()) {
        return QString();
    }

    QStringList locations = QStandardPaths::standardLocations(QStandardPaths::MoviesLocation);
    QString movieDir = QString(locations.at(0)).split("/").value(3);
    if (movieDir.isEmpty()){
        return QString();
    }
    QString location = storageLocation + "/" + movieDir + "/" + QCoreApplication::applicationName();
    QDir dir;
    dir.mkpath(location);
    return location;
}
