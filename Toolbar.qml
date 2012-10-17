import QtQuick 2.0
import QtMultimedia 5.0

Item {
    id: toolbar

    property Camera camera
    signal recordClicked()
    signal zoomClicked()

    Behavior on opacity { NumberAnimation { duration: 500 } }

    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 75
        width: 50
        height: childrenRect.height
        spacing: 50

        RecordControl {
            anchors.left: parent.left
            state: camera.isRecording ? "on" : "off"
            onClicked: camera.isRecording = !camera.isRecording
            enabled: toolbar.opacity > 0.0
        }

        FlashButton {
            anchors.left: parent.left

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
            enabled: toolbar.opacity > 0.0
        }
    }

    Column {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 75
        width: 50
        height: childrenRect.height
        spacing: 50

        ToolbarButton {
            anchors.right: parent.right
            source: "assets/swap_camera.png"
        }

        ToolbarButton {
            anchors.right: parent.right
            source: "assets/gallery.png"
        }
    }

    Item {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50

        ToolbarButton {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            source: "assets/zoom.png"
            onClicked: zoomClicked()
            enabled: toolbar.opacity > 0.0
        }
    }
}
