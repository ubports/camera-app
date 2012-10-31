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

AbstractButton {
    id: slider
    property real minimumValue
    property real maximumValue
    property real value
    property bool live

    property Component backgroundDelegate
    property Component thumbDelegate

    property real __normalizedValue: (value - minimumValue) / (maximumValue - minimumValue)

    Loader {
        id: background
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: backgroundDelegate
    }

    Loader {
        id: thumb
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: thumbDelegate

        Binding {
            target: thumb; when: !dragHandle.drag.active; property: "x";
            value: (background.width - thumb.width) * __normalizedValue
        }
    }

    onClicked: value = valueFromPosition(mouse.x - thumb.width / 2)

    MouseArea {
        id: dragHandle
        anchors.top: background.top
        anchors.bottom: background.bottom
        anchors.left: thumb.left
        anchors.right: thumb.right
        drag {
            target: thumb
            minimumX: 0
            maximumX: background.width - thumb.width
            axis: Drag.XAxis
            onActiveChanged: {
                if (!slider.live && !dragHandle.drag.active) slider.value = valueFromPosition(thumb.x)
            }
        }

        onXChanged: {
            if (drag.active && slider.live) slider.value = valueFromPosition(thumb.x)
        }

    }

    function valueFromPosition(position) {
        var value = ((maximumValue - minimumValue) * position  / (background.width - thumb.width)) + minimumValue
        return MathUtils.clamp(value, minimumValue, maximumValue)
    }
}
