import QtQuick 2.0
import Ubuntu.Components 0.1

AbstractButton {
    width: text.paintedWidth + 10
    height: text.paintedHeight + 10

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.3
    }

    TextCustom {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 5
        anchors.leftMargin: 5

        id: text
        fontSize: "medium"
        text: "ZOOM"
        color: "white"
    }
}
