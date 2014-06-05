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
import QtQuick.Layouts 1.1

Item {
    id: galleryView

    signal exit
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
    }

    PhotogridView {
        id: photogridView
        anchors.fill: parent
        model: galleryView.model
        visible: opacity != 0.0
        onPhotoClicked: {
            slideshowView.showPhotoAtIndex(index);
            header.gridMode = false;
        }
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

    Item {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: units.gu(7)

        property bool gridMode: false

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.6
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            IconButton {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: units.gu(8)
                iconHeight: units.gu(3)
                iconWidth: iconHeight
                iconName: "back"
                iconColor: Theme.palette.normal.foregroundText
                onClicked: galleryView.exit()
            }

            Label {
                text: i18n.tr("Photo Roll")
                fontSize: "x-large"
                color: Theme.palette.normal.foregroundText
                Layout.fillWidth: true
            }

            ImageButton {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: units.gu(6)
                iconSource: "assets/gridview.png"
                onClicked: {
                    if (!header.gridMode) {
                        // position grid view so that the current photo in slideshow view is visible
                        photogridView.showPhotoAtIndex(slideshowView.currentIndex);
                    }

                    header.gridMode = !header.gridMode
                }
//            IconButton {
//                iconName: "view-grid-symbolic"
            }

            ImageButton {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: units.gu(6)
                iconSource: "assets/options.png"
//            IconButton {
//                iconName: "contextual-menu"
            }
        }
    }

}
