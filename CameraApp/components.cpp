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

#include <QtQuick>
#include "components.h"
#include "advancedcamerasettings.h"

void Components::registerTypes(const char *uri)
{
    qmlRegisterUncreatableType<AdvancedCameraSettings>(uri, 0, 1, "AdvancedCameraSettings",
        "Please access this singleton via the context property advancedCameraSettings.");
}

void Components::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
    engine->rootContext()->setContextProperty("advancedCameraSettings",
        &AdvancedCameraSettings::instance());
}
