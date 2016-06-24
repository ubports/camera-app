/*
 * Copyright 2015 Canonical Ltd.
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
    property string videoPath
    property int bottomMargin

    Image {
        id: thumbnail
        anchors.fill: parent

        fillMode: Image.PreserveAspectFit
        sourceSize.width: width
        sourceSize.height: height

        source: videoPath ? "image://thumbnailer/%1".arg(videoPath) : ""
        opacity: status == Image.Ready ? 1.0 : 0.0
        Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration } }
    }

    Item {
        anchors.fill: parent
        anchors.bottomMargin: parent.bottomMargin

        ActivityIndicator {
            anchors.centerIn: parent
            visible: running
            running: thumbnail.status == Image.Loading
        }

        Icon {
            width: units.gu(5)
            height: units.gu(5)
            anchors.centerIn: parent
            name: "media-playback-start"
            color: "white"
            opacity: 0.8
            asynchronous: true
        }

        MouseArea {
            anchors.centerIn: parent
            width: units.gu(10)
            height: units.gu(10)
            onClicked: Qt.openUrlExternally("video://%1".arg(videoPath));
        }
    }
}
