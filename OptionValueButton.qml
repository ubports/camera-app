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
    id: optionValueButton

    implicitHeight: units.gu(5)

    property alias label: label.text
    property alias iconName: icon.name
    property alias iconSource: icon.source
    property bool selected
    property bool isLast
    property int columnWidth
    property int marginSize: units.gu(1)

    width: marginSize + iconLabelGroup.width + marginSize

    Item {
        property bool showIcon:  iconName !== "" || (iconName == ""  && iconSource.toString().match(/^file:\/\//))
        id: iconLabelGroup
        width: (icon.width * showIcon) + label.width
        height: icon.height

        anchors {
            left:  parent.left
            leftMargin: marginSize
            verticalCenter: parent.verticalCenter
            topMargin: marginSize
            bottomMargin: marginSize
        }

        Icon {
            id: icon
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            width: optionValueButton.height - optionValueButton.marginSize * 2
            color: "white"
            opacity: optionValueButton.selected ? 1.0 : 0.5
            visible: iconLabelGroup.showIcon
            asynchronous: true
        }

        Label {
            id: label
            anchors {
                left: iconLabelGroup.showIcon ? icon.right : parent.left
                verticalCenter: parent.verticalCenter
            }

            color: "white"
            opacity: optionValueButton.selected ? 1.0 : 0.5
            width: paintedWidth
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        width: parent.columnWidth
        height: units.dp(1)
        color: "white"
        opacity: 0.5
        visible: !optionValueButton.isLast
    }
}
