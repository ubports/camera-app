import QtQuick 1.1
import "CameraEnums.js" as CameraEnums

Item {
    id: toolbar

    property Camera camera

    Behavior on y { NumberAnimation { duration: 500 } }
    Behavior on opacity { NumberAnimation { duration: 500 } }

    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: 50
        height: childrenRect.height
        spacing: 50

        RecordControl {
            anchors.left: parent.left
            state: camera.isRecording ? "on" : "off"
            onClicked: camera.isRecording = !camera.isRecording
        }

        FlashButton {
            anchors.left: parent.left

            flashAllowed: !camera.isRecording

            state: { switch (camera.flashMode) {
                case CameraEnums.FlashModeOff: return (flashAllowed) ? "off_flash" : "off_torch";
                case CameraEnums.FlashModeOn: return "on";
                case CameraEnums.FlashModeTorch: return "torch";
                case CameraEnums.FlashModeAuto: return "auto";
            }}

            onClicked: { switch (state) {
                case "off_torch":
                case "off_flash": camera.flashMode = (flashAllowed) ? CameraEnums.FlashModeOn :
                                                                      CameraEnums.FlashModeTorch; break;
                case "on": camera.flashMode = CameraEnums.FlashModeAuto; break;
                case "auto": camera.flashMode = CameraEnums.FlashModeTorch; break;
                case "torch": camera.flashMode = CameraEnums.FlashModeOff; break;
            }}
        }
    }

    Column {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
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
        }
    }

    states: [
        State { name: "shown"
           PropertyChanges { target: toolbar; opacity: 1.0 }
        },
        State { name: "hidden"
           PropertyChanges { target: toolbar; opacity: 0.0 }
        }
    ]
}
