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
    property int iconWidth: 92
    property int iconHeight: 76

    BorderImage {
        id: leftBackground
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: middle.left
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        source: "assets/toolbar-left.sci"

        property int iconSpacing: (width - toolbar.iconWidth * children.length) / 3

        FlashButton {
            id: flashButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.iconSpacing

            iconHeight: toolbar.iconHeight
            iconWidth: toolbar.iconWidth
            enabled: toolbar.opacity > 0.0
            flashAllowed: camera.captureMode != Camera.CaptureVideo
            onFlashAllowedChanged: {
                if (camera.flash.mode == Camera.FlashOff) camera.flash.mode = Camera.FlashOff
                else camera.flash.mode = (flashAllowed) ? Camera.FlashAuto : Camera.FlashTorch
            }

            state: { switch (camera.flash.mode) {
                case Camera.FlashOff: return (flashAllowed) ? "off_flash" : "off_torch";
                case Camera.FlashOn: return "on";
                case Camera.FlashTorch: return "torch";
                case Camera.FlashAuto: return "auto";
            }}

            onClicked: { switch (state) {
                case "off_torch":
                case "off_flash": camera.flash.mode = (flashAllowed) ? Camera.FlashOn :
                                                                       Camera.FlashTorch; break;
                case "on": camera.flash.mode = Camera.FlashAuto; break;
                case "auto": camera.flash.mode = Camera.FlashTorch; break;
                case "torch": camera.flash.mode = Camera.FlashOff; break;
            }}
        }

        ToolbarButton {
            id: recordModeButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: flashButton.right
            anchors.leftMargin: parent.iconSpacing

            enabled: toolbar.opacity > 0.0

            iconWidth: toolbar.iconWidth
            iconHeight: toolbar.iconHeight
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
        height: shootButton.height + 20
        source: "assets/toolbar-middle.sci"

        ShootButton {
            id: shootButton
            anchors.centerIn: parent
            iconWidth: 126
            iconHeight: 134
            state: if (camera.captureMode == Camera.CaptureVideo) {
                       return (camera.videoRecorder.recorderState == CameraRecorder.StoppedState) ? "record" : "pulsing"
                   } else return "camera"

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
                    camera.lastCaptureId = camera.imageCapture.capture()
                }
            }
            enabled: camera.lastCaptureId == 0
        }
    }

    BorderImage {
        id: rightBackground
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: middle.right
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        source: "assets/toolbar-right.sci"

        property int iconSpacing: (width - toolbar.iconWidth * children.length) / 3

        ToolbarButton {
            id: swapButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: galleryButton.left
            anchors.rightMargin: parent.iconSpacing

            enabled: toolbar.opacity > 0.0

            iconWidth: toolbar.iconWidth
            iconHeight: toolbar.iconHeight
            iconSource: "assets/swap_camera.png"

            onClicked: console.log("Functionality not supported yet")
        }

        ToolbarButton {
            id: galleryButton
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
