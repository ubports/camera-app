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
import QtQuick.Window 2.2
import QtMultimedia 5.0
import Ubuntu.Components 1.3
import Ubuntu.Unity.Action 1.1 as UnityActions
import UserMetrics 0.1
import Ubuntu.Content 0.1
import CameraApp 0.1

Window {
    id: main
    objectName: "main"
    width: height * viewFinderView.aspectRatio
    height: units.gu(80)
    color: "black"
    title: "Camera"

    UnityActions.ActionManager {
        actions: [
            UnityActions.Action {
                text: i18n.tr("Flash")
                keywords: i18n.tr("Light;Dark")
            },
            UnityActions.Action {
                text: i18n.tr("Flip Camera")
                keywords: i18n.tr("Front Facing;Back Facing")
            },
            UnityActions.Action {
                text: i18n.tr("Shutter")
                keywords: i18n.tr("Take a Photo;Snap;Record")
            },
            UnityActions.Action {
                text: i18n.tr("Mode")
                keywords: i18n.tr("Stills;Video")
                enabled: false
            },
            UnityActions.Action {
                text: i18n.tr("White Balance")
                keywords: i18n.tr("Lighting Condition;Day;Cloudy;Inside")
            }
        ]

        onQuit: {
            Qt.quit()
        }
    }

    Component.onCompleted: {
        i18n.domain = "camera-app";
        if (!application.desktopMode) {
            main.showFullScreen();
        } else {
            main.show();
        }
    }


    Flickable {
        id: viewSwitcher
        objectName: "viewSwitcher"
        anchors.fill: parent
        flickableDirection: state == "PORTRAIT" ? Flickable.HorizontalFlick : Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds

        property real panesMargin: units.gu(1)
        property real ratio
        property int orientationAngle: Screen.angleBetween(Screen.primaryOrientation, Screen.orientation)
        property var angleToOrientation: {0: "PORTRAIT",
                                          90: "LANDSCAPE",
                                          270: "INVERTED_LANDSCAPE"}
        state: angleToOrientation[orientationAngle]
        states: [
            State {
                name: "PORTRAIT"
                StateChangeScript {
                    script: {
                        viewSwitcher.ratio = viewSwitcher.ratio;
                        viewSwitcher.contentWidth = Qt.binding(function() { return viewSwitcher.width * 2 + viewSwitcher.panesMargin });
                        viewSwitcher.contentHeight = Qt.binding(function() { return viewSwitcher.height });
                        galleryView.x = Qt.binding(function() { return viewFinderView.width + viewSwitcher.panesMargin });
                        galleryView.y = 0;
                        viewFinderView.x = 0;
                        viewFinderView.y = 0;
                        viewSwitcher.positionContentAtRatio(viewSwitcher.ratio)
                        viewSwitcher.ratio = Qt.binding(function() { return viewSwitcher.contentX / viewSwitcher.contentWidth });
                    }
                }
            },
            State {
                name: "LANDSCAPE"
                StateChangeScript {
                    script: {
                        viewSwitcher.ratio = viewSwitcher.ratio;
                        viewSwitcher.contentWidth = Qt.binding(function() { return viewSwitcher.width });
                        viewSwitcher.contentHeight = Qt.binding(function() { return viewSwitcher.height * 2 + viewSwitcher.panesMargin });
                        galleryView.x = 0;
                        galleryView.y = Qt.binding(function() { return viewFinderView.height + viewSwitcher.panesMargin });
                        viewFinderView.x = 0;
                        viewFinderView.y = 0;
                        viewSwitcher.positionContentAtRatio(viewSwitcher.ratio)
                        viewSwitcher.ratio = Qt.binding(function() { return viewSwitcher.contentY / viewSwitcher.contentHeight });
                    }
                }
            },
            State {
                name: "INVERTED_LANDSCAPE"
                StateChangeScript {
                    script: {
                        viewSwitcher.ratio = viewSwitcher.ratio;
                        viewSwitcher.contentWidth = Qt.binding(function() { return viewSwitcher.width });
                        viewSwitcher.contentHeight = Qt.binding(function() { return viewSwitcher.height * 2 + viewSwitcher.panesMargin });
                        galleryView.x = 0;
                        galleryView.y = 0;
                        viewFinderView.x = 0;
                        viewFinderView.y = Qt.binding(function() { return galleryView.height + viewSwitcher.panesMargin });
                        viewSwitcher.positionContentAtRatio(viewSwitcher.ratio)
                        viewSwitcher.ratio = Qt.binding(function() { return 0.5 - viewSwitcher.contentY / viewSwitcher.contentHeight });
                    }
                }
            }
        ]
        interactive: !viewFinderView.touchAcquired && !galleryView.touchAcquired && !viewFinderView.photoCaptureInProgress

        Component.onCompleted: {
            // FIXME: workaround for qtubuntu not returning values depending on the grid unit definition
            // for Flickable.maximumFlickVelocity and Flickable.flickDeceleration
            var scaleFactor = units.gridUnit / 8;
            maximumFlickVelocity = maximumFlickVelocity * scaleFactor;
            flickDeceleration = flickDeceleration * scaleFactor;
        }

        property bool settling: false
        property bool switching: false
        property real settleVelocity: units.dp(5000)

        function settle() {
            settling = true;
            var velocity;
            if (flickableDirection == Flickable.HorizontalFlick) {
                if (horizontalVelocity < 0 || visibleArea.xPosition <= 0.05 || (horizontalVelocity == 0 && visibleArea.xPosition <= 0.25)) {
                    // FIXME: compute velocity better to ensure it reaches rest position (maybe in a constant time)
                    velocity = settleVelocity;
                } else {
                    velocity = -settleVelocity;
                }
                flick(velocity, 0);
            } else {
                if (verticalVelocity < 0 || visibleArea.yPosition <= 0.05 || (verticalVelocity == 0 && visibleArea.yPosition <= 0.25)) {
                    // FIXME: compute velocity better to ensure it reaches rest position (maybe in a constant time)
                    velocity = settleVelocity;
                } else {
                    velocity = -settleVelocity;
                }
                flick(0, velocity);
            }
        }

        function switchToViewFinder() {
            cancelFlick();
            switching = true;
            if (state == "PORTRAIT") {
                flick(settleVelocity, 0);
            } else if (state == "LANDSCAPE") {
                flick(0, settleVelocity);
            } else if (state == "INVERTED_LANDSCAPE") {
                flick(0, -settleVelocity);
            }
        }

        function positionContentAtRatio(ratio) {
            if (state == "PORTRAIT") {
                viewSwitcher.contentX = ratio * viewSwitcher.contentWidth;
            } else if (state == "LANDSCAPE") {
                viewSwitcher.contentY = ratio * viewSwitcher.contentHeight;
            } else if (state == "INVERTED_LANDSCAPE") {
                viewSwitcher.contentY = (0.5 - ratio) * viewSwitcher.contentHeight;
            }
        }

        onContentWidthChanged: positionContentAtRatio(viewSwitcher.ratio)
        onContentHeightChanged: positionContentAtRatio(viewSwitcher.ratio)

        onMovementEnded: {
            // go to a rest position as soon as user stops interacting with the Flickable
            settle();
        }

        onFlickStarted: {
            // cancel user triggered flicks
            if (!settling && !switching) {
                cancelFlick();
            }
        }

        onFlickingHorizontallyChanged: {
            // use flickingHorizontallyChanged instead of flickEnded because flickEnded
            // is not called when a flick is interrupted by the user
            if (!flickingHorizontally) {
                if (settling) {
                    settling = false;
                }
                if (switching) {
                    switching = true;
                }
            }
        }

        onHorizontalVelocityChanged: {
            // FIXME: this is a workaround for the lack of notification when
            // the user manually interrupts a flick by pressing and releasing
            if (horizontalVelocity == 0 && !atXBeginning && !atXEnd && !settling && !moving) {
                settle();
            }
        }

        onFlickingVerticallyChanged: {
            // use flickingHorizontallyChanged instead of flickEnded because flickEnded
            // is not called when a flick is interrupted by the user
            if (!flickingVertically) {
                if (settling) {
                    settling = false;
                }
                if (switching) {
                    switching = true;
                }
            }
        }

        onVerticalVelocityChanged: {
            // FIXME: this is a workaround for the lack of notification when
            // the user manually interrupts a flick by pressing and releasing
            if (verticalVelocity == 0 && !atYBeginning && !atYEnd && !settling && !moving) {
                settle();
            }
        }

        ViewFinderView {
            id: viewFinderView
            width: viewSwitcher.width
            height: viewSwitcher.height
            overlayVisible: !viewSwitcher.moving && !viewSwitcher.flicking
            inView: viewSwitcher.ratio < 0.5
            opacity: inView ? 1.0 : 0.0
            onPhotoTaken: {
                galleryView.prependMediaToModel(filePath);
                galleryView.showLastPhotoTaken();
            }
            onVideoShot: {
                galleryView.prependMediaToModel(filePath);
                galleryView.showLastPhotoTaken();
                galleryView.precacheThumbnail(filePath);
            }
        }

        GalleryViewLoader {
            id: galleryView
            width: viewSwitcher.width
            height: viewSwitcher.height
            inView: viewSwitcher.ratio > 0.0
            onExit: viewSwitcher.switchToViewFinder()
            opacity: inView ? 1.0 : 0.0
        }
    }

    property bool contentExportMode: transfer !== null
    property var transfer: null
    property var transferContentType: ContentType.Pictures

    function exportContent(urls) {
        if (!main.transfer) return;

        var item;
        var items = [];
        for (var i=0; i<urls.length; i++) {
            item = contentItemComponent.createObject(main.transfer, {"url": urls[i]});
            items.push(item);
        }
        main.transfer.items = items;
        main.transfer.state = ContentTransfer.Charged;
        main.transfer = null;
    }

    function cancelExport() {
        main.transfer.state = ContentTransfer.Aborted;
        main.transfer = null;
    }

    Component {
        id: contentItemComponent
        ContentItem {
        }
    }

    Connections {
        target: ContentHub
        onExportRequested: {
            viewSwitcher.switchToViewFinder();

            // The exportRequested event can arrive before or after the
            // app is active, but setting the recording type before the
            // capture becomes ready does not have any effect.
            // See camera.imageCapture.onReadyChanged for the other case.
            if (viewFinderView.camera.imageCapture.ready) {
                if (transfer.contentType === ContentType.Videos) {
                    viewFinderView.captureMode = Camera.CaptureVideo;
                } else {
                    viewFinderView.captureMode = Camera.CaptureStillImage;
                }
            }
            main.transfer = transfer;
        }
    }

    Metric {
        id: metricPhotos
        name: "camera-photos"
        // Mark text for translation at a later point.
        // It will be translated by dtr (or dgettext) to allows plural forms
        format: i18n.tag("<b>%1</b> photos taken today")
        emptyFormat: i18n.tag("No photos taken today")
        domain: "camera-app"
        minimum: 0.0
    }

    Metric {
        id: metricVideos
        name: "camera-videos"
        // Mark text for translation at a later point.
        // It will be translated by dtr (or dgettext) to allows plural forms
        format: i18n.tag("<b>%1</b> videos recorded today")
        emptyFormat: i18n.tag("No videos recorded today")
        domain: "camera-app"
        minimum: 0.0
    }
}
