/*
 * Copyright 2016 Canonical Ltd.
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
    id: processingFeedback

    property bool processing: false

    Timer {
        interval: 2000
        running: processing
        onTriggered: spinner.running = true
    }

    onProcessingChanged: if (!processing) spinner.running = false

    ActivityIndicator {
        id: spinner
        opacity: running ? 1.0 : 0.0
        Behavior on opacity {
            OpacityAnimator {
                duration: UbuntuAnimation.SnapDuration
                easing: UbuntuAnimation.StandardEasing
            }
        }
    }
}
