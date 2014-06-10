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
    property int currentIndex: listView.currentIndex
    signal toggleHeader

    function showPhotoAtIndex(index) {
        listView.positionViewAtIndex(index, ListView.Contain);
    }

    function showLastPhotoTaken() {
        listView.positionViewAtBeginning();
    }

    function exit() {
        listView.currentItem.zoomOut();
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
        highlightRangeMode: ListView.StrictlyEnforceRange
        spacing: units.gu(1)

        delegate: Item {
            function zoomIn(centerX, centerY) {
                flickable.scaleCenterX = centerX / flickable.width;
                flickable.scaleCenterY = centerY / flickable.height;
                flickable.sizeScale = 3.0;
            }

            function zoomOut() {
                flickable.scaleCenterX = flickable.contentX / flickable.width / (flickable.sizeScale - 1);
                flickable.scaleCenterY = flickable.contentY / flickable.height / (flickable.sizeScale - 1);
                flickable.sizeScale = 1.0;
            }

            width: ListView.view.width
            height: ListView.view.height

            ActivityIndicator {
                anchors.centerIn: parent
                visible: running
                running: image.status != Image.Ready
            }

            Flickable {
                id: flickable
                anchors.fill: parent
                contentWidth: media.width
                contentHeight: media.height
                contentX: (sizeScale - 1) * scaleCenterX * width
                contentY: (sizeScale - 1) * scaleCenterY * height

                property real sizeScale: 1.0
                property real scaleCenterX
                property real scaleCenterY
                Behavior on sizeScale { UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration} }

                Item {
                    id: media

                    width: flickable.width * flickable.sizeScale
                    height: flickable.height * flickable.sizeScale

                    Image {
                        id: image
                        anchors.fill: parent
                        asynchronous: true
                        cache: false
                        // FIXME: should use the thumbnailer instead of loading the full image and downscaling on the fly
                        source: fileURL
                        sourceSize {
                            width: flickable.width
                            height: flickable.height
                        }
                        fillMode: Image.PreserveAspectFit
                        opacity: status == Image.Ready ? 1.0 : 0.0
                        Behavior on opacity { UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration} }

                    }

                    Image {
                        id: highResolutionImage
                        anchors.fill: parent
                        asynchronous: true
                        cache: false
                        source: flickable.sizeScale > 1.0 ? fileURL : ""
                        sourceSize {
                            width: width
                            height: height
                        }
                        fillMode: Image.PreserveAspectFit
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        slideshowView.toggleHeader();
                        mouse.accepted = false;
                    }
                    onDoubleClicked: {
                        if (flickable.sizeScale == 1.0) {
                            zoomIn(mouse.x, mouse.y);
                        } else {
                            zoomOut();
                        }
                    }
                }
            }
        }
    }
}
