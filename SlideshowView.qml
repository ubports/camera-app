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

import QtQuick 2.2
import Ubuntu.Components 1.0

Item {
    id: slideshowView

    property var model

    function showLastPhotoTaken() {
        listView.positionViewAtBeginning();
    }

    ListView {
        id: listView
        Component.onCompleted: {
            // FIXME: workaround for qtubuntu not returning values depending on the grid unit definition
            // for Flickable.maximumFlickVelocity and Flickable.flickDeceleration
            var scaleFactor = units.gridUnit / 8;
            maximumFlickVelocity = maximumFlickVelocity * scaleFactor;
            flickDeceleration = flickDeceleration * scaleFactor;
        }

        anchors.fill: parent
        model: slideshowView.model
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: width
        spacing: units.gu(1)

        delegate: Item {
            width: ListView.view.width
            height: ListView.view.height

            ActivityIndicator {
                anchors.centerIn: parent
                visible: running
                running: image.status != Image.Ready
            }

            Image {
                id: image
                anchors.fill: parent
//                scale:
                asynchronous: true
                cache: false
                // FIXME: should use the thumbnailer instead of loading the full image and downscaling on the fly
                source: fileURL
                sourceSize {
                    width: width
                    height: height
                }
                fillMode: Image.PreserveAspectFit
                opacity: status == Image.Ready ? 1.0 : 0.0
                Behavior on opacity { UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration} }
            }
        }
    }
}
