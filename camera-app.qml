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
import Ubuntu.Unity.Action 1.1 as UnityActions
import UserMetrics 0.1
import Qt.labs.folderlistmodel 2.1

Rectangle {
    id: main
    objectName: "main"
    width: units.gu(40)
    height: units.gu(71)
//    width: application.desktopMode ? units.gu(120) : (device.naturalOrientation == "portrait" ? units.gu(40) : units.gu(80))
//    height: application.desktopMode ? units.gu(60) : (device.naturalOrientation == "portrait" ? units.gu(80) : units.gu(40))
    color: "black"

    UnityActions.ActionManager {
        actions: [
//            UnityActions.Action {
//                text: i18n.tr("Flash")
//                keywords: i18n.tr("Light;Dark")
//                onTriggered: toolbar.switchFlashMode()
//            },
//            UnityActions.Action {
//                text: i18n.tr("Flip Camera")
//                keywords: i18n.tr("Front Facing;Back Facing")
//                onTriggered: toolbar.switchCamera()
//            },
//            UnityActions.Action {
//                text: i18n.tr("Shutter")
//                keywords: i18n.tr("Take a Photo;Snap;Record")
//                onTriggered: toolbar.shoot()
//            },
//            UnityActions.Action {
//                text: i18n.tr("Mode")
//                keywords: i18n.tr("Stills;Video")
//                onTriggered: toolbar.changeRecordMode()
//                enabled: false
//            },
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
//        onAtXEndChanged: print("ATXEND", atXEnd)
//        onAtXBeginningChanged: print("ATXBEGINNING", atXBeginning)

        property bool settling: false

        function settle() {
            settling = true;
            var velocity;
            if (horizontalVelocity < 0 || (horizontalVelocity == 0 && visibleArea.xPosition <= 0.25)) {
                // FIXME: compute velocity better to ensure it reaches rest position (maybe in a constant time)
                velocity = units.dp(5000);
            } else {
                velocity = -units.dp(5000);
            }

            flick(velocity, 0);
        }

        onMovementEnded: {
            // go to a rest position as soon as user stops interacting with the Flickable
            settle();
        }

        onFlickStarted: {
            // cancel user triggered flicks
            if (!settling) {
                cancelFlick();
            }
        }

        onFlickingHorizontallyChanged: {
            // use flickingHorizontallyChanged instead of flickEnded because flickEnded
            // is not called when a flick is interrupted by the user
            if (!flickingHorizontally && settling) {
                settling = false;
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
//            width: viewFinder View.width + galleryView.width
            spacing: units.gu(1)

            ViewFinderView {
                id: viewFinderView
                width: viewSwitcher.width
                height: viewSwitcher.height
                overlayVisible: !viewSwitcher.moving && !viewSwitcher.flicking
//                visible: !viewSwitcher.atXEnd
            }

            GalleryView {
                id: galleryView
                width: viewSwitcher.width
                height: viewSwitcher.height
//                visible: !viewSwitcher.atXBeginning

            }
        }
    }


    Metric {
        id: metricPhotos
        name: "camera-photos"
        format: "<b>%1</b> photos taken today"
        emptyFormat: "No photos taken today"
        domain: "camera-app"
        minimum: 0.0
    }

    Metric {
        id: metricVideos
        name: "camera-videos"
        format: "<b>%1</b> videos recorded today"
        emptyFormat: "No videos recorded today"
        domain: "camera-app"
        minimum: 0.0
    }
}
