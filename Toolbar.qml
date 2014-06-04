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

import QtQuick 2.0
import QtMultimedia 5.0
import Ubuntu.Components 1.0

Item {
    id: toolbar

    function switchFlashMode() {
        if (flashButton.torchMode) {
            camera.flash.mode = (flashButton.flashState == "on") ?
                                Camera.FlashOff : Camera.FlashVideoLight;
        } else {
            camera.flash.mode = (flashButton.flashState == "off") ? Camera.FlashOn :
                                ((flashButton.flashState == "on") ? Camera.FlashAuto : Camera.FlashOff);
        }
    }

    FlashButton {
        id: flashButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: parent.iconSpacing

        height: toolbar.iconHeight
        width: toolbar.iconWidth
        visible: !application.desktopMode
        enabled: toolbar.opacity > 0.0
        rotation: iconsRotation

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

        onClicked: toolbar.switchFlashMode()

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
        rotation: iconsRotation

        // Disabled the video recording button for V1.0 since the feature is broken, leave it enabled for desktopMode
        enabled: application.desktopMode
        opacity: 0.5

        width: toolbar.iconWidth
        height: toolbar.iconHeight
        iconSource: camera.captureMode == Camera.CaptureVideo ? "assets/record_picture.png" : "assets/record_video.png"
        onClicked: toolbar.changeRecordMode()
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

            onClicked: toolbar.shoot()
            enabled: toolbar.canCapture
            opacity: enabled ? 1.0 : 0.5
        }
    }

}
