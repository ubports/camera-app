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
import Ubuntu.Components.ListItems 1.0 as ListItems
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 0.1
import Ubuntu.Thumbnailer 0.1
import CameraApp 0.1
import "MimeTypeMapper.js" as MimeTypeMapper

Item {
    id: slideshowView

    property var model
    property int currentIndex: listView.currentIndex
    property string currentFilePath: slideshowView.model.get(slideshowView.currentIndex, "filePath")
    property string currentFileType: slideshowView.model.get(slideshowView.currentIndex, "fileType")

    signal toggleHeader
    property list<Action> actions: [
        Action {
            text: i18n.tr("Share")
            iconName: "share"
            onTriggered: PopupUtils.open(sharePopoverComponent)
        },
        Action {
            text: i18n.tr("Delete")
            iconName: "delete"
            onTriggered: PopupUtils.open(deleteDialogComponent)
        }
    ]

    function showPhotoAtIndex(index) {
        listView.positionViewAtIndex(index, ListView.Contain);
    }

    function showLastPhotoTaken() {
        listView.positionViewAtBeginning();
    }

    function exit() {
        if (listView.currentItem) {
            listView.currentItem.zoomOut();
        }
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
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: width
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem
        spacing: units.gu(1)
        property real maxDimension: Math.max(width, height)

        delegate: Item {
            function zoomIn(centerX, centerY) {
                flickable.scaleCenterX = centerX / flickable.width;
                flickable.scaleCenterY = centerY / flickable.height;
                flickable.sizeScale = 3.0;
            }

            function zoomOut() {
                if (flickable.sizeScale != 1.0) {
                    flickable.scaleCenterX = flickable.contentX / flickable.width / (flickable.sizeScale - 1);
                    flickable.scaleCenterY = flickable.contentY / flickable.height / (flickable.sizeScale - 1);
                    flickable.sizeScale = 1.0;
                }
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
                property real scaleCenterX: 0.0
                property real scaleCenterY: 0.0
                Behavior on sizeScale { UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration} }

                Item {
                    id: media

                    width: flickable.width * flickable.sizeScale
                    height: flickable.height * flickable.sizeScale

                    property bool isVideo: MimeTypeMapper.mimeTypeToContentType(fileType) === ContentType.Videos

                    Image {
                        id: image
                        anchors.fill: parent
                        asynchronous: true
                        cache: false
                        source: "image://thumbnailer/" + fileURL.toString()
                        sourceSize {
                            width: listView.maxDimension
                            height: listView.maxDimension
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

                Icon {
                    width: units.gu(5)
                    height: units.gu(5)
                    anchors.centerIn: parent
                    name: "media-playback-start"
                    color: "white"
                    opacity: 0.8
                    visible: media.isVideo
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        slideshowView.toggleHeader();
                        mouse.accepted = false;
                    }
                    onDoubleClicked: {
                        if (media.isVideo) {
                            return;
                        }

                        if (flickable.sizeScale == 1.0) {
                            zoomIn(mouse.x, mouse.y);
                        } else {
                            zoomOut();
                        }
                    }
                }

                MouseArea {
                    anchors.centerIn: parent
                    width: units.gu(10)
                    height: units.gu(10)
                    enabled: media.isVideo
                    onClicked: {
                        if (media.isVideo) {
                            Qt.openUrlExternally(fileURL);
                        }
                    }
                }
            }
        }
    }


    Component {
        id: sharePopoverComponent

        PopupBase {
            id: sharePopover

            fadingAnimation: UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration }

            // FIXME: ContentPeerPicker should either have a background or not, not half of one
            Rectangle {
                anchors.fill: parent
                color: Theme.palette.normal.overlay
            }

            ContentItem {
                id: contentItem
                url: slideshowView.currentFilePath
            }

            ContentPeerPicker {
                // FIXME: ContentPeerPicker should define an implicit size and not refer to its parent
                // FIXME: ContentPeerPicker should not be visible: false by default
                visible: true
                contentType: MimeTypeMapper.mimeTypeToContentType(slideshowView.currentFileType)
                handler: ContentHandler.Share

                onPeerSelected: {
                    var transfer = peer.request();
                    if (transfer.state === ContentTransfer.InProgress) {
                        transfer.items = [ contentItem ];
                        transfer.state = ContentTransfer.Charged;
                    }
                    PopupUtils.close(sharePopover);
                }
                onCancelPressed: PopupUtils.close(sharePopover);
            }
        }
    }

    Component {
        id: deleteDialogComponent

        Dialog {
            id: deleteDialog

            title: i18n.tr("Delete media?")

            FileOperations {
                id: fileOperations
            }

            Button {
                text: i18n.tr("Cancel")
                color: UbuntuColors.warmGrey
                onClicked: PopupUtils.close(deleteDialog)
            }
            Button {
                text: i18n.tr("Delete")
                color: UbuntuColors.orange
                onClicked: {
                    fileOperations.remove(slideshowView.currentFilePath);
                    PopupUtils.close(deleteDialog);
                }
            }
        }
    }
}
