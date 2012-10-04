import QtQuick 2.0
import Ubuntu.Components 0.1

Image {
    source: "assets/focus_ring.svg"
    sourceSize.width: 120
    sourceSize.height: 120

    signal clicked()

    Behavior on opacity { NumberAnimation { duration: 500 } }

    AbstractButton {
        anchors.centerIn: parent
        width: icon.paintedWidth
        height: icon.paintedHeight

        Image {
            id: icon
            source: "assets/camera.png"
        }

        onClicked: ring.clicked()
    }
}
