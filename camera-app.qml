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
            onClicked: {
                toolbar.opacity = 1.0;
                ring.x = mouse.x - ring.width * 0.5;
                ring.y = mouse.y - ring.height * 0.5;
                ring.opacity = 1.0;
                zoomRight.opacity = zoomLeft.opacity = 0.0
                // TODO: call the spot focusing API here
            }
        }

        FocusRing {
            id: ring
            opacity: 0.0
            onClicked: camera.takeSnapshot()
        }

        ZoomControl {
            id: zoomRight
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.width / 2
            width: height
            opacity: 0.0

            zoomLevels: camera.zoomLevels
            onZoomingChanged: if (zooming) { zoomLeft.opacity = 0.0; zoomRight.opacity = 1.0 }
                              else hideZoom.restart();
            onZoomChanged: camera.startZoom(zoom)
        }

        ZoomControl {
            id: zoomLeft
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            height: parent.width / 2
            width: height
            opacity: 0.0

            leftHanded: true
            zoomLevels: camera.zoomLevels
            onZoomingChanged: if (zooming) { zoomRight.opacity = 0.0; zoomLeft.opacity = 1.0 }
                              else hideZoom.restart();
            onZoomChanged: camera.startZoom(zoom)
        }

        onIsRecordingChanged: if (isRecording) ring.opacity = 0.0
        onSnapshotSuccess: {
            snapshot.source = imagePath
            console.log("snapshot successfully taken");
            ring.opacity = 0.0
            toolbar.opacity = 0.0
        }
    }

    Snapshot {
        id: snapshot
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: 0
    }

    Binding {

    }

    Toolbar {
        id: toolbar
        anchors.fill: parent
        camera: camera
        opacity: 0.0
        onZoomClicked: {
            zoomLeft.opacity = zoomRight.opacity = 0.75;
            console.log(camera.zoomLevel + " " + zoomLeft.zooming)
            zoomLeft.zoom = zoomRight.zoom = camera.zoomLevel; // set the zoom controls to the current camera zoom level
            toolbar.opacity = 0.0;
            ring.opacity = 0.0;
        }

        Timer {
            id: hideZoom
            interval: 5000
            onTriggered: zoomLeft.opacity = zoomRight.opacity = 0.0;
        }
    }
}
