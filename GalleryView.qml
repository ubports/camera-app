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
import Ubuntu.Content 1.3
import Ubuntu.Thumbnailer 0.1
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
        folders: [StorageLocations.picturesLocation, StorageLocations.videosLocation,
                  StorageLocations.removableStoragePicturesLocation,
                  StorageLocations.removableStorageVideosLocation]
        typeFilters: !main.contentExportMode ? [ "image", "video" ]
                                              : [MimeTypeMapper.contentTypeToMimeType(main.transferContentType)]
        singleSelectionOnly: main.contentExportMode && main.transfer.selectionType === ContentTransfer.Single
    }

    property bool gridMode: main.contentExportMode
    property bool showLastPhotoTakenPending: false

    function showLastPhotoTaken() {
        galleryView.gridMode = false;
        // do not immediately try to show the photo in the slideshow as it
        // might not be in the photo roll model yet
        showLastPhotoTakenPending = true;
    }

    function prependMediaToModel(filePath) {
        galleryView.model.prependFile(filePath);
    }

    function precacheThumbnail(filePath) {
        preCachingThumbnail.filename = filePath;
    }

    function exitUserSelectionMode() {
        model.clearSelection();
        userSelectionMode = false;
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
            inView: galleryView.inView && galleryView.currentView == slideshowView
            focus: inView
            inSelectionMode: main.contentExportMode || galleryView.userSelectionMode
            onToggleSelection: model.toggleSelected(currentIndex)
            onToggleHeader: header.toggle();
        }

        PhotogridView {
            id: photogridView
            anchors.fill: parent
            headerHeight: header.height
            userSelectionMode: galleryView.userSelectionMode
            model: galleryView.model
            visible: opacity != 0.0
            inView: galleryView.inView && galleryView.currentView == photogridView
            focus: inView
            inSelectionMode: main.contentExportMode || galleryView.userSelectionMode
            onPhotoClicked: {
                slideshowView.showPhotoAtIndex(index);
                galleryView.gridMode = false;
            }
            onPhotoPressAndHold: {
                if (!galleryView.userSelectionMode) {
                    galleryView.userSelectionMode = true;
                    model.toggleSelected(index);
                }
            }

            onPhotoSelectionAreaClicked: {
                if (main.contentExportMode || galleryView.userSelectionMode)
                    model.toggleSelected(index);
            }
            onExitUserSelectionMode: galleryView.exitUserSelectionMode()
            onToggleHeader: header.toggle()
        }

        // FIXME: it would be better to use the standard header from the toolkit
        GalleryViewHeader {
            id: header
            actions: currentView.actions
            gridMode: galleryView.gridMode
            validationVisible: main.contentExportMode && model.selectedFiles.length > 0 && galleryView.gridMode
            userSelectionMode: galleryView.userSelectionMode
            onExit: {
                if ((main.contentExportMode || userSelectionMode) && !galleryView.gridMode) {
                    galleryView.gridMode = true;
                    // position grid view so that the current photo in slideshow view is visible
                    photogridView.showPhotoAtIndex(slideshowView.currentIndex);
                } else if (userSelectionMode) {
                    galleryView.exitUserSelectionMode();
                } else {
                    galleryView.exit()
                }
            }
            onToggleViews: {
                if (!galleryView.gridMode) {
                    // position grid view so that the current photo in slideshow view is visible
                    photogridView.showPhotoAtIndex(slideshowView.currentIndex);
                }

                galleryView.gridMode = !galleryView.gridMode
            }
            onToggleSelectAll: {
                if (model.selectedFiles.length != model.count)
                    model.selectAll();
                else
                    model.clearSelection();
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
        visible: model.count === 0 && !model.loading
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
            asynchronous: true
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

    Rectangle {
        objectName: "scanningMediaHint"
        anchors.fill: parent
        visible: model.count === 0 && model.loading
        color: "#0F0F0F"

        Icon {
            id: scanningMediaIcon
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
            asynchronous: true
        }

        Label {
            id: scanningMediaLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: scanningMediaIcon.bottom
                topMargin: units.gu(4)
            }
            text: i18n.tr("Scanning for content...")
            color: "white"
            opacity: 0.2
            fontSize: "large"
        }
    }

    // This image component is used to pre-load thumbnails of recently
    // created files.  This is primarily to hide the delays in
    // thumbnailing videos.
    Image {
        id: preCachingThumbnail
        property string filename

        visible: false
        asynchronous: true
        cache: false
        sourceSize.width: 32
        sourceSize.height: 32
        source: filename ? "image://thumbnailer/%1".arg(filename) : ""

        onStatusChanged: {
            if (status == Image.Ready) {
                filename = "";
            }
        }
    }

    state: galleryView.gridMode ? "GRID" : "SLIDESHOW"
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
}
