/*
 * Copyright 2012 Canonical Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.HUD 0.1 as HUD
import QtMultimedia 5.0
import CameraApp 0.1
import QtSensors 5.0

Rectangle {
    id: main
    width: units.gu(40)
    height: units.gu(80)
    color: "#252423"

    HUD.HUD {
        applicationIdentifier: "camera-app"
        HUD.Context {
            toolbar.quitAction.onTriggered: Qt.quit()
        }
    }

    Component.onCompleted: camera.start();

    OrientationHelper {
        id: device
        root: main
    }

    Camera {
        id: camera
        flash.mode: Camera.FlashOff
        captureMode: Camera.CaptureStillImage
        focus.focusMode: Camera.FocusAuto //TODO: Not sure if Continuous focus is better here
        focus.focusPointMode: focusRing.opacity > 0 ? Camera.FocusPointCustom : Camera.FocusPointAuto

        property AdvancedCameraSettings advanced: AdvancedCameraSettings {
            camera: camera
        }

        /* Use only digital zoom for now as it's what phone cameras mostly use.
           TODO: if optical zoom is available, maximumZoom should be the combined
           range of optical and digital zoom and currentZoom should adjust the two
           transparently based on the value. */
        property alias currentZoom: camera.digitalZoom
        property alias maximumZoom: camera.maximumDigitalZoom

        imageCapture {
            onCaptureFailed: {
                console.log("Capture failed for request " + requestId + ": " + message);
                focusRing.opacity = 0.0;
            }
            onImageCaptured: {
                focusRing.opacity = 0.0;
                snapshot.source = preview;
            }
            onImageSaved: {
                console.log("Picture saved as " + path)
            }
        }
    }

    Connections {
        target: Qt.application
        onActiveChanged: (Qt.application.active) ? camera.start() : camera.stop()
    }

    VideoOutput {
        id: viewFinder
        x: 0
        y: viewFinderGeometry.y * -1
        width: parent.width
        height: parent.height
        source: camera

        /* This rotation need to be applied since the camera hardware in the
           Galaxy Nexus phone is mounted at an angle inside the device, so the video
           feed is rotated too.
           FIXME: This should come from a system configuration option so that we
           don't have to have a different codebase for each different device we want
           to run on */
        orientation: -90

        StopWatch {
            anchors.top: parent.top
            anchors.left: parent.left
            color: "red"
            opacity: camera.videoRecorder.recorderState == CameraRecorder.StoppedState ? 0.0 : 1.0
            time: camera.videoRecorder.duration / 1000
        }

        /* Convenience item tracking the real position and size of the real video feed.
           Having this helps since these values depend on a lot of rules:
           - the feed is automatically scaled to fit the viewfinder
           - the viewfinder might apply a rotation to the feed, depending on device orientation
           - the resolution and aspect ratio of the feed changes depending on the active camera
           The item is also separated in a component so it can be unit tested.
         */
        ViewFinderGeometry {
            id: viewFinderGeometry
            anchors.centerIn: parent

            cameraResolution: camera.advanced.resolution
            viewFinderHeight: viewFinder.height
            viewFinderWidth: viewFinder.width
            viewFinderOrientation: viewFinder.orientation

            MouseArea {
                id: area
                anchors.top: viewFinderGeometry.top
                anchors.left: viewFinderGeometry.left
                anchors.right: viewFinderGeometry.right
                height: Math.min(zoomControl.y, viewFinderGeometry.height)

                onPressed: {
                    var mousePosition = main.mapFromItem(area, mouse.x, mouse.y);
                    focusRing.x = mousePosition.x - focusRing.width * 0.5;
                    focusRing.y = mousePosition.y - focusRing.height * 0.5;
                    focusRing.opacity = 1.0;
                }

                onReleased: {
                    focusRingTimeout.restart()
                    var focusPoint = viewFinder.mapPointToSourceNormalized(Qt.point(mouse.x, mouse.y));
                    camera.focus.customFocusPoint = focusPoint;
                }

                drag {
                    target: focusRing
                    minimumY: area.y - focusRing.height / 2
                    maximumY: area.y + area.height - focusRing.height / 2
                    minimumX: area.x - focusRing.width / 2
                    maximumX: area.x + area.width - focusRing.width / 2
                }

                Timer {
                    id: focusRingTimeout
                    interval: 2000
                    onTriggered: focusRing.opacity = 0.0
                }
            }

            Snapshot {
                id: snapshot
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height
                y: 0
                orientation: viewFinder.orientation
            }
        }
    }

    FocusRing {
        id: focusRing
        height: units.gu(13)
        width: units.gu(13)
        opacity: 0.0
    }

    Item {
        id: controlsArea
        anchors.centerIn: parent

        height: (device.naturalOrientation == "portrait") ? parent.height : parent.width
        width: (device.naturalOrientation == "portrait") ? parent.width : parent.height

        rotation: device.naturalOrientation == "landscape" ?
                      ((device.isInverted) ? 90 : -90) :
                      (!device.isLandscape ? (device.isInverted ? 180 : 0) :
                                             (device.isInverted ? 0 : 180))

        ZoomControl {
            id: zoomControl
            maximumValue: camera.maximumZoom
            height: units.gu(4.5)

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: units.gu(0.75)
            anchors.rightMargin: units.gu(0.75)
            anchors.bottomMargin: units.gu(0.5)
            anchors.topMargin: units.gu(0.5)

            state: device.isLandscape ? "split" : "joined"
            states: [
                State { name: "joined"
                    AnchorChanges { target: zoomControl; anchors.bottom: toolbar.top }
                },
                State { name: "split"
                    AnchorChanges { target: zoomControl; anchors.top: parent.top }
                }
            ]

            // Create a two way binding between the zoom control value and the actual camera zoom,
            // so that they can stay in sync when the zoom is changed from the UI or from the hardware
            Binding { target: zoomControl; property: "value"; value: camera.currentZoom }
            Binding { target: camera; property: "currentZoom"; value: zoomControl.value }

            iconsRotation: device.rotationAngle - controlsArea.rotation
        }

        Toolbar {
            id: toolbar

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: units.gu(1)
            anchors.leftMargin: units.gu(1)
            anchors.rightMargin: units.gu(1)

            camera: camera
            canCapture: camera.imageCapture.ready && !snapshot.sliding
            iconsRotation: device.rotationAngle - controlsArea.rotation
        }
    }
}
