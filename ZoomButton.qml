import QtQuick 2.0
import Ubuntu.Components 0.1

AbstractButton {
    width: text.paintedWidth + units.dp(5)
    height: text.paintedHeight + units.dp(5)

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.3
    }

    TextCustom {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: units.dp(2)
        anchors.leftMargin: units.dp(2)

        id: text
        fontSize: "medium"
        text: "ZOOM"
        color: "white"
    }
}
