import QtQuick 2.0
import Ubuntu.Components 0.1

AbstractButton {
    width: 50
    height: 50

    property alias source: icon.source

    /* Temporary background so we see well where the icons are.
       FIXME: remove it when visual design is complete and we have more visible icons */
    Rectangle {
        anchors.fill: parent
        color: "#DDFFFFFF"
    }

    Image {
        id: icon
        anchors.left: parent.left
        anchors.top: parent.top
    }
}

