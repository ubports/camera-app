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

import QtQuick 2.4
import QtQuick.Window 2.2
import Ubuntu.Components 1.3

AbstractButton {
    id: button

    property alias iconName: icon.name
    property url iconSource
    property bool on: true
    property string label: ""
    property bool automaticOrientation: true

    width: units.gu(5)
    height: width

    Image {
        anchors.fill: parent
        source: "assets/ubuntu_shape.svg"
        opacity: button.pressed ? 0.7 : 0.3
        sourceSize.width: width
        sourceSize.height: height
        cache: true
        asynchronous: true
    }

    Icon {
        id: icon
        anchors {
            fill: parent
            margins: units.gu(1)
        }
        source: name ? "image://theme/%1".arg(name) : button.iconSource
        color: "white"
        opacity: button.on ? (button.enabled ? 1.0 : 0.3): 0.5
        visible: label === ""
        rotation: automaticOrientation ? Screen.angleBetween(Screen.primaryOrientation, Screen.orientation) : 0
        Behavior on rotation {
            RotationAnimator {
                duration: UbuntuAnimation.BriskDuration
                easing: UbuntuAnimation.StandardEasing
                direction: RotationAnimator.Shortest
            }
        }
        asynchronous: true
    }

    Label {
        anchors {
            centerIn: parent
        }
        font.weight: Font.Light
        fontSize: "small"
        color: "white"
        text: label
        opacity: button.on ? (button.enabled ? 1.0 : 0.3): 0.5
        visible: label !== ""
        rotation: automaticOrientation ? Screen.angleBetween(Screen.primaryOrientation, Screen.orientation) : 0
        Behavior on rotation {
            RotationAnimator {
                duration: UbuntuAnimation.BriskDuration
                easing: UbuntuAnimation.StandardEasing
                direction: RotationAnimator.Shortest
            }
        }
    }
}
