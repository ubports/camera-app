// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Item {
    height: snapshot.paintedHeight
    width: snapshot.paintedWidth

    property alias source: snapshot.source

    Rectangle {
        id: shade
        color: "white"
        opacity: 0.75
        visible: snapshot.opacity == 1.0
        anchors.fill: parent
    }

    Image {
        id: snapshot
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        asynchronous: true
        opacity: 0.0
        fillMode: Image.PreserveAspectCrop
        sourceSize.height: parent.height

        Behavior on x {
            SequentialAnimation {
                NumberAnimation { duration: 800 }
                PropertyAction { target: snapshot; property: "opacity"; value: 0.0 }
                PropertyAction { target: snapshot; property: "source"; value: "" }
                PropertyAction { target: snapshot; property: "x"; value: 0 }
            }
        }

        onStatusChanged: {
            if (status == Image.Ready) {
                opacity = 1.0
                x = parent.width
            }
        }
    }
}
