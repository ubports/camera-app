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
import QtPositioning 5.2
import CameraApp 0.1
import Qt.labs.settings 1.0

Item {
    id: viewFinderOverlay

    property Camera camera
    property bool touchAcquired: bottomEdge.pressed || zoomPinchArea.active
    property real revealProgress: bottomEdge.progress
    property var controls: controls

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
        property bool preferRemovableStorage: false
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

    Panel {
        id: bottomEdge
        anchors {
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }
        height: optionsOverlayLoader.height
        onOpenedChanged: optionsOverlayLoader.item.closeValueSelector()

        Item {
            /* Use the 'trigger' feature of Panel so that tapping on the Panel
               has the same effect as tapping outside of it (bottomEdgeClose) */
            id: clickReceiver
            anchors.fill: parent
            function trigger() {
                optionsOverlayClose();
            }
        }

        property real progress: (bottomEdge.height - bottomEdge.position) / bottomEdge.height
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
                property bool visible: true

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
            }
        ]

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

        Item {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.top
            }
            width: indicators.width + units.gu(2)
            height: units.gu(3)
            opacity: bottomEdge.pressed || bottomEdge.opened ? 0.0 : 1.0
            Behavior on opacity { UbuntuNumberAnimation {} }

            Image {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: parent.height * 2
                opacity: 0.3
                source: "assets/ubuntu_shape.svg"
                sourceSize.width: width
                sourceSize.height: height
                cache: false
                asynchronous: true
                visible: indicators.visibleChildren.length > 1
            }

            Row {
                id: indicators

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: units.gu(1)

                Repeater {
                    model: bottomEdge.options
                    delegate: Item {
                        anchors {
                            top: parent.top
                            topMargin: units.gu(0.5)
                            bottom: parent.bottom
                            bottomMargin: units.gu(0.5)
                        }
                        width: units.gu(2)
                        visible: modelData.available && modelData.visible ? (modelData.isToggle ? modelData.get(model.selectedIndex).value : true) : false
                        opacity: 0.5

                        Icon {
                            id: indicatorIcon
                            anchors.fill: parent
                            color: "white"
                            name: modelData.isToggle ? modelData.icon : modelData.get(model.selectedIndex).icon
                            visible: name !== ""
                        }

                        Label {
                            id: indicatorLabel
                            anchors.fill: parent
                            fontSize: "xx-small"
                            color: "white"
                            text: modelData.label
                            verticalAlignment: Text.AlignVCenter
                            visible: indicatorIcon.name === ""
                        }
                    }
                }
            }
        }
    }

    Item {
        id: controls

        anchors {
            left: parent.left
            right: parent.right
        }
        height: parent.height
        y: bottomEdge.position - bottomEdge.height
        opacity: 1 - bottomEdge.progress
        visible: opacity != 0.0
        enabled: visible

        function shoot() {
            var orientation = Screen.angleBetween(Screen.orientation, Screen.primaryOrientation);
            if (Screen.primaryOrientation == Qt.PortraitOrientation) {
                orientation += 90;
            }

            if (camera.captureMode == Camera.CaptureVideo) {
                if (application.removableStoragePresent && settings.preferRemovableStorage) {
                    camera.videoRecorder.outputLocation = application.removableStorageVideosLocation;
                }
                if (camera.videoRecorder.recorderState == CameraRecorder.StoppedState) {
                    camera.videoRecorder.setMetadata("Orientation", orientation);
                    camera.videoRecorder.record();
                } else {
                    camera.videoRecorder.stop();
                    // TODO: there's no event to tell us that the video has been successfully recorder or failed
                }
            } else {
                if (!main.contentExportMode) {
                    shootFeedback.start();
                }
                camera.imageCapture.setMetadata("Orientation", orientation);
                var position = positionSource.position;
                if (settings.gpsEnabled && positionSource.valid
                        && position.latitudeValid
                        && position.longitudeValid
                        && position.altitudeValid) {
                    camera.imageCapture.setMetadata("GPSLatitude", position.coordinate.latitude);
                    camera.imageCapture.setMetadata("GPSLongitude", position.coordinate.longitude);
                    camera.imageCapture.setMetadata("GPSAltitude", position.coordinate.altitude);
                    camera.imageCapture.setMetadata("GPSTimeStamp", position.timestamp);
                    camera.imageCapture.setMetadata("GPSProcessingMethod", "GPS");
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

            enabled: camera.imageCapture.ready
            state: (camera.captureMode == Camera.CaptureVideo) ?
                   ((camera.videoRecorder.recorderState == CameraRecorder.StoppedState) ? "record_off" : "record_on") :
                   "camera"
            onClicked: controls.shoot()
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
                bottomMargin: units.gu(1)
                left: parent.left
                right: parent.right
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

    Loader {
        id: optionsOverlayLoader
        anchors {
            left: parent.left
            right: parent.right
            top: controls.bottom
        }
        asynchronous: true
        sourceComponent: Component {
            OptionsOverlay {
                options: bottomEdge.options
            }
        }
    }
}
