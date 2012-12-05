/*
 * Copyright 2012 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    property alias source: snapshot.source
    property alias sliding: shoot.running

    Rectangle {
        id: shade
        color: "white"
        opacity: 0.0
        anchors.fill: parent
    }

    Item {
        id: container
        anchors.left: parent.left
        anchors.right: parent.right
        height:parent.height
        y: 0

        Image {
            id: snapshot
            anchors.centerIn: parent
            rotation: 90

            asynchronous: true
            opacity: 0.0
            fillMode: Image.PreserveAspectCrop
            smooth: false
            sourceSize.height: parent.width

            onStatusChanged: if (status == Image.Ready) shoot.restart()
        }
    }

    SequentialAnimation {
        id: shoot
        NumberAnimation { target: shade; property: "opacity"; to: 0.75;
                          duration: 200; easing.type: Easing.OutQuad }
        PropertyAction { target: shade; property: "opacity"; value: 0.0 }
        SequentialAnimation {
            id: sliding
            PropertyAction { target: snapshot; property: "opacity"; value: 1.0 }
            NumberAnimation { target: container; property: "y"; to: container.parent.height; duration: 800 }
            PropertyAction { target: snapshot; property: "opacity"; value: 0.0 }
            PropertyAction { target: snapshot; property: "source"; value: ""}
            PropertyAction { target: container; property: "y"; value: 0 }
        }
    }

}
