import QtQuick 1.1

Rectangle {
    id: main
    width: 400
    height: 600
    color: "black"

    Camera {
        id: camera
        anchors.fill: parent
    }

    Toolbar {
        id: toolbar
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        y: main.height - 50
        camera: camera
    }

    /* temporary drag area to bring up the UI */
    MouseArea {
        id: toolbarDrag
        y: parent.height - height
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        drag.target: toolbar
        drag.axis: Drag.YAxis
        drag.minimumY: 0
        drag.maximumY: main.height - 50
        /* At end of drage either bring everything fully out or bring everything back in to hiding */
        onReleased: toolbar.y = (toolbar.y <= main.height * 0.66) ? 0 : main.height - 50
        enabled: toolbar.y != 0
    }
}
