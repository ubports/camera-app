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
import Ubuntu.Components 1.0

Item {
    id: snapshotRoot
    property alias source: snapshot.source
    property alias sliding: shoot.running
    property int orientation
    property ViewFinderGeometry geometry
    property bool deviceDefaultIsPortrait: true

    function startOutAnimation() {
        shoot.restart()
    }

    Item {
        id: container
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width
        visible: false

        Image {
            id: snapshot
            anchors.centerIn: parent
            rotation: snapshotRoot.orientation * -1

            asynchronous: true
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
        }
    }

    SequentialAnimation {
        id: shoot

        PropertyAction { target: container; property: "visible"; value: true }
        PauseAnimation { duration: 150 }
        XAnimator { target: container; to: container.width + shadow.width; duration: UbuntuAnimation.BriskDuration; easing: UbuntuAnimation.StandardEasing}
        PropertyAction { target: snapshot; property: "source"; value: ""}
        PropertyAction { target: container; property: "visible"; value: false }
        PropertyAction { target: container; property: "x"; value: 0 }
    }
}
