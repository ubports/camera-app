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
import Ubuntu.Components 1.1
import QtMultimedia 5.0
import CameraApp 0.1
import QtGraphicalEffects 1.0

Item {
    id: viewFinderView

    property bool overlayVisible: true
    property bool optionValueSelectorVisible: false
    property bool touchAcquired: viewFinderOverlay.touchAcquired || camera.videoRecorder.recorderState == CameraRecorder.RecordingState
    property bool inView
    property alias captureMode: camera.captureMode
    signal photoTaken
    signal videoShot

    Camera {
        id: camera
        captureMode: Camera.CaptureStillImage
        StateSaver.properties: "captureMode"

        function manualFocus(x, y) {
            viewFinderOverlay.showFocusRing(x, y);
            autoFocusTimer.restart();
            focus.focusMode = Camera.FocusAuto;
            focus.customFocusPoint = viewFinder.mapPointToSourceNormalized(Qt.point(x, y));
            focus.focusPointMode = Camera.FocusPointCustom;
        }

        function autoFocus() {
            focus.focusMode = Camera.FocusContinuous;
            focus.focusPointMode = Camera.FocusPointAuto;
        }

        property var autoFocusTimer: Timer {
            interval: 5000
            onTriggered: camera.autoFocus();
        }

        focus {
            focusMode: Camera.FocusContinuous
            focusPointMode: Camera.FocusPointAuto
        }

        property AdvancedCameraSettings advanced: AdvancedCameraSettings {
            id: advancedCamera
            camera: camera
            StateSaver.properties: "activeCameraIndex"
        }

        Component.onCompleted: {
            camera.start();
        }
        
        /* Use only digital zoom for now as it's what phone cameras mostly use.
               TODO: if optical zoom is available, maximumZoom should be the combined
               range of optical and digital zoom and currentZoom should adjust the two
               transparently based on the value. */
        property alias currentZoom: camera.digitalZoom
        property alias maximumZoom: camera.maximumDigitalZoom
        property bool switchInProgress: false
        
        imageCapture {
            onCaptureFailed: {
                console.log("Capture failed for request " + requestId + ": " + message);
            }
            onImageCaptured: {
                snapshot.source = preview;
            }
            onImageSaved: {
                if (main.contentExportMode) {
                    viewFinderExportConfirmation.confirmExport(path);
                } else {
                    viewFinderOverlay.visible = true;
                    snapshot.startOutAnimation();
                    if (photoRollHint.necessary) {
                        photoRollHint.enable();
                    }
                }
                viewFinderView.photoTaken();
                metricPhotos.increment();
                console.log("Picture saved as " + path);
            }
        }
        
        videoRecorder {
            onRecorderStateChanged: {
                if (videoRecorder.recorderState === CameraRecorder.StoppedState) {
                    if (photoRollHint.necessary) {
                        photoRollHint.enable();
                    }
                    metricVideos.increment()
                    viewFinderOverlay.visible = true;
                    viewFinderView.videoShot();
                }
            }
        }
    }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active) {
                camera.start()
            } else if (!application.desktopMode) {
                if (camera.videoRecorder.recorderState == CameraRecorder.RecordingState) {
                    camera.videoRecorder.stop();
                }
                camera.stop()
            }
        }
    }

    Item {
        id: viewFinderSwitcher
        anchors.fill: parent
        
        ShaderEffectSource {
            id: viewFinderGrab
            live: false
            sourceItem: viewFinder

            onScheduledUpdateCompleted: {
                if (camera.switchInProgress) {
                    // FIXME: hack to make viewFinder invisible
                    // 'viewFinder.visible = false' prevents the camera switching
                    viewFinder.width = 1;
                    viewFinder.height = 1;
                    camera.advanced.activeCameraIndex = (camera.advanced.activeCameraIndex === 0) ? 1 : 0;
                    viewFinderSwitcherRotation.angle = 180;
                }
            }
            transform: Rotation {
                origin.x: viewFinderGrab.width/2
                origin.y: viewFinderGrab.height/2
                axis.x: 0; axis.y: 1; axis.z: 0
                angle: 180
            }
        }
        
        transform: [
            Scale {
                id: viewFinderSwitcherScale
                origin.x: viewFinderSwitcher.width/2
                origin.y: viewFinderSwitcher.height/2
                xScale: 1
                yScale: xScale
            },
            Rotation {
                id: viewFinderSwitcherRotation
                origin.x: viewFinderSwitcher.width/2
                origin.y: viewFinderSwitcher.height/2
                axis.x: 0; axis.y: 1; axis.z: 0
                angle: 0
            }
        ]
        
        
        SequentialAnimation {
            id: viewFinderSwitcherAnimation
            
            SequentialAnimation {
                ParallelAnimation {
                    UbuntuNumberAnimation {target: viewFinderSwitcherScale; property: "xScale"; from: 1.0; to: 0.8; duration: UbuntuAnimation.BriskDuration ; easing: UbuntuAnimation.StandardEasing}
                    UbuntuNumberAnimation {
                        target: viewFinderSwitcherRotation
                        property: "angle"
                        from: 180
                        to: 90
                        duration: UbuntuAnimation.BriskDuration
                        easing: UbuntuAnimation.StandardEasing
                    }
                }
                PropertyAction { target: viewFinder; property: "width"; value: viewFinderSwitcher.width}
                PropertyAction { target: viewFinder; property: "height"; value: viewFinderSwitcher.height}
                PropertyAction { target: viewFinderGrab; property: "visible"; value: false }
                ParallelAnimation {
                    UbuntuNumberAnimation {target: viewFinderSwitcherScale; property: "xScale"; from: 0.8; to: 1.0; duration: UbuntuAnimation.BriskDuration; easing: UbuntuAnimation.StandardEasingReverse}
                    UbuntuNumberAnimation {
                        target: viewFinderSwitcherRotation
                        property: "angle"
                        from: 90
                        to: 0
                        duration: UbuntuAnimation.BriskDuration
                        easing: UbuntuAnimation.StandardEasingReverse
                    }
                }
            }
        }
        
        VideoOutput {
            id: viewFinder
            
            x: 0
            y: -viewFinderGeometry.y
            width: parent.width
            height: parent.height
            source: camera
            
            /* This rotation need to be applied since the camera hardware in the
                   Galaxy Nexus phone is mounted at an angle inside the device, so the video
                   feed is rotated too.
                   FIXME: This should come from a system configuration option so that we
                   don't have to have a different codebase for each different device we want
                   to run on */
            orientation: Screen.primaryOrientation === Qt.PortraitOrientation  ? -90 : 0
            
            /* Convenience item tracking the real position and size of the real video feed.
                   Having this helps since these values depend on a lot of rules:
                   - the feed is automatically scaled to fit the viewfinder
                   - the viewfinder might apply a rotation to the feed, depending on device orientation
                   - the resolution and aspect ratio of the feed changes depending on the active camera
                   The item is also separated in a component so it can be unit tested.
                 */
            
            transform: Rotation {
                origin.x: viewFinder.width / 2
                origin.y: viewFinder.height / 2
                axis.x: 0; axis.y: 1; axis.z: 0
                angle: application.desktopMode ? 180 : 0
            }

            ViewFinderGeometry {
                id: viewFinderGeometry
                anchors.centerIn: parent

                cameraResolution: camera.advanced.resolution
                viewFinderHeight: viewFinder.height
                viewFinderWidth: viewFinder.width
                viewFinderOrientation: viewFinder.orientation
            }
        }

        Item {
            id: timedShootFeedback
            anchors.fill: parent

            function start() {
                viewFinderOverlay.visible = false;
            }

            function showRemainingSecs(secs) {
                remainingSecsLabel.text = secs;
                remainingSecsLabel.opacity = 1.0;
                remainingSecsLabelAnimation.restart();
            }

            Label {
                id: remainingSecsLabel
                anchors.fill: parent
                font.pixelSize: units.gu(6)
                font.bold: true
                color: "white"
                style: Text.Outline;
                styleColor: "black"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                visible: opacity != 0.0
                opacity: 0.0

                OpacityAnimator {
                    id: remainingSecsLabelAnimation
                    target: remainingSecsLabel
                    from: 1.0
                    to: 0.0
                    duration: 750
                    easing: UbuntuAnimation.StandardEasing
                }
            }
        }

        Rectangle {
            id: shootFeedback
            anchors.fill: parent
            color: "white"
            visible: opacity != 0.0
            opacity: 0.0

            function start() {
                shootFeedback.opacity = 1.0;
                viewFinderOverlay.visible = false;
                shootFeedbackAnimation.restart();
            }

            OpacityAnimator {
                id: shootFeedbackAnimation
                target: shootFeedback
                from: 1.0
                to: 0.0
                duration: 50
                easing: UbuntuAnimation.StandardEasing
            }
        }
    }

    FastBlur {
        anchors.fill: viewFinderSwitcher
        radius: photoRollHint.visible ? 64 : viewFinderOverlay.revealProgress * 64
        source: radius !== 0 ? viewFinderSwitcher : null
        visible: radius !== 0
    }

    ViewFinderOverlayLoader {
        id: viewFinderOverlay

        anchors.fill: parent
        camera: camera
        opacity: status == Loader.Ready && overlayVisible && !photoRollHint.enabled ? 1.0 : 0.0
        Behavior on opacity {UbuntuNumberAnimation {duration: UbuntuAnimation.SnapDuration}}
    }

    PhotoRollHint {
        id: photoRollHint
        anchors.fill: parent
        visible: enabled && !snapshot.loading

        Connections {
            target: viewFinderView
            onInViewChanged: if (!viewFinderView.inView) photoRollHint.disable()
        }
    }

    Snapshot {
        id: snapshot
        anchors.fill: parent
        orientation: viewFinder.orientation
        geometry: viewFinderGeometry
        deviceDefaultIsPortrait: Screen.primaryOrientation === Qt.PortraitOrientation
    }

    ViewFinderExportConfirmation {
        id: viewFinderExportConfirmation
        anchors.fill: parent
        snapshot: snapshot
    }
}
