import QtQuick 1.1

Rectangle {
    id: main
    width: 400
    height: 600
    color: "black"

    Camera {
        id: camera
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            onClicked: toolbar.state = (toolbar.state == "shown") ? "hidden" : "shown"
        }
    }

    Toolbar {
        id: toolbar
        anchors.fill: parent
        camera: camera
        state: "hidden"
    }
}
