/*
 * Copyright (C) 2012 Canonical, Ltd.
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
import Ubuntu.Components 1.3

Item {
    id: snapshotRoot
    property alias source: snapshot.source
    property bool shouldSlide: true
    property bool sliding: false
    property int orientation
    property ViewFinderGeometry geometry
    property bool deviceDefaultIsPortrait: true
    property bool loading: snapshot.status == Image.Loading

    opacity: 0.0

    // Rotation and sliding direction is locked at the moment the picture is shoot
    // (in case processing is long, such as with HDR)
    function lockOrientation() { snapshot.rotation = orientationAngle }

    Item {
        id: container
        width: parent.width
        height: parent.height

        Image {
            id: snapshot
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

            onStatusChanged: if (shouldSlide && snapshot.status == Image.Ready) shoot.restart()
        }

        Image {
            id: shadow

            transformOrigin: Item.TopLeft
            rotation: snapshot.rotation
            width: units.gu(2)
            height: rotation == 0 ? snapshot.height : snapshot.width
            x: rotation == 90 ? container.width : - width
            y: rotation == 270 ? container.height + width : (rotation == 90 ? - width : 0)
            source: "assets/shadow.png"
            fillMode: Image.Stretch
            asynchronous: true
            cache: false
        }
    }
    property int orientationAngle: Screen.angleBetween(Screen.primaryOrientation, Screen.orientation)
    property var angleToOrientation: {0: "PORTRAIT",
                                      90: "LANDSCAPE",
                                      270: "INVERTED_LANDSCAPE"}

    SequentialAnimation {
        id: shoot

        NumberAnimation {
            target: snapshotRoot; property: "opacity"; to: 1.0
            duration: UbuntuAnimation.SnapDuration
        }
        PauseAnimation { duration: 150 }
        PropertyAction { target: snapshotRoot; property: "sliding"; value: true}
        XAnimator {
            target: container
            to: angleToOrientation[orientationAngle] == "PORTRAIT" ? container.width + shadow.width : 0
            duration: UbuntuAnimation.BriskDuration
            easing: UbuntuAnimation.StandardEasing
        }
        YAnimator {
            target: container
            to: angleToOrientation[orientationAngle] == "LANDSCAPE" ? container.height + shadow.width :
                angleToOrientation[orientationAngle] == "INVERTED_LANDSCAPE" ? -(container.height + shadow.width) : 0
            duration: UbuntuAnimation.BriskDuration
            easing: UbuntuAnimation.StandardEasing
        }
        PropertyAction { target: snapshot; property: "source"; value: ""}
        PropertyAction { target: snapshotRoot; property: "opacity"; value: 0.0 }
        PropertyAction { target: container; property: "x"; value: 0 }
        PropertyAction { target: container; property: "y"; value: 0 }
        PropertyAction { target: snapshotRoot; property: "sliding"; value: false}
    }
}
