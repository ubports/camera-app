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
                // TODO: call the spot focusing API here
            }
        }

        FocusRing {
            id: ring
            opacity: 0.0
            onClicked: camera.takeSnapshot()
        }

        ZoomControl {
            id: zoom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.width / 2
            width: height

            zoomLevels: 10
            zoom: 10
        }

        ZoomControl {
            id: zoom2
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            height: parent.width / 2
            width: height

            zoomLevels: 10
            zoom: 1

            flipped: true
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

    Toolbar {
        id: toolbar
        anchors.fill: parent
        camera: camera
        opacity: 0.0
    }
}
