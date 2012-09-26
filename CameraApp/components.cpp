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

#include "components.h"

#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/qdeclarative.h>

void Components::initializeEngine(QDeclarativeEngine *engine, const char *uri)
{
    Q_ASSERT(engine);
    Q_UNUSED(uri);

    mRootContext = engine->rootContext();
    Q_ASSERT(mRootContext);
}

void Components::registerTypes(const char *uri)
{
    // @uri TelephonyApp
}

Q_EXPORT_PLUGIN2(components, Components)
