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

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: shootButton

    signal clicked()

    width: icon.width
    height: icon.height
    opacity: enabled ? 1.0 : 0.5

    MouseArea {
        anchors.fill: parent
        onClicked: shootButton.clicked()
    }

    Image {
        id: icon
        anchors.centerIn: parent
        cache: false
        asynchronous: true
    }

    states: [
        State {
            name: "camera"
            PropertyChanges { target: icon; source: "assets/shutter_stills.png" }
        },
        State {
            name: "record_off"
            PropertyChanges { target: icon; source: "assets/record_video.png" }

        },
        State {
            name: "record_on"
            PropertyChanges { target: icon; source: "assets/record_video_stop.png" }
        }
    ]
}
