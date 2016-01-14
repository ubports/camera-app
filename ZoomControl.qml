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

Item {
    id: zoomControl
    property alias minimumValue: slider.minimumValue
    property alias maximumValue: slider.maximumValue
    property alias value: slider.value

    function show() {
        zoomAutoHide.restart();
        shown = true;
    }

    property bool shown: false
    visible: opacity != 0.0
    opacity: shown ? 1.0 : 0.0
    layer.enabled: fadeAnimation.running
    Behavior on opacity { UbuntuNumberAnimation {id: fadeAnimation} }

    Timer {
        id: zoomAutoHide
        interval: 2000
        onTriggered: {
            zoomControl.shown = false;
        }
    }

    implicitHeight: slider.height

    Image {
        id: minusIcon
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        source: "assets/zoom_minus.png"
        asynchronous: true
        cache: false
    }

    Slider {
        id: slider
        style: ThinSliderStyle {}
        anchors {
            left: minusIcon.right
            right: plusIcon.left
        }

        live: true
        minimumValue: 0.0 // No zoom => 0.0 zoom factor
        value: minimumValue
    }

    Image {
        id: plusIcon
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        source: "assets/zoom_plus.png"
        asynchronous: true
        cache: false
    }
}

