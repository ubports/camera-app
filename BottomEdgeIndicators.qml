/*
 * Copyright 2015-2016 Canonical Ltd.
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

Item {
    id: bottomEdgeIndicators

    property var options
    width: indicatorsRow.width + units.gu(2) + emptyIndicatorsHint.width
    height: units.gu(3)

    Image {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: parent.height * 2
        opacity: 0.3
        source: "assets/ubuntu_shape.svg"
        sourceSize.width: width
        sourceSize.height: height
        cache: false
        asynchronous: true
    }

    Icon {
        id: emptyIndicatorsHint
        objectName: "emptyIndicatorsHint"
        name: "go-up"
        opacity: 0.5
        color: "white"
        visible: indicatorsRow.visibleChildren.length <= 1
        anchors {
            top: parent.top
            topMargin: units.gu(0.5)
            bottom: parent.bottom
            bottomMargin: units.gu(0.5)
            horizontalCenter: parent.horizontalCenter
        }
        width: visible ? height * 1.5 : 0
        asynchronous: true
    }

    Row {
        id: indicatorsRow
        objectName: "indicatorsRow"

        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        spacing: units.gu(1)

        Repeater {
            model: bottomEdgeIndicators.options
            delegate: Item {
                anchors {
                    top: parent.top
                    topMargin: units.gu(0.5)
                    bottom: parent.bottom
                    bottomMargin: units.gu(0.5)
                }
                width: units.gu(2)
                visible: modelData.showInIndicators && modelData.available && modelData.visible ? (modelData.isToggle ? modelData.get(model.selectedIndex).value : true) : false
                opacity: 0.5

                Icon {
                    id: indicatorIcon
                    anchors.fill: parent
                    color: modelData.colorize ? "red" : "white"
                    name: modelData && modelData.isToggle ?
                                                        modelData.icon :
                                                        (modelData.get(model.selectedIndex) && modelData.get(model.selectedIndex).icon ? modelData.get(model.selectedIndex).icon : "")
                    source: name ? "image://theme/%1".arg(name) : (modelData.iconSource || "")
                    visible: source != ""
                    asynchronous: true
                }

                Label {
                    id: indicatorLabel
                    anchors.fill: parent
                    fontSize: "xx-small"
                    color: "white"
                    text: modelData.label
                    verticalAlignment: Text.AlignVCenter
                    visible: indicatorIcon.name === ""
                }
            }
        }
    }
}
