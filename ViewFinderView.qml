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
    id: viewFinderView

    property bool overlayVisible: true
    property bool touchAcquired: bottomEdge.pressed
    property bool inView
    signal photoTaken

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
        
        Component.onCompleted: camera.start();
        
        /* Use only digital zoom for now as it's what phone cameras mostly use.
               TODO: if optical zoom is available, maximumZoom should be the combined
               range of optical and digital zoom and currentZoom should adjust the two
               transparently based on the value. */
        property alias currentZoom: camera.digitalZoom
        property alias maximumZoom: camera.maximumDigitalZoom
        property bool captureInProgress: false
        property bool switchInProgress: false
        onCameraStateChanged: print("STATE", cameraState)
        onCameraStatusChanged: print("STATUS", cameraStatus)
        onAvailabilityChanged: print("AVAIL", availability)
        
        imageCapture {
            onCaptureFailed: {
                console.log("Capture failed for request " + requestId + ": " + message);
                focusRing.opacity = 0.0;
            }
            onImageCaptured: {
                print("CAPTURED")
                focusRing.opacity = 0.0;
                snapshot.source = preview;
            }
            onImageSaved: {
                viewFinderView.photoTaken();
                metricPhotos.increment();
                console.log("Picture saved as " + path);
            }
            onReadyChanged: {
                print("READY", imageCapture.ready)
                if (imageCapture.ready) {
                    if (camera.captureInProgress) {
                        controls.completeCapture();
                    } else if (camera.switchInProgress) {
                        controls.completeSwitch();
                    }
                }
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
    
    Item {
        id: viewFinderSwitcher
        anchors.fill: parent
        
        ShaderEffectSource {
            id: viewFinderGrab
            live: false
            sourceItem: viewFinder
            
            onScheduledUpdateCompleted: {
                print("SCHEDULE UPDATE COMPLETED")
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
            //            opacity: viewFinderSwitcherRotation.angle <= 90 ? 1.0 : 0.0
            //            visible: viewFinderSwitcherRotation.angle <= 90
            //            onOpacityChanged: print("viewFinder OPACITY", opacity)
            
            
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
                
                Item {
                    id: itemScale
                    visible: false
                }
                
                //            PinchArea {
                //                id: area
                
                //                state: device.isLandscape ? "split" : "joined"
                //                anchors.left: viewFinderGeometry.left
                //                anchors.right: viewFinderGeometry.right
                
                //                pinch.minimumScale: 0.0
                //                pinch.maximumScale: camera.maximumZoom
                //                pinch.target: itemScale
                
                //                states: [
                //                    State {
                //                        name: "joined"
                //                        PropertyChanges {
                //                            target: area
                //                            height: zoomControl.y
                //                        }
                //                        AnchorChanges {
                //                            target: area;
                //                            anchors.top: viewFinderGeometry.top
                //                        }
                //                    },
                //                    State {
                //                        name: "split"
                //                        PropertyChanges {
                //                            target: area
                //                            y: device.isInverted ?  zoomControl.height : toolbar.height
                //                            height: viewFinderGeometry.height - zoomControl.height - toolbar.height
                //                        }
                //                        AnchorChanges {
                //                            target: area;
                //                            anchors.top: undefined
                //                        }
                //                    }
                //                ]
                
                //                onPinchStarted: {
                //                    if (!application.desktopMode)
                //                        focusRing.center = main.mapFromItem(area, pinch.center.x, pinch.center.y);
                //                }
                
                //                onPinchFinished: {
                //                    if (!application.desktopMode) {
                //                        focusRing.restartTimeout()
                //                        var center = pinch.center
                //                        var focusPoint = viewFinder.mapPointToSourceNormalized(pinch.center);
                //                        camera.focus.customFocusPoint = focusPoint;
                //                    }
                //                }
                
                //                onPinchUpdated: {
                //                    if (!application.desktopMode) {
                //                        focusRing.center = main.mapFromItem(area, pinch.center.x, pinch.center.y);
                //                        camera.currentZoom = itemScale.scale
                //                    }
                //                }
                
                //                MouseArea {
                //                    id: mouseArea
                
                //                    anchors.fill: parent
                
                //                    onPressed: {
                //                        if (!application.desktopMode && !area.pinch.active)
                //                            focusRing.center = main.mapFromItem(area, mouse.x, mouse.y);
                //                    }
                
                //                    onReleased:  {
                //                        if (!application.desktopMode && !area.pinch.active) {
                //                            var focusPoint = viewFinder.mapPointToSourceNormalized(Qt.point(mouse.x, mouse.y))
                
                //                            focusRing.restartTimeout()
                //                            camera.focus.customFocusPoint = focusPoint;
                //                        }
                //                    }
                
                //                    drag {
                //                        target: application.desktopMode ? "" : focusRing
                //                        minimumY: area.y - focusRing.height / 2
                //                        maximumY: area.y + area.height - focusRing.height / 2
                //                        minimumX: area.x - focusRing.width / 2
                //                        maximumX: area.x + area.width - focusRing.width / 2
                //                    }
                
                //                }
                //            }
            }
            
            Rectangle {
                id: shootFeedback
                anchors.fill: parent
                color: "white"
                visible: opacity != 0.0
                opacity: 0.0
                
                function start() {
                    shootFeedback.opacity = 1.0;
                    overlay.visible = false;
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
    }
    
    //    Flipable {
    //        id: viewFinderSwitcher
    //        anchors.fill: parent
    
    //        front: viewFinder
    //        back: ShaderEffectSource {
    //            id: viewFinderGrab
    //            width: viewFinder.width
    //            height: viewFinder.height
    //            live: false
    //            sourceItem: viewFinder
    //        }
    
    //        transform: [
    //            Scale {
    //                id: viewFinderSwitcherScale
    //                origin.x: viewFinderSwitcher.width/2
    //                origin.y: viewFinderSwitcher.height/2
    //                xScale: 1
    //                yScale: xScale
    //            },
    //            Rotation {
    //                id: viewFinderSwitcherRotation
    //                origin.x: viewFinderSwitcher.width/2
    //                origin.y: viewFinderSwitcher.height/2
    //                axis.x: 0; axis.y: 1; axis.z: 0
    //                angle: 0
    //            }
    //        ]
    
    
    //        SequentialAnimation {
    //            id: viewFinderSwitcherAnimation
    
    //            ParallelAnimation {
    //                SequentialAnimation {
    //                    UbuntuNumberAnimation {target: viewFinderSwitcherScale; property: "xScale"; from: 1.0; to: 0.8; duration: UbuntuAnimation.BriskDuration * 6; easing: UbuntuAnimation.StandardEasing}
    //                    UbuntuNumberAnimation {target: viewFinderSwitcherScale; property: "xScale"; from: 0.8; to: 1.0; duration: UbuntuAnimation.BriskDuration * 6; easing: UbuntuAnimation.StandardEasingReverse}
    //                }
    //                UbuntuNumberAnimation {
    //                    target: viewFinderSwitcherRotation
    //                    property: "angle"
    //                    from: 180
    //                    to: 0
    //                    duration: UbuntuAnimation.BriskDuration * 2 * 6
    //                }
    //            }
    //        }
    //    }
    
    FocusRing {
        id: focusRing
        height: units.gu(13)
        width: units.gu(13)
        opacity: 0.0
    }
    
    Item {
        id: overlay
        anchors.fill: parent

        opacity: overlayVisible ? 1.0 : 0.0
        Behavior on opacity {UbuntuNumberAnimation {duration: UbuntuAnimation.SnapDuration}}

        Panel {
            id: bottomEdge
            anchors {
                right: parent.right
                left: parent.left
                bottom: parent.bottom
            }
            height: units.gu(9)
            
            Item {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.top
                }
                width: indicators.width
                height: units.gu(3)
                opacity: bottomEdge.pressed || bottomEdge.opened ? 0.0 : 1.0
                Behavior on opacity {
                    UbuntuNumberAnimation {
                    }
                }

                Image {
                    anchors {
                        fill: parent
                        bottomMargin: -height/2
                    }
                    opacity: 0.3
                    source: "assets/ubuntu_shape.svg"
                    sourceSize.width: width
                    sourceSize.height: height
                }
                
                Row {
                    id: indicators
                    
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                    }
                    spacing: units.gu(0.5)
                    
                    Image {
                        anchors {
                            top: parent.top
                            topMargin: units.gu(0.5)
                            bottom: parent.bottom
                            bottomMargin: units.gu(0.5)
                        }
                        width: units.gu(2)
                        opacity: 0.5
                        source: "assets/gps.png"
                    }
                    
                    Icon {
                        anchors {
                            top: parent.top
                            topMargin: units.gu(0.5)
                            bottom: parent.bottom
                            bottomMargin: units.gu(0.5)
                        }
                        width: units.gu(2)
                        color: "white"
                        opacity: 0.5
                        name: "flash-on"
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
            opacity: 1 - (bottomEdge.height - bottomEdge.position) / bottomEdge.height
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
                overlay.visible = true;
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
        }
        
        Item {
            id: options
            
            anchors {
                left: parent.left
                right: parent.right
                top: controls.bottom
            }
            height: childrenRect.height
            
            Grid {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                
                columns: 3
                columnSpacing: units.gu(9.5)
                rowSpacing: units.gu(9.5)
                
                AbstractButton {
                    id: button1
                    
                    width: units.gu(5)
                    height: width
                    
                    Image {
                        anchors.fill: parent
                        source: "assets/ubuntu_shape.svg"
                        opacity: button1.pressed ? 0.7 : 0.3
                        sourceSize.width: width
                        sourceSize.height: height
                    }
                    
                    Image {
                        anchors {
                            fill: parent
                            margins: units.gu(1)
                        }
                        source: "assets/gps.png"
                    }
                }
                
                CircleButton {
                    iconName: "flash-on"
                }
                
                AbstractButton {
                    id: button2
                    
                    width: units.gu(5)
                    height: width
                    
                    Image {
                        anchors.fill: parent
                        source: "assets/ubuntu_shape.svg"
                        opacity: button2.pressed ? 0.7 : 0.3
                        sourceSize.width: width
                        sourceSize.height: height
                    }
                    
                    Label {
                        anchors {
                            centerIn: parent
                        }
                        font.weight: Font.Light
                        fontSize: "small"
                        color: "white"
                        text: "HDR"
                    }
                }
            }
        }
    }
    
    Snapshot {
        id: snapshot
        anchors.fill: parent
        orientation: viewFinder.orientation
        geometry: viewFinderGeometry
        deviceDefaultIsPortrait: device.naturalOrientation === "portrait"
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

//        ZoomControl {
//            id: zoomControl
//            maximumValue: camera.maximumZoom
//            height: units.gu(4.5)

//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.leftMargin: units.gu(0.75)
//            anchors.rightMargin: units.gu(0.75)
//            anchors.bottomMargin: controlsArea.state == "split" ? units.gu(3.25) : units.gu(0.5)
//            anchors.topMargin: controlsArea.state == "split" ? units.gu(3.25) : units.gu(0.5)

//            visible: camera.maximumZoom > 1

//            // Create a two way binding between the zoom control value and the actual camera zoom,
//            // so that they can stay in sync when the zoom is changed from the UI or from the hardware
//            Binding { target: zoomControl; property: "value"; value: camera.currentZoom }
//            Binding { target: camera; property: "currentZoom"; value: zoomControl.value }

//            iconsRotation: device.rotationAngle - controlsArea.rotation
//        }

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
