/*
 * Copyright 2014 Canonical Ltd.
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

import QtQuick 2.2
import Ubuntu.Components 1.1

Loader {
    id: loader

    property var camera
    property bool touchAcquired: loader.item ? loader.item.touchAcquired : false
    property real revealProgress: loader.item ? loader.item.revealProgress : 0

    function showFocusRing(x, y) {
        loader.item.showFocusRing(x, y);
    }

    asynchronous: true
    Component.onCompleted: {
        loader.setSource("ViewFinderOverlay.qml", { "camera": loader.camera });
    }
}
