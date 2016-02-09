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

Item {
    id: viewFinderExportConfirmation

    property bool isVideo
    property string mediaPath
    property bool waitingForPictureCapture: false

    signal hideRequested()
    signal showRequested()
    property ViewFinderGeometry viewFinderGeometry

    visible: false

    // For videos show immediately without waiting for the preview to load,
    // since we will show a progress indicator instead of the preview
    onMediaPathChanged: if (mediaPath && isVideo) showRequested()

    function photoCaptureStarted() {
        controls.item.lockPictureOrientation()
        waitingForPictureCapture = true
    }

    Loader {
        id: controls
        anchors.fill: parent
        asynchronous: true
        sourceComponent: Component {
            Item {
                function lockPictureOrientation() { pictureReview.lockOrientation() }

                VideoReview {
                    id: videoReview
                    anchors.fill: parent
                    bottomMargin: buttons.height
                    videoPath: isVideo ? mediaPath : ""
                    visible: isVideo
                }

                PictureReview {
                    id: pictureReview
                    anchors.fill: parent
                    visible: !isVideo
                    geometry: viewFinderGeometry
                    source: !isVideo ? mediaPath : ""

                    // Show export confirmation only when the snapshot is loaded to prevent the
                    // screen being black while the image loads
                    onLoadedChanged: {
                        if (loaded) {
                             viewFinderExportConfirmation.showRequested()
                             waitingForPictureCapture = false
                         }
                    }
                }

                Item {
                    id: buttons
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: childrenRect.height

                    CircleButton {
                        id: retryButton
                        objectName: "retryButton"

                        anchors {
                            right: validateButton.left
                            rightMargin: units.gu(7.5)
                            bottom: parent.bottom
                            bottomMargin: units.gu(6)
                        }

                        iconName: "reload"
                        onClicked: hideRequested()
                    }

                    CircleButton {
                        id: validateButton
                        objectName: "validateButton"

                        width: units.gu(8)
                        anchors {
                            bottom: parent.bottom
                            bottomMargin: units.gu(5)
                            horizontalCenter: parent.horizontalCenter
                        }

                        iconName: "ok"
                        onClicked: {
                            hideRequested();
                            main.exportContent([mediaPath]);
                            mediaPath = "";
                        }
                    }

                    CircleButton {
                        id: cancelButton
                        objectName: "cancelButton"

                        anchors {
                            left: validateButton.right
                            leftMargin: units.gu(7.5)
                            bottom: parent.bottom
                            bottomMargin: units.gu(6)
                        }

                        iconName: "close"
                        onClicked: {
                            hideRequested();
                            main.cancelExport();
                            mediaPath = "";
                        }
                    }
                }
            }
        }
    }
}
