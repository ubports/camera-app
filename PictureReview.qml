/*
 * Copyright (C) 2016 Canonical, Ltd.
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

import QtQuick 2.4
import QtQuick.Window 2.2

Item {
    id: snapshotRoot
    property alias source: image.source
    property ViewFinderGeometry geometry
    property bool loaded: image.status == Image.Ready

    // Rotation is locked at the moment the picture is shoot
    // (in case processing is long, such as with HDR)
    function lockOrientation() {
        image.rotation = Screen.angleBetween(Screen.primaryOrientation, Screen.orientation)
    }

    Image {
        id: image
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -geometry.y

        asynchronous: true
        cache: false
        fillMode: Image.PreserveAspectFit
        smooth: false
        width: rotation == 0 ? geometry.width : geometry.height
        height: rotation == 0 ? geometry.height : geometry.width
        sourceSize.width: width
        sourceSize.height: height
    }
}
