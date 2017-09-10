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
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtMultimedia 5.0
import CameraApp 0.1
import QtGraphicalEffects 1.0
import Ubuntu.Content 1.3

FocusScope {
    id: viewFinderView

    property bool overlayVisible: true
    property bool optionValueSelectorVisible: false
    property bool touchAcquired: viewFinderOverlay.touchAcquired || camera.videoRecorder.recorderState == CameraRecorder.RecordingState
    property bool inView
    property alias captureMode: camera.captureMode
    property real aspectRatio: viewFinder.sourceRect.height != 0 ? viewFinder.sourceRect.width / viewFinder.sourceRect.height : 1.0
    signal photoTaken(string filePath)
    signal videoShot(string filePath)

    Connections {
        target: viewFinderOverlay
        onStatusChanged: decideCameraState()
    }
    Connections {
        target: Qt.application
        onActiveChanged: if (Qt.application.active && camera.failedToConnect) decideCameraState()
    }

    function decideCameraState() {
        if (viewFinderOverlay.status == Loader.Ready) {
            camera.cameraState = Camera.LoadedState;
            viewFinderOverlay.updateResolutionOptions();
            camera.cameraState = Camera.ActiveState;
        }
    }

    property Camera camera: Camera {
        id: camera
        captureMode: Camera.CaptureStillImage
        cameraState: Camera.UnloadedState
        StateSaver.properties: "captureMode, position"
        property bool failedToConnect: false

        function manualFocus(x, y) {
            var normalizedPoint = viewFinder.mapPointToSourceNormalized(Qt.point(x, y - viewFinder.y));
            if (normalizedPoint.x >= 0.0 && normalizedPoint.x <= 1.0 &&
                normalizedPoint.y >= 0.0 && normalizedPoint.y <= 1.0) {
                viewFinderOverlay.showFocusRing(x, y);
                autoFocusTimer.restart();
                focus.focusMode = Camera.FocusAuto;
                focus.customFocusPoint = normalizedPoint;
                focus.focusPointMode = Camera.FocusPointCustom;
            }
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
        }

        /* Use only digital zoom for now as it's what phone cameras mostly use.
               TODO: if optical zoom is available, maximumZoom should be the combined
               range of optical and digital zoom and currentZoom should adjust the two
               transparently based on the value. */
        property alias currentZoom: camera.digitalZoom
        property alias maximumZoom: camera.maximumDigitalZoom
        property bool switchInProgress: false
        property bool photoCaptureInProgress: false
        property bool timedCaptureInProgress: false

        onPhotoCaptureInProgressChanged: {
            if (main.contentExportMode && camera.photoCaptureInProgress) {
                viewFinderExportConfirmation.photoCaptureStarted();
            }
        }

        imageCapture {
            onImageCaptured: {
                if (camera.photoCaptureInProgress) {
                    if (photoRollHint.necessary && !main.transfer) photoRollHint.enable();
                    camera.photoCaptureInProgress = false;
                }
            }

            onCaptureFailed: {
                console.log("Image capture failed for request " + requestId + ": " + message);
                camera.photoCaptureInProgress = false;
                viewFinderOverlay.visible = true;
                PopupUtils.open(captureFailedDialogComponent);
            }

            onImageSaved: {
                if (main.contentExportMode) viewFinderExportConfirmation.mediaPath = path;

                viewFinderView.photoTaken(path);
                metricPhotos.increment();
                console.log("Picture saved as " + path);
            }
        }

        videoRecorder {
            onRecorderStateChanged: {
                if (videoRecorder.recorderState === CameraRecorder.StoppedState) {
                    metricVideos.increment()
                    viewFinderView.videoShot(videoRecorder.actualLocation);
                    if (main.contentExportMode) {
                        viewFinderExportConfirmation.mediaPath = videoRecorder.actualLocation
                    } else if (photoRollHint.necessary) {
                        photoRollHint.enable();
                    }
                }
            }
            onErrorCodeChanged: {
                if (videoRecorder.errorCode !== CameraRecorder.NoError) {
                    PopupUtils.open(captureFailedDialogComponent);
                }
            }
        }
    }

    Item {
        id: viewFinderSwitcher
        anchors.fill: parent
        visible: !viewFinderSwitcherBlurred.visible

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
                    camera.cameraState = Camera.LoadedState;
                    camera.position = (camera.position === Camera.FrontFace) ? Camera.BackFace : Camera.FrontFace;
                    decideCameraState();
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
                ScriptAction {
                    script: {
                        viewFinder.width = Qt.binding(function () {return viewFinderSwitcher.width;});
                        viewFinder.height = Qt.binding(function () {return viewFinderSwitcher.height;});
                    }
                }
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
            opacity: ((main.contentExportMode && viewFinderExportConfirmation.waitingForPictureCapture) ||
                      (!main.contentExportMode && camera.photoCaptureInProgress && !camera.imageCapture.ready))
                      ? 0.1 : 1.0

            /* This rotation need to be applied since the camera hardware in the
               Galaxy Nexus phone is mounted at an angle inside the device, so the video
               feed is rotated too.
               FIXME: This should come from a system configuration option so that we
               don't have to have a different codebase for each different device we want
               to run on. Android has that information and QML has an API to reflect it:
               the camera.orientation property. Unfortunately it is not hooked up yet.

               Ref.: http://doc.qt.io/qt-5/qml-qtmultimedia-camera.html#orientation-prop
                     http://doc.qt.io/qt-5/qcamerainfocontrol.html#cameraOrientation
                     http://developer.android.com/reference/android/hardware/Camera.CameraInfo.html#orientation
            */
            Component.onCompleted: {
                // Set orientation only at startup because later on Screen.primaryOrientation
                // may change.
                orientation = Screen.primaryOrientation === Qt.PortraitOrientation  ? -90 : 0;
                viewFinderOverlay.sensorOrientation = orientation;
            }

            transform: Rotation {
                origin.x: viewFinder.width / 2
                origin.y: viewFinder.height / 2
                axis.x: 0; axis.y: 1; axis.z: 0
                angle: application.desktopMode ? 180 : 0
            }
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

            cameraResolution: camera.viewfinder.resolution
            viewFinderHeight: viewFinder.height
            viewFinderWidth: viewFinder.width
            viewFinderOrientation: viewFinder.orientation
        }

        Item {
            id: gridlines
            objectName: "gridlines"
            anchors.horizontalCenter: parent.horizontalCenter
            width: viewFinderGeometry.width
            height: viewFinderGeometry.height
            visible: viewFinderOverlay.settings != undefined && viewFinderOverlay.settings.gridEnabled

            property color color: Qt.rgba(0.8, 0.8, 0.8, 0.8)
            property real thickness: units.dp(1)

            Rectangle {
                y: parent.height / 3
                width: parent.width
                height: gridlines.thickness
                color: gridlines.color
            }

            Rectangle {
                y: 2 * parent.height / 3
                width: parent.width
                height: gridlines.thickness
                color: gridlines.color
            }

            Rectangle {
                x: parent.width / 3
                width: gridlines.thickness
                height: parent.height
                color: gridlines.color
            }

            Rectangle {
                x: 2 * parent.width / 3
                width: gridlines.thickness
                height: parent.height
                color: gridlines.color
            }
        }

        Connections {
            target: viewFinderView
            onInViewChanged: if (!viewFinderView.inView) viewFinderOverlay.controls.cancelTimedShoot()
        }

        OrientationHelper {
            id: timedShootFeedback
            anchors.fill: parent

            function start() {
            }

            function stop() {
                remainingSecsLabel.text = "";
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

            // tapping anywhere on the screen while a timed shoot is ongoing cancels it
            MouseArea {
                anchors.fill: parent
                onClicked: viewFinderOverlay.controls.cancelTimedShoot()
                enabled: remainingSecsLabel.visible
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
                shootFeedbackAnimation.restart();
            }

            OpacityAnimator {
                id: shootFeedbackAnimation
                target: shootFeedback
                from: 1.0
                to: 0.0
                duration: UbuntuAnimation.SnapDuration
                easing: UbuntuAnimation.StandardEasing
            }
        }
    }

    FastBlur {
        id: viewFinderSwitcherBlurred
        anchors.fill: viewFinderSwitcher
        property real finalRadius: 64
        property real finalOpacity: 0.7
        radius: photoRollHint.visible ? finalRadius : viewFinderOverlay.revealProgress * finalRadius
        opacity: photoRollHint.visible ? finalOpacity : (1.0 - viewFinderOverlay.revealProgress) * finalOpacity + finalOpacity
        source: radius !== 0 ? viewFinderSwitcher : null
        visible: radius !== 0
    }

    PhotoRollHint {
        id: photoRollHint
        objectName: "photoRollHint"
        anchors.fill: parent
        visible: enabled

        Connections {
            target: viewFinderView
            onInViewChanged: if (!viewFinderView.inView) photoRollHint.disable()
        }
    }

    ViewFinderOverlayLoader {
        id: viewFinderOverlay

        anchors.fill: parent
        camera: camera
        opacity: status == Loader.Ready && overlayVisible && !photoRollHint.enabled ? 1.0 : 0.0
        readyForCapture: main.contentExportMode &&
                         viewFinderExportConfirmation.waitingForPictureCapture ? false : camera.imageCapture.ready

        Behavior on opacity {
            enabled: !photoRollHint.enabled
            UbuntuNumberAnimation {duration: UbuntuAnimation.SnapDuration}
        }

        // Tapping anywhere on the screen should not trigger any camera
        // controls while PhotoRoll hint is visible 
        MouseArea {
            anchors.fill: parent
            enabled: photoRollHint.visible
        }
    }

    ViewFinderExportConfirmation {
        id: viewFinderExportConfirmation
        anchors.fill: parent

        isVideo: main.transfer && main.transfer.contentType == ContentType.Videos
        viewFinderGeometry: viewFinderGeometry

        onShowRequested: {
            viewFinder.visible = false;
            viewFinderOverlay.visible = false;
            visible = true;
        }

        onHideRequested: {
            viewFinder.visible = true;
            viewFinderOverlay.visible = true;
            visible = false;
        }
    }

    Component {
         id: captureFailedDialogComponent
         Dialog {
             id: captureFailedDialog
             objectName: "captureFailedDialog"
             title: i18n.tr("Capture failed")

             // If we are capturing to an SD card the problem can be a broken card, otherwise it is probably a
             // crash in the driver and a reboot might fix things.
             text: StorageLocations.removableStorageLocation && viewFinderOverlay.settings.preferRemovableStorage ?
                   i18n.tr("Replacing your external media, formatting it, or restarting the device might fix the problem.") :
                   i18n.tr("Restarting your device might fix the problem.")

             Button {
                 text: i18n.tr("Cancel")
                 onClicked: PopupUtils.close(captureFailedDialog)
             }
         }
    }
}
