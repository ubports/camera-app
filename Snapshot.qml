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

import QtQuick 2.2
import QtQuick.Window 2.0
import Ubuntu.Components 1.3

Item {
    id: snapshotRoot
    property alias source: snapshot.source
    property alias sliding: shoot.running
    property int orientation
    property ViewFinderGeometry geometry
    property bool deviceDefaultIsPortrait: true
    property bool loading: snapshot.status == Image.Loading

    function startOutAnimation() {
        shoot.restart()
    }

    visible: false

    Item {
        id: container
        width: parent.width
        height: parent.height

        Image {
            id: snapshot
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -geometry.y
            rotation: snapshotRoot.orientation * -1

            asynchronous: true
            cache: false
            fillMode: Image.PreserveAspectFit
            smooth: false
            width: deviceDefaultIsPortrait ? geometry.height : geometry.width
            height: deviceDefaultIsPortrait ? geometry.width : geometry.height
            sourceSize.width: width
            sourceSize.height: height
        }

        Image {
            id: shadow

            property bool rotated: (snapshot.rotation % 180) != 0
            height: rotated ? snapshot.width : snapshot.height
            width: units.gu(2)
            x: (container.width - (rotated ? snapshot.height : snapshot.width)) / 2 - width
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

        PropertyAction { target: snapshotRoot; property: "visible"; value: true }
        PauseAnimation { duration: 150 }
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
        PropertyAction { target: snapshotRoot; property: "visible"; value: false }
        PropertyAction { target: container; property: "x"; value: 0 }
        PropertyAction { target: container; property: "y"; value: 0 }
    }
}
