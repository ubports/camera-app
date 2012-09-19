import QtQuick 1.1
import "CameraEnums.js" as CameraEnums

Rectangle {
    id: toolbar
    color: "#30000000"

    property Camera camera

    Behavior on y { NumberAnimation { duration: 500 } }

    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: 50
        height: childrenRect.height
        spacing: 50

        ToolbarButton {
            anchors.left: parent.left
            source: "assets/record_off.png"

            onClicked: console.log("click")
        }

        FlashButton {
            anchors.left: parent.left
            state: { switch (camera.flashMode) {
                case CameraEnums.FlashOff: return "off";
                case CameraEnums.FlashOn: return "on";
                case CameraEnums.FlashAuto:
                default: return "auto";
            }}

            onClicked: { switch (state) {
                case "off": camera.flashMode = CameraEnums.FlashOn; break;
                case "on": camera.flashMode = CameraEnums.FlashAuto; break;
                case "auto":
                default: camera.flashMode = CameraEnums.FlashOff; break;
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
}
