import QtQuick 2.0
import QtMultimedia 5.0

Rectangle {
    id: main
    width: 720
    height: 1280
    color: "black"

    Component.onCompleted: camera.start()

    Camera {
        id: camera
        flash.mode: Camera.FlashOff
        captureMode: Camera.CaptureStillImage
        focus.focusMode: Camera.FocusAuto //TODO: Not sure if Continuous focus is better here
        focus.focusPointMode: focusRing.opacity > 0 ? Camera.FocusPointCustom : Camera.FocusPointAuto

        property int lastCaptureId: 0

        /* Use only digital zoom for now as it's what phone cameras mostly use.
           TODO: if optical zoom is available, maximumZoom should be the combined
           range of optical and digital zoom and currentZoom should adjust the two
           transparently based on the value. */
        property alias currentZoom: camera.digitalZoom
        property alias maximumZoom: camera.maximumDigitalZoom

        imageCapture {
            onCaptureFailed: {
                console.log("Capture failed for request " + requestId + ": " + message);
                camera.lastCaptureId = 0;
                focusRing.opacity = 0.0;
            }
            onImageCaptured: {
                camera.lastCaptureId = 0;
                focusRing.opacity = 0.0;
                snapshot.source = preview;
            }
            onImageSaved: {
                console.log("Picture saved as " + path)
            }
        }
    }

    VideoOutput {
        id: viewFinder
        anchors.fill: parent
        source: camera

        MouseArea {
            anchors.fill: parent
            onClicked: {
                focusRing.x = mouse.x - focusRing.width * 0.5;
                focusRing.y = mouse.y - focusRing.height * 0.5;
                focusRing.opacity = 1.0;
                zoomControl.opacity = 0.0;

                var focusPoint = viewFinder.mapPointToItemNormalized(Qt.point(mouse.x, mouse.y));
                camera.focus.customFocusPoint = focusPoint;
            }
        }

        FocusRing {
            id: focusRing
            opacity: 0.0
        }

        ZoomControl {
            id: zoomControl
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            opacity: 0.0

            maximumValue: camera.maximumZoom
            onValueChanged: {
                hideZoom.restart();
                camera.currentZoom = value;
            }

            Timer {
                id: hideZoom
                interval: 5000
                onTriggered: zoomControl.opacity = 0.0;
            }
        }

        StopWatch {
            anchors.top: zoomControl.bottom
            anchors.left: parent.left
            color: "red"
            opacity: camera.videoRecorder.recorderState == CameraRecorder.StoppedState ? 0.0 : 1.0
            time: camera.videoRecorder.duration / 1000
        }
    }

    Snapshot {
        id: snapshot
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        x: 0
    }

    ZoomButton {
        anchors.bottom: toolbar.top
        anchors.bottomMargin: 10
        x: toolbar.width * 0.5 - width * 0.5
        onClicked: {
            zoomControl.opacity = 1.0
            hideZoom.restart()
        }
    }

    Toolbar {
        id: toolbar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: 16
        anchors.leftMargin: 16
        anchors.rightMargin: 16

        camera: camera
    }
}
