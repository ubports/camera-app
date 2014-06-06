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
import Qt.labs.folderlistmodel 2.1

Item {
    id: galleryView

    signal exit
    property bool inView
    property var model: FolderListModel {
        folder: application.mediaLocation
        nameFilters: [ "*.png", "*.jpg", "*.jpeg", "*.PNG", "*.JPG", "*.JPEG" ]
        showOnlyReadable: true
        sortField: FolderListModel.LastModified
        sortReversed: true
        showDirs: false
    }

    function showLastPhotoTaken() {
        header.gridMode = false;
        slideshowView.showLastPhotoTaken();
    }

    SlideshowView {
        id: slideshowView
        anchors.fill: parent
        model: galleryView.model
        visible: opacity != 0.0
        onToggleHeader: header.toggle();
    }

    PhotogridView {
        id: photogridView
        anchors.fill: parent
        headerHeight: header.height
        model: galleryView.model
        visible: opacity != 0.0
        onPhotoClicked: {
            slideshowView.showPhotoAtIndex(index);
            header.gridMode = false;
        }
    }

    onInViewChanged: if (inView) {
                         header.show();
                     }

    state: header.gridMode ? "GRID" : "SLIDESHOW"
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

    GalleryViewHeader {
        id: header
    }
}
