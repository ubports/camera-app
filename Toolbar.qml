/*
 * Copyright 2012 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtMultimedia 5.0
import Ubuntu.Components 0.1

Item {
    id: toolbar

    property Camera camera
    signal recordClicked()
    signal zoomClicked()

    Behavior on opacity { NumberAnimation { duration: 500 } }

    height: middle.height
    property int iconWidth: units.gu(6)
    property int iconHeight: units.gu(5)
    property bool canCapture

    BorderImage {
        id: leftBackground
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: middle.left
        anchors.topMargin: units.dp(2)
        anchors.bottomMargin: units.dp(2)
        source: "assets/toolbar-left.sci"

        property int iconSpacing: (width - toolbar.iconWidth * children.length) / 3

        FlashButton {
            id: flashButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.iconSpacing

            height: toolbar.iconHeight
            width: toolbar.iconWidth
            enabled: toolbar.opacity > 0.0

            Connections {
                target: camera.advanced
                onActiveCameraIndexChanged: {
                    if (camera.advanced.activeCameraIndex == 1) {
                        camera.flash.mode = Camera.FlashOff;
                        flashButton.previousFlashMode = Camera.FlashOff;
                    }
                }
            }

            torchMode: camera.captureMode == Camera.CaptureVideo
            flashState: { switch (camera.flash.mode) {
                case Camera.FlashAuto: return "auto";
                case Camera.FlashOn:
                case Camera.FlashVideoLight: return "on";
                case Camera.FlashOff:
                default: return "off"
            }}

            onClicked: {
                if (torchMode) {
                    camera.flash.mode = (flashState == "on") ?
                                        Camera.FlashOff : Camera.FlashVideoLight;
                } else {
                    camera.flash.mode = (flashState == "off") ? Camera.FlashOn :
                                        ((flashState == "on") ? Camera.FlashAuto : Camera.FlashOff);
                }
            }

            property variant previousFlashMode: Camera.FlashOff

            onTorchModeChanged: {
                var previous = camera.flash.mode;
                camera.flash.mode = previousFlashMode;
                previousFlashMode = previous;
            }
        }

        FadingButton {
            id: recordModeButton
            objectName: "recordModeButton"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: flashButton.right
            anchors.leftMargin: parent.iconSpacing

            enabled: toolbar.opacity > 0.0

            width: toolbar.iconWidth
            height: toolbar.iconHeight
            iconSource: camera.captureMode == Camera.CaptureVideo ? "assets/record_video.png" : "assets/record_picture.png"
            onClicked: {
                if (camera.captureMode == Camera.CaptureVideo) camera.videoRecorder.stop()
                camera.captureMode = (camera.captureMode == Camera.CaptureVideo) ? Camera.CaptureStillImage : Camera.CaptureVideo
            }
        }
    }

    BorderImage {
        id: middle
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: shootButton.height + units.gu(1)
        source: "assets/toolbar-middle.sci"

        ShootButton {
            id: shootButton
            anchors.centerIn: parent
            iconWidth: units.gu(8)
            iconHeight: units.gu(8)
            state: (camera.captureMode == Camera.CaptureVideo) ?
                   ((camera.videoRecorder.recorderState == CameraRecorder.StoppedState) ? "record_off" : "record_on") :
                   "camera"

            onClicked: {
                if (camera.captureMode == Camera.CaptureVideo) {
                    if (camera.videoRecorder.recorderState == CameraRecorder.StoppedState) {
                        camera.videoRecorder.record()
                    } else {
                        camera.videoRecorder.stop()
                        // TODO: there's no event to tell us that the video has been successfully recorder or failed,
                        // and no preview to slide off anyway. Figure out what to do in this case.
                    }
                } else {
                    camera.imageCapture.capture()
                }
            }
            enabled: toolbar.canCapture
            opacity: enabled ? 1.0 : 0.5
        }
    }

    BorderImage {
        id: rightBackground
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: middle.right
        anchors.topMargin: units.dp(2)
        anchors.bottomMargin: units.dp(2)
        source: "assets/toolbar-right.sci"

        property int iconSpacing: (width - toolbar.iconWidth * children.length) / 3

        ToolbarButton {
            id: swapButton
            objectName: "swapButton"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: galleryButton.left
            anchors.rightMargin: parent.iconSpacing

            enabled: toolbar.opacity > 0.0

            iconWidth: toolbar.iconWidth
            iconHeight: toolbar.iconHeight
            iconSource: "assets/swap_camera.png"

            onClicked: camera.advanced.activeCameraIndex = (camera.advanced.activeCameraIndex === 0) ? 1 : 0
        }

        ToolbarButton {
            id: galleryButton
            objectName: "galleryButton"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: parent.iconSpacing

            enabled: toolbar.opacity > 0.0

            iconWidth: toolbar.iconWidth
            iconHeight: toolbar.iconHeight
            iconSource: "assets/gallery.png"

            onClicked: console.log("Functionality not supported yet")
        }
    }
}
