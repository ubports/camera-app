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
import QtPositioning 5.2
import QtSensors 5.0
import CameraApp 0.1
import Qt.labs.settings 1.0

Item {
    id: viewFinderOverlay

    property Camera camera
    property bool touchAcquired: bottomEdge.pressed || zoomPinchArea.active
    property real revealProgress: noSpaceHint.visible ? 1.0 : bottomEdge.progress
    property var controls: controls
    property var settings: settings

    function showFocusRing(x, y) {
        focusRing.center = Qt.point(x, y);
        focusRing.show();
    }

    Settings {
        id: settings

        property int flashMode: Camera.FlashAuto
        property bool gpsEnabled: false
        property bool hdrEnabled: false
        property int videoFlashMode: Camera.FlashOff
        property int selfTimerDelay: 0
        property int encodingQuality: 2 // QMultimedia.NormalQuality
        property bool gridEnabled: false
        property bool preferRemovableStorage: false
        property string videoResolution: "1920x1080"
        property bool playShutterSound: true

        onFlashModeChanged: if (flashMode != Camera.FlashOff) hdrEnabled = false;
        onHdrEnabledChanged: if (hdrEnabled) flashMode = Camera.FlashOff
    }

    Binding {
        target: camera.flash
        property: "mode"
        value: settings.flashMode
        when: camera.captureMode == Camera.CaptureStillImage
    }

    Binding {
        target: camera.flash
        property: "mode"
        value: settings.videoFlashMode
        when: camera.captureMode == Camera.CaptureVideo
    }

    Binding {
        target: camera.advanced
        property: "hdrEnabled"
        value: settings.hdrEnabled
    }

    Binding {
        target: camera.advanced
        property: "encodingQuality"
        value: settings.encodingQuality
    }

    Binding {
        target: camera.videoRecorder
        property: "resolution"
        value: settings.videoResolution
    }

    function resolutionToLabel(resolution) {
        // takes in a resolution string (e.g. "1920x1080") and returns a nicer
        // form of it for display in the UI: "1080p"
        return resolution.split("x").pop() + "p";
    }

    function updateVideoResolutionOptions() {
        // Clear and refill videoResolutionOptionsModel with available resolutions
        // Try to only display well known resolutions: 1080p, 720p and 480p
        videoResolutionOptionsModel.clear();
        var supported = camera.advanced.videoSupportedResolutions;
        var wellKnown = ["1920x1080", "1280x720", "640x480"];
        for (var i=0; i<supported.length; i++) {
            var resolution = supported[i];
            if (wellKnown.indexOf(resolution) !== -1) {
                var option = {"icon": "",
                              "label": resolutionToLabel(resolution),
                              "value": resolution};
                videoResolutionOptionsModel.insert(0, option);
            }
        }

        // If resolution setting chosen is not supported select the highest available resolution
        if (supported.indexOf(settings.videoResolution) == -1) {
            settings.videoResolution = supported[supported.length - 1];
        }
    }

    Component.onCompleted: {
        updateVideoResolutionOptions();
    }

    Connections {
        target: camera.advanced
        onVideoSupportedResolutionsChanged: updateVideoResolutionOptions();
    }

    Connections {
        target: camera.advanced
        onActiveCameraIndexChanged: {
            updateVideoResolutionOptions();
            camera.videoRecorder.resolution = settings.videoResolution;
        }
    }

    Connections {
        target: camera.imageCapture
        onReadyChanged: {
            if (camera.imageCapture.ready) {
                // FIXME: this is a workaround: simply setting
                // camera.flash.mode to the settings value does not have any effect
                camera.flash.mode = Camera.FlashOff;
                camera.flash.mode = settings.flashMode;
            }
        }
    }

    function optionsOverlayClose() {
        print("optionsOverlayClose")
        if (optionsOverlayLoader.item.valueSelectorOpened) {
            optionsOverlayLoader.item.closeValueSelector();
        } else {
            bottomEdge.close();
        }
    }

    MouseArea {
        id: bottomEdgeClose
        anchors.fill: parent
        onClicked: optionsOverlayClose()
    }

    OrientationHelper {
        id: bottomEdgeOrientation
        transitionEnabled: bottomEdge.opened

        Panel {
            id: bottomEdge
            anchors {
                right: parent.right
                left: parent.left
                bottom: parent.bottom
            }
            height: optionsOverlayLoader.height
            onOpenedChanged: optionsOverlayLoader.item.closeValueSelector()
            enabled: camera.videoRecorder.recorderState == CameraRecorder.StoppedState
            opacity: enabled ? 1.0 : 0.3

            Item {
                /* Use the 'trigger' feature of Panel so that tapping on the Panel
                   has the same effect as tapping outside of it (bottomEdgeClose) */
                id: clickReceiver
                anchors.fill: parent
                function trigger() {
                    optionsOverlayClose();
                }
            }

            /* At startup, opened is false and 'bottomEdge.height' is 0 until
               optionsOverlayLoader has finished loading. When that happens
               'bottomEdge.height' becomes non 0 and 'bottomEdge.position' which
               depends on bottomEdge.height eventually reaches the value
               'bottomEdge.height'. Unfortunately during that short period 'progress'
               has an incorrect value and unfortunate consequences/bugs occur.
               That makes it important to only compute progress when 'opened' is true.

               Ref.: https://bugs.launchpad.net/ubuntu/+source/camera-app/+bug/1472903
            */
            property real progress: opened ? (bottomEdge.height - bottomEdge.position) / bottomEdge.height : 0
            property list<ListModel> options: [
                ListModel {
                    id: gpsOptionsModel

                    property string settingsProperty: "gpsEnabled"
                    property string icon: "location"
                    property string label: ""
                    property bool isToggle: true
                    property int selectedIndex: bottomEdge.indexForValue(gpsOptionsModel, settings.gpsEnabled)
                    property bool available: true
                    property bool visible: true
                    property bool showInIndicators: true

                    ListElement {
                        icon: ""
                        label: QT_TR_NOOP("On")
                        value: true
                    }
                    ListElement {
                        icon: ""
                        label: QT_TR_NOOP("Off")
                        value: false
                    }
                },
                ListModel {
                    id: flashOptionsModel

                    property string settingsProperty: "flashMode"
                    property string icon: ""
                    property string label: ""
                    property bool isToggle: false
                    property int selectedIndex: bottomEdge.indexForValue(flashOptionsModel, settings.flashMode)
                    property bool available: camera.advanced.hasFlash
                    property bool visible: camera.captureMode == Camera.CaptureStillImage
                    property bool showInIndicators: true

                    ListElement {
                        icon: "flash-on"
                        label: QT_TR_NOOP("On")
                        value: Camera.FlashOn
                    }
                    ListElement {
                        icon: "flash-auto"
                        label: QT_TR_NOOP("Auto")
                        value: Camera.FlashAuto
                    }
                    ListElement {
                        icon: "flash-off"
                        label: QT_TR_NOOP("Off")
                        value: Camera.FlashOff
                    }
                },
                ListModel {
                    id: videoFlashOptionsModel

                    property string settingsProperty: "videoFlashMode"
                    property string icon: ""
                    property string label: ""
                    property bool isToggle: false
                    property int selectedIndex: bottomEdge.indexForValue(videoFlashOptionsModel, settings.videoFlashMode)
                    property bool available: camera.advanced.hasFlash
                    property bool visible: camera.captureMode == Camera.CaptureVideo
                    property bool showInIndicators: true

                    ListElement {
                        icon: "torch-on"
                        label: QT_TR_NOOP("On")
                        value: Camera.FlashVideoLight
                    }
                    ListElement {
                        icon: "torch-off"
                        label: QT_TR_NOOP("Off")
                        value: Camera.FlashOff
                    }
                },
                ListModel {
                    id: hdrOptionsModel

                    property string settingsProperty: "hdrEnabled"
                    property string icon: ""
                    property string label: i18n.tr("HDR")
                    property bool isToggle: true
                    property int selectedIndex: bottomEdge.indexForValue(hdrOptionsModel, settings.hdrEnabled)
                    property bool available: camera.advanced.hasHdr
                    property bool visible: true
                    property bool showInIndicators: true

                    ListElement {
                        icon: ""
                        label: QT_TR_NOOP("On")
                        value: true
                    }
                    ListElement {
                        icon: ""
                        label: QT_TR_NOOP("Off")
                        value: false
                    }
                },
                ListModel {
                    id: selfTimerOptionsModel

                    property string settingsProperty: "selfTimerDelay"
                    property string icon: ""
                    property string iconSource: "assets/self_timer.svg"
                    property string label: ""
                    property bool isToggle: true
                    property int selectedIndex: bottomEdge.indexForValue(selfTimerOptionsModel, settings.selfTimerDelay)
                    property bool available: true
                    property bool visible: true
                    property bool showInIndicators: true

                    ListElement {
                        icon: ""
                        label: QT_TR_NOOP("Off")
                        value: 0
                    }
                    ListElement {
                        icon: ""
                        label: QT_TR_NOOP("5 seconds")
                        value: 5
                    }
                    ListElement {
                        icon: ""
                        label: QT_TR_NOOP("15 seconds")
                        value: 15
                    }
                },
                ListModel {
                    id: encodingQualityOptionsModel

                    property string settingsProperty: "encodingQuality"
                    property string icon: "stock_image"
                    property string label: ""
                    property bool isToggle: false
                    property int selectedIndex: bottomEdge.indexForValue(encodingQualityOptionsModel, settings.encodingQuality)
                    property bool available: true
                    property bool visible: camera.captureMode == Camera.CaptureStillImage
                    property bool showInIndicators: false

                    ListElement {
                        label: QT_TR_NOOP("Fine Quality")
                        value: 4 // QMultimedia.VeryHighQuality
                    }
                    ListElement {
                        label: QT_TR_NOOP("Normal Quality")
                        value: 2 // QMultimedia.NormalQuality
                    }
                    ListElement {
                        label: QT_TR_NOOP("Basic Quality")
                        value: 1 // QMultimedia.LowQuality
                    }
                },
                ListModel {
                    id: gridOptionsModel

                    property string settingsProperty: "gridEnabled"
                    property string icon: ""
                    property string iconSource: "assets/grid_lines.svg"
                    property string label: ""
                    property bool isToggle: true
                    property int selectedIndex: bottomEdge.indexForValue(gridOptionsModel, settings.gridEnabled)
                    property bool available: true
                    property bool visible: true

                    ListElement {
                        icon: ""
                        label: QT_TR_NOOP("On")
                        value: true
                    }
                    ListElement {
                        icon: ""
                        label: QT_TR_NOOP("Off")
                        value: false
                    }
                },
                ListModel {
                    id: removableStorageOptionsModel

                    property string settingsProperty: "preferRemovableStorage"
                    property string icon: ""
                    property string label: i18n.tr("SD")
                    property bool isToggle: true
                    property int selectedIndex: bottomEdge.indexForValue(removableStorageOptionsModel, settings.preferRemovableStorage)
                    property bool available: application.removableStoragePresent
                    property bool visible: available

                    ListElement {
                        icon: ""
                        label: QT_TR_NOOP("Save to SD Card")
                        value: true
                    }
                    ListElement {
                        icon: ""
                        label: QT_TR_NOOP("Save internally")
                        value: false
                    }
                },
                ListModel {
                    id: videoResolutionOptionsModel

                    property string settingsProperty: "videoResolution"
                    property string icon: ""
                    property string label: "HD"
                    property bool isToggle: false
                    property int selectedIndex: bottomEdge.indexForValue(videoResolutionOptionsModel, settings.videoResolution)
                    property bool available: true
                    property bool visible: camera.captureMode == Camera.CaptureVideo
                    property bool showInIndicators: false
                },
                ListModel {
                    id: shutterSoundOptionsModel

                    property string settingsProperty: "playShutterSound"
                    property string icon: ""
                    property string label: ""
                    property bool isToggle: true
                    property int selectedIndex: bottomEdge.indexForValue(shutterSoundOptionsModel, settings.playShutterSound)
                    property bool available: true
                    property bool visible: camera.captureMode === Camera.CaptureStillImage
                    property bool showInIndicators: false

                    ListElement {
                        icon: "audio-volume-high"
                        label: QT_TR_NOOP("On")
                        value: true
                    }
                    ListElement {
                        icon: "audio-volume-muted"
                        label: QT_TR_NOOP("Off")
                        value: false
                    }
                }
            ]

            /* FIXME: application.removableStoragePresent is not updated dynamically.
               Workaround that by reading it when the bottom edge is opened/closed.
            */
            Connections {
                target: bottomEdge
                onOpenedChanged: removableStorageOptionsModel.available = application.removableStoragePresent
            }

            function indexForValue(model, value) {
                var i;
                var element;
                for (i=0; i<model.count; i++) {
                    element = model.get(i);
                    if (element.value === value) {
                        return i;
                    }
                }

                return -1;
            }

            BottomEdgeIndicators {
                id: bottomEdgeIndicators
                options: bottomEdge.options
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.top
                }
                opacity: bottomEdge.pressed || bottomEdge.opened ? 0.0 : 1.0
                Behavior on opacity { UbuntuNumberAnimation {} }
            }

            Loader {
                id: optionsOverlayLoader
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                asynchronous: true
                sourceComponent: Component {
                    OptionsOverlay {
                        options: bottomEdge.options
                    }
                }
            }
        }
    }

    OrientationSensor {
        id: orientationSensor
        active: true
    }

    Item {
        id: controls

        anchors {
            left: parent.left
            right: parent.right
        }
        height: parent.height
        y: Screen.angleBetween(Screen.primaryOrientation, Screen.orientation) == 0 ? bottomEdge.position - bottomEdge.height : 0
        opacity: 1 - bottomEdge.progress
        visible: opacity != 0.0
        enabled: visible

        function timedShoot(secs) {
            timedShootFeedback.start();
            shootingTimer.remainingSecs = secs;
            shootingTimer.start();
        }

        function cancelTimedShoot() {
            if (shootingTimer.running) {
                shootingTimer.stop();
                timedShootFeedback.stop();
            }
        }

        function shoot() {
            var orientation;
            switch (orientationSensor.reading.orientation) {
                case OrientationReading.TopUp:
                    orientation = 0;
                    break;
                case OrientationReading.TopDown:
                    orientation = 180;
                    break;
                case OrientationReading.LeftUp:
                    orientation = 90;
                    break;
                case OrientationReading.RightUp:
                    orientation = 270;
                    break;
                default:
                    /* Workaround for OrientationSensor not setting a valid value until
                       the device is rotated.
                       Ref.: https://bugs.launchpad.net/qtubuntu-sensors/+bug/1429865

                       Note that the value returned by Screen.angleBetween is valid if
                       the orientation lock is not engaged.
                       Ref.: https://bugs.launchpad.net/camera-app/+bug/1422762
                    */
                    orientation = Screen.angleBetween(Screen.orientation, Screen.primaryOrientation);
                    break;
            }

            if (Screen.primaryOrientation == Qt.PortraitOrientation) {
                orientation += 90;
            }

            if (camera.captureMode == Camera.CaptureVideo) {
                if (application.removableStoragePresent && settings.preferRemovableStorage) {
                    camera.videoRecorder.outputLocation = application.removableStorageVideosLocation;
                } else {
                    camera.videoRecorder.outputLocation = application.videosLocation;
                }

                if (camera.videoRecorder.recorderState == CameraRecorder.StoppedState) {
                    camera.videoRecorder.setMetadata("Orientation", orientation);
                    camera.videoRecorder.record();
                }
            } else {
                if (!main.contentExportMode) {
                    shootFeedback.start();
                }
                camera.imageCapture.setMetadata("Orientation", orientation);
                var position = positionSource.position;
                if (settings.gpsEnabled && positionSource.valid
                        && position.latitudeValid
                        && position.longitudeValid) {
                    camera.imageCapture.setMetadata("GPSLatitude", position.coordinate.latitude);
                    camera.imageCapture.setMetadata("GPSLongitude", position.coordinate.longitude);
                    camera.imageCapture.setMetadata("GPSTimeStamp", position.timestamp);
                    camera.imageCapture.setMetadata("GPSProcessingMethod", "GPS");
                    if (position.altitudeValid) {
                        camera.imageCapture.setMetadata("GPSAltitude", position.coordinate.altitude);
                    }
                }
                if (main.contentExportMode) {
                    camera.imageCapture.captureToLocation(application.temporaryLocation);
                } else if (application.removableStoragePresent && settings.preferRemovableStorage) {
                    camera.imageCapture.captureToLocation(application.removableStoragePicturesLocation);
                } else {
                    camera.imageCapture.captureToLocation(application.picturesLocation);
                }
            }
        }

        function switchCamera() {
            camera.switchInProgress = true;
            //                viewFinderGrab.sourceItem = viewFinder;
            viewFinderGrab.x = viewFinder.x;
            viewFinderGrab.y = viewFinder.y;
            viewFinderGrab.width = viewFinder.width;
            viewFinderGrab.height = viewFinder.height;
            viewFinderGrab.visible = true;
            viewFinderGrab.scheduleUpdate();
        }

        function completeSwitch() {
            viewFinderSwitcherAnimation.restart();
            camera.switchInProgress = false;
        }

        function changeRecordMode() {
            if (camera.captureMode == Camera.CaptureVideo) camera.videoRecorder.stop()
            camera.captureMode = (camera.captureMode == Camera.CaptureVideo) ? Camera.CaptureStillImage : Camera.CaptureVideo
        }

        Timer {
            id: shootingTimer
            repeat: true
            triggeredOnStart: true

            property int remainingSecs: 0

            onTriggered: {
                if (remainingSecs == 0) {
                    running = false;
                    controls.shoot();
                    timedShootFeedback.stop();
                } else {
                    timedShootFeedback.showRemainingSecs(remainingSecs);
                    remainingSecs--;
                }
            }
        }

        PositionSource {
            id: positionSource
            updateInterval: 1000
            active: settings.gpsEnabled
        }

        Connections {
            target: camera.imageCapture
            onReadyChanged: {
                if (camera.imageCapture.ready) {
                    if (camera.switchInProgress) {
                        controls.completeSwitch();
                    }
                }
            }
        }

        CircleButton {
            id: recordModeButton
            objectName: "recordModeButton"

            anchors {
                right: shootButton.left
                rightMargin: units.gu(7.5)
                bottom: parent.bottom
                bottomMargin: units.gu(6)
            }

            iconName: (camera.captureMode == Camera.CaptureStillImage) ? "camcorder" : "camera-symbolic"
            onClicked: controls.changeRecordMode()
            enabled: camera.videoRecorder.recorderState == CameraRecorder.StoppedState && !main.contentExportMode
        }

        ShootButton {
            id: shootButton

            anchors {
                bottom: parent.bottom
                // account for the bottom shadow in the asset
                bottomMargin: units.gu(5) - units.dp(6)
                horizontalCenter: parent.horizontalCenter
            }

            enabled: camera.imageCapture.ready && !storageMonitor.diskSpaceCriticallyLow
            state: (camera.captureMode == Camera.CaptureVideo) ?
                   ((camera.videoRecorder.recorderState == CameraRecorder.StoppedState) ? "record_off" : "record_on") :
                   "camera"
            onClicked: {
                if (camera.captureMode == Camera.CaptureVideo && camera.videoRecorder.recorderState == CameraRecorder.RecordingState) {
                    camera.videoRecorder.stop();
                } else {
                    if (settings.selfTimerDelay > 0) {
                        controls.timedShoot(settings.selfTimerDelay);
                    } else {
                        controls.shoot();
                    }
                }
            }
            rotation: Screen.angleBetween(Screen.primaryOrientation, Screen.orientation)
            Behavior on rotation {
                RotationAnimator {
                    duration: UbuntuAnimation.BriskDuration
                    easing: UbuntuAnimation.StandardEasing
                    direction: RotationAnimator.Shortest
                }
            }
        }

        CircleButton {
            id: swapButton
            objectName: "swapButton"

            anchors {
                left: shootButton.right
                leftMargin: units.gu(7.5)
                bottom: parent.bottom
                bottomMargin: units.gu(6)
            }

            enabled: !camera.switchInProgress && camera.videoRecorder.recorderState == CameraRecorder.StoppedState
            iconName: "camera-flip"
            onClicked: controls.switchCamera()
        }


        PinchArea {
            id: zoomPinchArea
            anchors {
                top: parent.top
                bottom: shootButton.top
                bottomMargin: bottomEdgeIndicators.height
                left: parent.left
                leftMargin: bottomEdgeIndicators.height
                right: parent.right
                rightMargin: bottomEdgeIndicators.height
            }

            property real initialZoom
            property real minimumScale: 0.3
            property real maximumScale: 3.0
            property bool active: false

            onPinchStarted: {
                active = true;
                initialZoom = zoomControl.value;
                zoomControl.show();
            }
            onPinchUpdated: {
                zoomControl.show();
                var scaleFactor = MathUtils.projectValue(pinch.scale, 1.0, maximumScale, 0.0, zoomControl.maximumValue);
                zoomControl.value = MathUtils.clamp(initialZoom + scaleFactor, zoomControl.minimumValue, zoomControl.maximumValue);
            }
            onPinchFinished: {
                active = false;
            }


            MouseArea {
                id: manualFocusMouseArea
                anchors.fill: parent
                onClicked: {
                    camera.manualFocus(mouse.x, mouse.y);
                    mouse.accepted = false;
                }
                // FIXME: calling 'isFocusPointModeSupported' fails with
                // "Error: Unknown method parameter type: QDeclarativeCamera::FocusPointMode"
                //enabled: camera.focus.isFocusPointModeSupported(Camera.FocusPointCustom)
            }
        }

        ZoomControl {
            id: zoomControl

            anchors {
                bottom: shootButton.top
                bottomMargin: units.gu(2)
                left: parent.left
                right: parent.right
                leftMargin: recordModeButton.x
                rightMargin: parent.width - (swapButton.x + swapButton.width)
            }
            maximumValue: camera.maximumZoom

            Binding { target: camera; property: "currentZoom"; value: zoomControl.value }
        }

        StopWatch {
            id: stopWatch

            anchors {
                top: parent.top
                topMargin: units.gu(6)
                horizontalCenter: parent.horizontalCenter
            }
            opacity: camera.videoRecorder.recorderState == CameraRecorder.StoppedState ? 0.0 : 1.0
            Behavior on opacity { UbuntuNumberAnimation {} }
            visible: opacity != 0
            time: camera.videoRecorder.duration / 1000
        }

        FocusRing {
            id: focusRing
        }

        CircleButton {
            id: exportBackButton
            objectName: "exportBackButton"

            anchors {
                top: parent.top
                topMargin: units.gu(4)
                left: recordModeButton.left
            }

            iconName: visible ? "go-previous" : ""
            visible: main.contentExportMode
            enabled: main.contentExportMode
            onClicked: main.cancelExport()
        }
    }

    StorageMonitor {
        id: storageMonitor
        location: (application.removableStoragePresent && settings.preferRemovableStorage) ?
                   application.removableStorageLocation : application.videosLocation
        onDiskSpaceLowChanged: if (storageMonitor.diskSpaceLow && !storageMonitor.diskSpaceCriticallyLow) {
                                   PopupUtils.open(freeSpaceLowDialogComponent);
                               }
        onDiskSpaceCriticallyLowChanged: if (storageMonitor.diskSpaceCriticallyLow) {
                                             camera.videoRecorder.stop();
                                         }
    }

    NoSpaceHint {
        id: noSpaceHint
        objectName: "noSpace"
        anchors.fill: parent
        visible: storageMonitor.diskSpaceCriticallyLow
    }

    Component {
         id: freeSpaceLowDialogComponent
         Dialog {
             id: freeSpaceLowDialog
             objectName: "lowSpaceDialog"
             title: i18n.tr("Low storage space")
             text: i18n.tr("You are running out of storage space. To continue without interruptions, free up storage space now.")
             Button {
                 text: i18n.tr("Cancel")
                 onClicked: PopupUtils.close(freeSpaceLowDialog)
             }
         }
    }
}
