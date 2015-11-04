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
import Qt.labs.settings 1.0

Item {
    id: photoRollHint

    property bool necessary: true
    property bool enabled: false

    function enable() {
        photoRollHint.enabled = true;
    }

    function disable() {
        if (photoRollHint.enabled) {
            photoRollHint.necessary = false;
            photoRollHint.enabled = false;
        }
    }

    // Display the hint only once after taking the very first photo
    Settings {
        property alias photoRollHintNecessary: photoRollHint.necessary
    }

    OrientationHelper {
        Image {
            id: hintPictogram
            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: units.gu(4)
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -units.gu(1)
            }

            asynchronous: true
            cache: false
            source: photoRollHint.enabled ? "assets/camera_swipe.png" : ""
        }

        Label {
            id: hintLabel

            anchors {
                top: hintPictogram.bottom
                topMargin: units.gu(5)
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - 2 * units.gu(2)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: i18n.tr("Swipe left for photo roll")
            fontSize: "x-large"
            color: "#ebebeb"
        }
    }
}
