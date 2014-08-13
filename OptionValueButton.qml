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

import QtQuick 2.0
import Ubuntu.Components 1.0

AbstractButton {
    id: optionValueButton

    implicitHeight: units.gu(5)

    property alias label: label.text
    property alias iconName: icon.name
    property bool selected
    property bool isLast

    Icon {
        id: icon
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
            leftMargin: units.gu(1)
        }
        width: height
        color: "white"
        opacity: optionValueButton.selected ? 1.0 : 0.5
        visible: name !== ""
    }

    Label {
        id: label
        anchors {
            left: icon.name != "" ? icon.right : parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        color: "white"
        opacity: optionValueButton.selected ? 1.0 : 0.5
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.dp(1)
        color: "white"
        opacity: 0.5
        visible: !optionValueButton.isLast
    }
}
