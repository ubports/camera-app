/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "storageinfocontrol.h"

StorageInfoControl* StorageInfoControl::instance() {
    static StorageInfoControl* instance = new StorageInfoControl();
    return instance;
}

StorageInfoControl::StorageInfoControl() {
    validMap.insert("/tmp/ok", true);
    validMap.insert("/tmp/unmounted", true);
    validMap.insert("/tmp/invalid", false);

    readyMap.insert("/tmp/ok", true);
    readyMap.insert("/tmp/unmounted", false);
    readyMap.insert("/tmp/invalid", false);

    freeSpaceMap.insert("/tmp/ok", 0);
    freeSpaceMap.insert("/tmp/unmounted", 0);
    freeSpaceMap.insert("/tmp/invalid", 0);
}
