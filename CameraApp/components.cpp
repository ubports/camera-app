/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * Authors:
 *  Ugo Riboni <ugo.riboni@canonical.com>
 *  Florian Boucault <florian.boucault@canonical.com>
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

#include <QtQuick>
#include "components.h"
#include "advancedcamerasettings.h"
#include "fileoperations.h"
#include "foldersmodel.h"
#include "storagemonitor.h"
#include "storagelocations.h"

static QObject* StorageLocations_singleton_factory(QQmlEngine* engine, QJSEngine* scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    return new StorageLocations();
}

void Components::registerTypes(const char *uri)
{
   Q_ASSERT(uri == QLatin1String("CameraApp"));

    // @uri CameraApp
    qmlRegisterType<AdvancedCameraSettings>(uri, 0, 1, "AdvancedCameraSettings");
    qmlRegisterType<FileOperations>(uri, 0, 1, "FileOperations");
    qmlRegisterType<FoldersModel>(uri, 0, 1, "FoldersModel");
    qmlRegisterType<StorageMonitor>(uri, 0, 1, "StorageMonitor");
    qmlRegisterSingletonType<StorageLocations>(uri, 0, 1, "StorageLocations", StorageLocations_singleton_factory);
}

void Components::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}
