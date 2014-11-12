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
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 0.1
import CameraApp 0.1
import "MimeTypeMapper.js" as MimeTypeMapper

Item {
    id: galleryView

    signal exit
    property bool inView
    property bool touchAcquired: slideshowView.touchAcquired
    property bool userSelectionMode: false
    property Item currentView: state == "GRID" ? photogridView : slideshowView
    property var model: FoldersModel {
        folders: [application.picturesLocation, application.videosLocation]
        typeFilters: !main.contentExportMode ? [ "image", "video" ]
                                              : [MimeTypeMapper.contentTypeToMimeType(main.transferContentType)]
        singleSelectionOnly: main.transfer.selectionType === ContentTransfer.Single
    }

    property list<Action> userSelectionActions: [
        Action {
            text: i18n.tr("Share")
            iconName: "share"
            onTriggered: {
                if (model.selectedFiles.length > 0)
                    PopupUtils.open(sharePopoverComponent)
            }
        },
        Action {
            text: i18n.tr("Delete")
            iconName: "delete"
            onTriggered: {
                if (model.selectedFiles.length > 0)
                    PopupUtils.open(deleteDialogComponent);
            }
        }
    ]

    property bool gridMode: false
    property bool showLastPhotoTakenPending: false

    function showLastPhotoTaken() {
        galleryView.gridMode = false;
        // do not immediately try to show the photo in the slideshow as it
        // might not be in the photo roll model yet
        showLastPhotoTakenPending = true;
    }

    function exitUserSelectionMode() {
        if (gridMode) {
            model.clearSelection();
            userSelectionMode = false;
        } else {
            gridMode = true;
        }
    }

    onExit: {
        slideshowView.exit();
        photogridView.exit();
    }

    OrientationHelper {
        visible: inView

        SlideshowView {
            id: slideshowView
            anchors.fill: parent
            model: galleryView.model
            visible: opacity != 0.0
            inView: galleryView.inView
            onToggleHeader: header.toggle();
        }

        PhotogridView {
            id: photogridView
            anchors.fill: parent
            headerHeight: header.height
            model: galleryView.model
            visible: opacity != 0.0
            inView: galleryView.inView
            inSelectionMode: main.contentExportMode || userSelectionMode
            onPhotoClicked: {
                slideshowView.showPhotoAtIndex(index);
                galleryView.gridMode = false;
            }
            onPhotoPressAndHold: {
                if (!userSelectionMode) {
                    userSelectionMode = true;
                    model.toggleSelected(index);
                }
            }

            onPhotoSelectionAreaClicked: {
                if (main.contentExportMode || userSelectionMode)
                    model.toggleSelected(index);
            }
        }

        // FIXME: it would be better to use the standard header from the toolkit
        GalleryViewHeader {
            id: header
            actions: userSelectionMode ? userSelectionActions : currentView.actions
            gridMode: galleryView.gridMode || main.contentExportMode
            validationVisible: main.contentExportMode && model.selectedFiles.length > 0
            userSelectionMode: galleryView.userSelectionMode
            onExit: {
                if (userSelectionMode)
                    galleryView.exitUserSelectionMode()
                else
                    galleryView.exit()
            }
            onToggleViews: {
                if (!galleryView.gridMode) {
                    // position grid view so that the current photo in slideshow view is visible
                    photogridView.showPhotoAtIndex(slideshowView.currentIndex);
                }

                galleryView.gridMode = !galleryView.gridMode
            }
            onValidationClicked: {
                var selection = model.selectedFiles;
                var urls = [];
                for (var i=0; i<selection.length; i++) {
                    urls.push(model.get(selection[i], "fileURL"));
                }
                model.clearSelection();
                main.exportContent(urls);
            }
        }
    }

    onInViewChanged: {
        if (inView) {
            header.show();
            if (showLastPhotoTakenPending) {
                slideshowView.showLastPhotoTaken();
                showLastPhotoTakenPending = false;
            }
        }
    }

    Rectangle {
        objectName: "noMediaHint"
        anchors.fill: parent
        visible: model.count === 0
        color: "#0F0F0F"

        Icon {
            id: noMediaIcon
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -units.gu(1)
            }
            height: units.gu(9)
            width: units.gu(9)
            color: "white"
            opacity: 0.2
            name: "camera-app-symbolic"
        }

        Label {
            id: noMediaLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: noMediaIcon.bottom
                topMargin: units.gu(4)
            }
            text: i18n.tr("No media available.")
            color: "white"
            opacity: 0.2
            fontSize: "large"
        }
    }

    state: galleryView.gridMode || main.contentExportMode ? "GRID" : "SLIDESHOW"
    states: [
        State {
            name: "SLIDESHOW"
            PropertyChanges {
                target: slideshowView
                scale: 1.0
                opacity: 1.0
            }
            PropertyChanges {
                target: photogridView
                scale: 1.4
                opacity: 0.0
            }
        },
        State {
            name: "GRID"
            PropertyChanges {
                target: slideshowView
                scale: 1.4
                opacity: 0.0
            }
            PropertyChanges {
                target: photogridView
                scale: 1.0
                opacity: 1.0
            }
        }
    ]

    transitions: [
        Transition {
            to: "*"
            UbuntuNumberAnimation { properties: "scale,opacity"; duration: UbuntuAnimation.SnapDuration }
        }
    ]

    Component {
        id: contentItemComp
        ContentItem {}
    }

    Component {
        id: sharePopoverComponent

        SharePopover {
            id: sharePopover

            transferContentType: MimeTypeMapper.mimeTypeToContentType(model.get(model.selectedFiles[0], "fileType"));
            transferItems: model.selectedFiles.map(function(row) {
                             return contentItemComp.createObject(parent, {"url": model.get(row, "filePath")});
                           })
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
                    for (var i=model.selectedFiles.length-1; i>=0; i--) {
                        var currentFilePath = model.get(model.selectedFiles[i], "filePath");
                        model.toggleSelected(model.selectedFiles[i])
                        fileOperations.remove(currentFilePath);
                    }

                    galleryView.exitUserSelectionMode();
                    PopupUtils.close(deleteDialog);
                }
            }
        }
    }
}
