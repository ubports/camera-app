import QtQuick 2.0
import Ubuntu.Components 0.1
import QtMultimedia 5.0

Rectangle {
    id: main
    width: units.gu(45)
    height: units.gu(80)
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
        orientation: -90

        FocusRing {
            id: focusRing
            height: units.gu(13)
            width: units.gu(13)
            opacity: 0.0
        }

        StopWatch {
            anchors.top: parent.top
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

    MouseArea {
        anchors.top: viewFinder.top
        anchors.bottom: zoomControl.top
        anchors.left: viewFinder.left
        anchors.right: viewFinder.right
        onClicked: {
            focusRing.x = mouse.x - focusRing.width * 0.5;
            focusRing.y = mouse.y - focusRing.height * 0.5;
            focusRing.opacity = 1.0;

            var focusPoint = viewFinder.mapPointToSourceNormalized(Qt.point(mouse.x, mouse.y));
            camera.focus.customFocusPoint = focusPoint;
        }
    }

    ZoomControl {
        id: zoomControl
        anchors.left: parent.left
        anchors.leftMargin: units.gu(0.75)
        anchors.rightMargin: units.gu(0.75)
        anchors.right: parent.right
        anchors.bottom: toolbar.top
        anchors.bottomMargin: units.gu(0.5)
        maximumValue: camera.maximumZoom
        height: units.gu(4.5)

        // Create a two way binding between the zoom control value and the actual camera zoom,
        // so that they can stay in sync when the zoom is changed from the UI or from the hardware
        Binding { target: zoomControl; property: "value"; value: camera.currentZoom }
        Binding { target: camera; property: "currentZoom"; value: zoomControl.value }
    }

    Toolbar {
        id: toolbar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: units.gu(1)
        anchors.leftMargin: units.gu(1)
        anchors.rightMargin: units.gu(1)

        camera: camera
    }
}
