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
import QtQuick.Window 2.0
import Ubuntu.Components 1.0

Item {
    property int time: 0
    property alias label: countLabel.text

    width: content.childrenRect.width + content.anchors.leftMargin + content.anchors.rightMargin
    height: content.childrenRect.height + units.gu(1.5)

    rotation: Screen.angleBetween(Screen.primaryOrientation, Screen.orientation)
    Behavior on rotation {
        RotationAnimator {
            duration: UbuntuAnimation.BriskDuration
            easing: UbuntuAnimation.StandardEasing
            direction: RotationAnimator.Shortest
        }
    }

    BorderImage {
        id: background

        anchors.fill: parent
        source: "assets/ubuntu_shape.sci"
        opacity: 0.3
        asynchronous: true
        cache: false
    }

    Row {
        id: content

        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }
        height: childrenRect.height
        spacing: units.gu(1.5)

        Rectangle {
            anchors.verticalCenter: countLabel.verticalCenter
            radius: units.gu(2)
            width: radius
            height: radius
            color: "#AE1623"
        }

        Label {
            id: countLabel

            color: "white"
            fontSize: "large"
            style: Text.Raised
            styleColor: "black"
            text: intern.formattedTime()
        }
    }

    QtObject {
        id: intern

        function pad(text, length) {
            while (text.length < length) text = '0' + text;
            return text;
        }

        function formattedTime() {
            var prefix = ""
            if (time < 0) {
                prefix = "-";
                time = -time;
            }
            var divisor_for_minutes = time % (60 * 60);
            var minutes = String(Math.floor(divisor_for_minutes / 60));

            var divisor_for_seconds = divisor_for_minutes % 60;
            var seconds = String(Math.ceil(divisor_for_seconds));

            return "%1%2:%3".arg(prefix).arg(intern.pad(minutes, 2)).arg(intern.pad(seconds, 2));
        }
    }
}
