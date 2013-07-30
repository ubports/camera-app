/*
 * Copyright 2012 Canonical Ltd.
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
import Ubuntu.Components 0.1

Item {
    property int time: 0
    property alias elapsed: count.text
    property alias fontSize: count.fontSize
    property alias labelRotation: count.rotation

    height: labelRotation % 180 === 0 ? intern.totalLabelHeight : intern.totalLabelWidth
    width: labelRotation % 180  === 0 ? intern.totalLabelWidth : intern.totalLabelHeight

    // FIXME: define all properties in one block

    Label {
        id: count

        anchors.centerIn: parent
        color: "white"
        // FIXME: factor into a named function
        text: {
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
        fontSize: "medium"
    }

    QtObject {
        id: intern

        property int totalLabelHeight: count.paintedHeight + 8 * 2
        property int totalLabelWidth: count.paintedWidth + 22 * 2

        function pad(text, length) {
            while (text.length < length) text = '0' + text;
            return text;
        }
    }
}
