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
import QtQuick.Window 2.0
import Ubuntu.Components 1.0
import Ubuntu.Unity.Action 1.1 as UnityActions
import UserMetrics 0.1

Item {
    id: main
    objectName: "main"
    width: units.gu(40)
    height: units.gu(71)
//    width: application.desktopMode ? units.gu(120) : (Screen.primaryOrientation === Qt.PortraitOrientation ? units.gu(40) : units.gu(80))
//    height: application.desktopMode ? units.gu(60) : (Screen.primaryOrientation === Qt.PortraitOrientation ? units.gu(80) : units.gu(40))

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
    }


    Flickable {
        id: viewSwitcher
        anchors.fill: parent
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: contentItem.childrenRect.width
        contentHeight: contentItem.childrenRect.height
        interactive: !viewFinderView.touchAcquired

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
            if (horizontalVelocity < 0 || (horizontalVelocity == 0 && visibleArea.xPosition <= 0.25)) {
                // FIXME: compute velocity better to ensure it reaches rest position (maybe in a constant time)
                velocity = settleVelocity;
            } else {
                velocity = -settleVelocity;
            }

            flick(velocity, 0);
        }

        function switchToViewFinder() {
            cancelFlick();
            switching = true;
            flick(settleVelocity, 0);
        }

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

        Row {
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            spacing: units.gu(1)

            ViewFinderView {
                id: viewFinderView
                width: viewSwitcher.width
                height: viewSwitcher.height
                overlayVisible: !viewSwitcher.moving && !viewSwitcher.flicking
                inView: !viewSwitcher.atXEnd
                onPhotoTaken: galleryView.showLastPhotoTaken();
                onVideoShot: galleryView.showLastPhotoTaken();
            }

            GalleryView {
                id: galleryView
                width: viewSwitcher.width
                height: viewSwitcher.height
                inView: !viewSwitcher.atXBeginning
                onExit: viewSwitcher.switchToViewFinder()
            }
        }
    }


    Metric {
        id: metricPhotos
        name: "camera-photos"
        format: i18n.tr("<b>%1</b> photos taken today")
        emptyFormat: i18n.tr("No photos taken today")
        domain: "camera-app"
        minimum: 0.0
    }

    Metric {
        id: metricVideos
        name: "camera-videos"
        format: i18n.tr("<b>%1</b> videos recorded today")
        emptyFormat: i18n.tr("No videos recorded today")
        domain: "camera-app"
        minimum: 0.0
    }
}
