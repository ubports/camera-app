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
import Ubuntu.Unity.Action 1.0 as UnityActions
import QtMultimedia 5.0
import CameraApp 0.1
import QtQuick.Window 2.0
import UserMetrics 0.1

Rectangle {
    id: main
    objectName: "main"
    width: application.desktopMode ? units.gu(120) : (device.naturalOrientation == "portrait" ? units.gu(40) : units.gu(80))
    height: application.desktopMode ? units.gu(60) : (device.naturalOrientation == "portrait" ? units.gu(80) : units.gu(40))
    color: "#252423"

    UnityActions.ActionManager {
        actions: [
            UnityActions.Action {
                text: i18n.tr("Flash")
                keywords: i18n.tr("Light;Dark")
                onTriggered: toolbar.switchFlashMode()
            },
            UnityActions.Action {
                text: i18n.tr("Flip Camera")
                keywords: i18n.tr("Front Facing;Back Facing")
                onTriggered: toolbar.switchCamera()
            },
            UnityActions.Action {
                text: i18n.tr("Shutter")
                keywords: i18n.tr("Take a Photo;Snap;Record")
                onTriggered: toolbar.shoot()
            },
            UnityActions.Action {
                text: i18n.tr("Mode")
                keywords: i18n.tr("Stills;Video")
                onTriggered: toolbar.changeRecordMode()
                enabled: false
            },
            UnityActions.Action {
                text: i18n.tr("White Balance")
                keywords: i18n.tr("Lighting Condition;Day;Cloudy;Inside")
            }
        ]
    }

    Component.onCompleted: {
        i18n.domain = "camera-app";
        camera.start();
    }

    DeviceOrientation {
        id: device
    }

    Camera {
        id: camera
        flash.mode: Camera.FlashOff
        captureMode: Camera.CaptureStillImage
        focus.focusMode: Camera.FocusAuto //TODO: Not sure if Continuous focus is better here
        focus.focusPointMode: application.desktopMode ? Camera.FocusPointAuto : (focusRing.opacity > 0 ? Camera.FocusPointCustom : Camera.FocusPointAuto)

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
                metricPhotos.increment()
                console.log("Picture saved as " + path)
            }
        }

        videoRecorder {
            onRecorderStateChanged: {
                if (videoRecorder.recorderState === CameraRecorder.StoppedState)
                    metricVideos.increment()
            }

        }
    }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active)
                camera.start()
            else if (!application.desktopMode)
                camera.stop()
        }
    }

    VideoOutput {
        id: viewFinder

        property bool shouldBeCentered: device.isLandscape ||
                                        ((viewFinder.width > viewFinderGeometry.width) &&
                                         device.naturalOrientation === "portrait")
        property real anchoredY: viewFinderGeometry.y * (device.isInverted ? +1 : -1)
        property real anchoredX: viewFinderGeometry.x * (device.isInverted ? +1 : -1)

        x: viewFinder.shouldBeCentered ? 0 : viewFinder.anchoredX
        y: viewFinder.shouldBeCentered || device.naturalOrientation === "landscape" ?
           0 : viewFinder.anchoredY
        width: parent.width
        height: parent.height
        source: camera

        /* This rotation need to be applied since the camera hardware in the
           Galaxy Nexus phone is mounted at an angle inside the device, so the video
           feed is rotated too.
           FIXME: This should come from a system configuration option so that we
           don't have to have a different codebase for each different device we want
           to run on */
        orientation: device.naturalOrientation === "portrait"  ? -90 : 0

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

            Item {
                id: itemScale
                visible: false
            }

            PinchArea {
                id: area

                state: device.isLandscape ? "split" : "joined"
                anchors.left: viewFinderGeometry.left
                anchors.right: viewFinderGeometry.right

                pinch.minimumScale: 0.0
                pinch.maximumScale: camera.maximumZoom
                pinch.target: itemScale

                states: [
                    State {
                        name: "joined"
                        PropertyChanges {
                            target: area
                            height: zoomControl.y
                        }
                        AnchorChanges {
                            target: area;
                            anchors.top: viewFinderGeometry.top
                        }
                    },
                    State {
                        name: "split"
                        PropertyChanges {
                            target: area
                            y: device.isInverted ?  zoomControl.height : toolbar.height
                            height: viewFinderGeometry.height - zoomControl.height - toolbar.height
                        }
                        AnchorChanges {
                            target: area;
                            anchors.top: undefined
                        }
                    }
                ]

                onPinchStarted: {
                    if (!application.desktopMode)
                        focusRing.center = main.mapFromItem(area, pinch.center.x, pinch.center.y);
                }

                onPinchFinished: {
                    if (!application.desktopMode) {
                        focusRing.restartTimeout()
                        var center = pinch.center
                        var focusPoint = viewFinder.mapPointToSourceNormalized(pinch.center);
                        camera.focus.customFocusPoint = focusPoint;
                    }
                }

                onPinchUpdated: {
                    if (!application.desktopMode) {
                        focusRing.center = main.mapFromItem(area, pinch.center.x, pinch.center.y);
                        camera.currentZoom = itemScale.scale
                    }
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent

                    onPressed: {
                        if (!application.desktopMode && !area.pinch.active)
                            focusRing.center = main.mapFromItem(area, mouse.x, mouse.y);
                    }

                    onReleased:  {
                        if (!application.desktopMode && !area.pinch.active) {
                            var focusPoint = viewFinder.mapPointToSourceNormalized(Qt.point(mouse.x, mouse.y))

                            focusRing.restartTimeout()
                            camera.focus.customFocusPoint = focusPoint;
                        }
                    }

                    drag {
                        target: application.desktopMode ? "" : focusRing
                        minimumY: area.y - focusRing.height / 2
                        maximumY: area.y + area.height - focusRing.height / 2
                        minimumX: area.x - focusRing.width / 2
                        maximumX: area.x + area.width - focusRing.width / 2
                    }

                }
            }

            Snapshot {
                id: snapshot
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height
                y: 0
                orientation: viewFinder.orientation
                geometry: viewFinderGeometry
                deviceDefaultIsPortrait: device.naturalOrientation === "portrait"
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

        state: device.isLandscape ? "split" : "joined"
        states: [
            State { name: "joined"
                AnchorChanges { target: zoomControl; anchors.bottom: toolbar.top }
                AnchorChanges {
                    target: stopWatch
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            },
            State { name: "split"
                AnchorChanges { target: zoomControl; anchors.top: parent.top }
                AnchorChanges {
                    target: stopWatch
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        ]

        ZoomControl {
            id: zoomControl
            maximumValue: camera.maximumZoom
            height: units.gu(4.5)

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: units.gu(0.75)
            anchors.rightMargin: units.gu(0.75)
            anchors.bottomMargin: controlsArea.state == "split" ? units.gu(3.25) : units.gu(0.5)
            anchors.topMargin: controlsArea.state == "split" ? units.gu(3.25) : units.gu(0.5)

            visible: camera.maximumZoom > 1

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

        StopWatch {
            id: stopWatch
            opacity: camera.videoRecorder.recorderState == CameraRecorder.StoppedState ? 0.0 : 1.0
            time: camera.videoRecorder.duration / 1000
            labelRotation: device.rotationAngle - controlsArea.rotation
            anchors.topMargin: units.gu(2)
            anchors.rightMargin: units.gu(2)
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
