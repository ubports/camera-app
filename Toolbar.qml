import QtQuick 2.0
import QtMultimedia 5.0
import Ubuntu.Components 0.1

Item {
    id: toolbar

    property Camera camera
    signal recordClicked()
    signal zoomClicked()

    height: buttons.height + 20

    Behavior on opacity { NumberAnimation { duration: 500 } }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
        opacity: 0.35
    }

    Row {
        id: buttons
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        property int effectiveWidth: (toolbar.width - spacing * (buttons.children.length - 1))
                                     - anchors.leftMargin - anchors.rightMargin
        height: effectiveWidth / buttons.children.length
        spacing: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 10

        FlashButton {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.height

            enabled: toolbar.opacity > 0.0
            flashAllowed: !camera.isRecording

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
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.height

            enabled: toolbar.opacity > 0.0

            iconSource: camera.isRecording ? "assets/record_on.png" : "assets/record_off.png"
            onClicked: camera.isRecording = !camera.isRecording
        }

        ToolbarButton {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.height
            iconSource: "assets/camera.png"
            onClicked: camera.lastCaptureId = camera.imageCapture.capture()
            enabled: camera.lastCaptureId == 0
        }

        ToolbarButton {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.height

            enabled: toolbar.opacity > 0.0

            iconSource: "assets/swap_camera.png"

            onClicked: console.log("Functionality not supported yet")
        }

        ToolbarButton {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.height

            enabled: toolbar.opacity > 0.0

            iconSource: "assets/gallery.png"

            onClicked: console.log("Functionality not supported yet")
        }
    }
}
