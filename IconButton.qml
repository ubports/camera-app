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
import Ubuntu.Components 1.3

AbstractButton {
    id: button

    property string iconName
    property alias iconColor: icon.color

    width: units.gu(5)
    height: width

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(1.0, 1.0, 1.0, 0.3)
        visible: button.pressed
    }

    Icon {
        id: icon
        anchors.centerIn: parent
        width: units.gu(2.5)
        height: width
        color: "white"
        name: action ? action.iconName : button.iconName
        opacity: action ? (action.enabled ? 1.0 : 0.5) : 1.0
        asynchronous: true
    }
}
