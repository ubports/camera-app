import QtQuick 1.1

Rectangle {
    id: toolbar
    color: "#30000000"

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
        }

        ToolbarButton {
            anchors.left: parent.left
            source: "assets/flash_off.png"
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
