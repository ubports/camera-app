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
import QtMultimedia 5.0
import CameraApp 0.1

Item {
    id: viewFinderOverlay

    property Camera camera
    property bool touchAcquired: bottomEdge.pressed || zoomPinchArea.active
    property real revealProgress: bottomEdge.progress

    function showFocusRing(x, y) {
        focusRing.center = Qt.point(x, y);
        focusRing.show();
    }

    QtObject {
        id: settings

        property int flashMode: Camera.FlashAuto
        property bool gpsEnabled: false
        property bool hdrEnabled: false
    }

    Binding {
        target: camera.flash
        property: "mode"
        value: settings.flashMode
    }

    Connections {
        target: camera
        onCameraStateChanged: camera.flash.mode = settings.flashMode
    }

    Panel {
        id: bottomEdge
        anchors {
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }
        height: units.gu(9)
        onOpenedChanged: optionValueSelector.hide()

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

                ListElement {
                    icon: ""
                    label: "On"
                    value: true
                }
                ListElement {
                    icon: ""
                    label: "Off"
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

                ListElement {
                    icon: "flash-on"
                    label: "On"
                    value: Camera.FlashOn
                }
                ListElement {
                    icon: "flash-auto"
                    label: "Auto"
                    value: Camera.FlashAuto
                }
                ListElement {
                    icon: "flash-off"
                    label: "Off"
                    value: Camera.FlashOff
                }
            },
            ListModel {
                id: hdrOptionsModel

                property string settingsProperty: "hdrEnabled"
                property string icon: "import-image"
                property string label: "HDR"
                property bool isToggle: true
                property int selectedIndex: bottomEdge.indexForValue(hdrOptionsModel, settings.hdrEnabled)
                property bool available: true

                ListElement {
                    icon: ""
                    label: "On"
                    value: true
                }
                ListElement {
                    icon: ""
                    label: "Off"
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
                    delegate: Icon {
                        anchors {
                            top: parent.top
                            topMargin: units.gu(0.5)
                            bottom: parent.bottom
                            bottomMargin: units.gu(0.5)
                        }
                        width: units.gu(2)
                        color: "white"
                        opacity: 0.5
                        name: modelData.isToggle ? modelData.icon : modelData.get(model.selectedIndex).icon
                        visible: modelData.available ? (modelData.isToggle ? modelData.get(model.selectedIndex).value : true) : false
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
            camera.captureInProgress = true;
            shootFeedback.start();

            var orientation = 90
            if (device.isLandscape) {
                if (device.naturalOrientation === "portrait") {
                    orientation = 180
                } else {
                    orientation = 0
                }
            }
            if (device.isInverted) {
                orientation += 180
            }

            if (camera.captureMode == Camera.CaptureVideo) {
                if (camera.videoRecorder.recorderState == CameraRecorder.StoppedState) {
                    camera.videoRecorder.setMetadata("Orientation", orientation)
                    camera.videoRecorder.record()
                } else {
                    camera.videoRecorder.stop()
                    // TODO: there's no event to tell us that the video has been successfully recorder or failed,
                    // and no preview to slide off anyway. Figure out what to do in this case.
                }
            } else {
                camera.imageCapture.setMetadata("Orientation", orientation)
                camera.imageCapture.capture()
            }
        }

        function completeCapture() {
            print("COMPLETE CAPTURE")
            viewFinderOverlay.visible = true;
            snapshot.startOutAnimation();
            camera.captureInProgress = false;
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
            print("COMPLETE SWITCH")
            viewFinderSwitcherAnimation.restart();
            camera.switchInProgress = false;
        }

        function changeRecordMode() {
            if (camera.captureMode == Camera.CaptureVideo) camera.videoRecorder.stop()
            camera.captureMode = (camera.captureMode == Camera.CaptureVideo) ? Camera.CaptureStillImage : Camera.CaptureVideo
        }

        Connections {
            target: camera.imageCapture
            onReadyChanged: {
                print("READY", camera.imageCapture.ready)
                if (camera.imageCapture.ready) {
                    if (camera.captureInProgress) {
                        controls.completeCapture();
                    } else if (camera.switchInProgress) {
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

            iconName: "camcorder"
            onClicked: controls.changeRecordMode()
        }

        ShootButton {
            id: shootButton

            anchors {
                bottom: parent.bottom
                // account for the bottom shadow in the asset
                bottomMargin: units.gu(5) - units.dp(6)
                horizontalCenter: parent.horizontalCenter
            }

            onClicked: controls.shoot()
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
                enabled: !application.desktopMode
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

        FocusRing {
            id: focusRing
        }
    }

    Item {
        id: options

        anchors {
            left: parent.left
            right: parent.right
            top: controls.bottom
        }
        height: optionsGrid.height

        Grid {
            id: optionsGrid
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            columns: 3
            columnSpacing: units.gu(9.5)
            rowSpacing: units.gu(9.5)

            Repeater {
                model: bottomEdge.options
                delegate: CircleButton {
                    id: optionsButton

                    property var model: modelData

                    iconName: model.isToggle ? model.icon : model.get(model.selectedIndex).icon
                    onClicked: optionValueSelector.toggle(model, optionsButton)
                    on: model.isToggle ? model.get(model.selectedIndex).value : true
                    visible: model.available
                    label: model.label
                }
            }
        }

        Column {
            id: optionValueSelector
            anchors {
                bottom: optionsGrid.top
                bottomMargin: units.gu(2)
            }
            width: units.gu(12)

            function toggle(model, callerButton) {
                if (optionValueSelectorVisible && optionsRepeater.model === model) {
                    hide();
                } else {
                    show(model, callerButton);
                }
            }

            function show(model, callerButton) {
                alignWith(callerButton);
                optionsRepeater.model = model;
                optionValueSelectorVisible = true;
            }

            function hide() {
                optionValueSelectorVisible = false;
            }

            function alignWith(item) {
                // horizontally center optionValueSelector with the center of item
                // if there is enough space to do so, that is as long as optionValueSelector
                // does not get cropped by the edge of the screen
                var itemX = parent.mapFromItem(item, 0, 0).x;
                var centeredX = itemX + item.width / 2.0 - width / 2.0;
                var margin = units.gu(1);

                if (centeredX < margin) {
                    x = itemX;
                } else if (centeredX + width > item.parent.width - margin) {
                    x = itemX + item.width - width;
                } else {
                    x = centeredX;
                }
            }

            visible: opacity !== 0.0
            onVisibleChanged: if (!visible) optionsRepeater.model = null;
            opacity: optionValueSelectorVisible ? 1.0 : 0.0
            Behavior on opacity {UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration}}

            Repeater {
                id: optionsRepeater

                delegate: AbstractButton {
                    id: optionDelegate

                    anchors {
                        right: optionValueSelector.right
                        left: optionValueSelector.left
                    }
                    height: units.gu(5)

                    property bool selected: optionsRepeater.model.selectedIndex == index
                    onClicked: settings[optionsRepeater.model.settingsProperty] = optionsRepeater.model.get(index).value

                    Icon {
                        id: icon
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            left: parent.left
                            topMargin: units.gu(1)
                            bottomMargin: units.gu(1)
                            leftMargin: units.gu(1)
                        }
                        width: height
                        color: "white"
                        opacity: optionDelegate.selected ? 1.0 : 0.5
                        name: model.icon
                    }

                    Label {
                        id: label
                        anchors {
                            left: model.icon != "" ? icon.right : parent.left
                            leftMargin: units.gu(2)
                            right: parent.right
                            rightMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }

                        color: "white"
                        opacity: optionDelegate.selected ? 1.0 : 0.5
                        text: model.label
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: units.dp(1)
                        color: "white"
                        opacity: 0.5
                        visible: index !== optionsRepeater.count - 1
                    }
                }
            }
        }
    }

//    Item {
//        id: controlsArea
//        anchors.centerIn: parent

//        height: (device.naturalOrientation == "portrait") ? parent.height : parent.width
//        width: (device.naturalOrientation == "portrait") ? parent.width : parent.height

//        rotation: device.naturalOrientation == "landscape" ?
//                      ((device.isInverted) ? 90 : -90) :
//                      (!device.isLandscape ? (device.isInverted ? 180 : 0) :
//                                             (device.isInverted ? 0 : 180))

//        state: device.isLandscape ? "split" : "joined"
//        states: [
//            State { name: "joined"
//                AnchorChanges { target: zoomControl; anchors.bottom: toolbar.top }
//                AnchorChanges {
//                    target: stopWatch
//                    anchors.top: parent.top
//                    anchors.horizontalCenter: parent.horizontalCenter
//                }
//            },
//            State { name: "split"
//                AnchorChanges { target: zoomControl; anchors.top: parent.top }
//                AnchorChanges {
//                    target: stopWatch
//                    anchors.right: parent.right
//                    anchors.verticalCenter: parent.verticalCenter
//                }
//            }
//        ]

//        Toolbar {
//            id: toolbar

//            anchors.bottom: parent.bottom
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.bottomMargin: units.gu(1)
//            anchors.leftMargin: units.gu(1)
//            anchors.rightMargin: units.gu(1)

//            camera: camera
//            canCapture: camera.imageCapture.ready && !snapshot.sliding
//            iconsRotation: device.rotationAngle - controlsArea.rotation
//        }

//        StopWatch {
//            id: stopWatch
//            opacity: camera.videoRecorder.recorderState == CameraRecorder.StoppedState ? 0.0 : 1.0
//            time: camera.videoRecorder.duration / 1000
//            labelRotation: device.rotationAngle - controlsArea.rotation
//            anchors.topMargin: units.gu(2)
//            anchors.rightMargin: units.gu(2)
//        }
//    }
}
