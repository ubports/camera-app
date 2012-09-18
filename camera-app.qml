import QtQuick 1.1

Rectangle {
    id: camera
    width: 400
    height: 600
    color: "black"

    LiveView {
        id: liveView
        anchors.fill: parent
    }

    Toolbar {
        id: toolbar
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        y: camera.height - 50
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
        drag.maximumY: camera.height - 50
        /* At end of drage either bring everything fully out or bring everything back in to hiding */
        onReleased: toolbar.y = (toolbar.y <= camera.height * 0.33) ? 0 : camera.height - 50
    }
}
