import QtQuick 2.0
import QtMultimedia 5.0
import Qt.labs.folderlistmodel 1.0
import "PhotoViewer"

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

                var focusPoint = viewFinder.mapPointToSourceNormalized(Qt.point(mouse.x, mouse.y));
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

        camera: camera
        onToggleViewerClicked: viewer.x = viewer.onScreen ? main.width : 0
    }

    PhotoViewer {
        id: viewer
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: parent.width
        width: parent.width

        model: FolderListModel {
            folder: picturesDirectory
            nameFilters: ["*.jpeg", "*.JPEG", "*.jpg", "*.JPG", "*.png", "*.PNG"]
            showDirs: false
            sortField: FolderListModel.Time
        }

        delegate: PhotoComponent {
            width: viewer.width
            height: viewer.height
            source: filePath
        }

        property bool onScreen: x == 0
        Behavior on x { NumberAnimation { duration: 500 } }


        // We want to overshoot boundaries on the right but not on the left, and when we
        // are dragging from the left side we want to slide away the entire viewer.
        // FIXME: the only way i found to do this is with the following hack using a timer to detect
        // when we've been flicking or dragging for a bit and the contentX is still zero. There may be
        // a better way.
        onContentXChanged: if (contentX <= 0) contentX = 0; else viewerSlideOff.stop()
        onMovingHorizontallyChanged: if (movingHorizontally && contentX == 0) viewerSlideOff.restart()
        onFlickingHorizontallyChanged: if (flickingHorizontally && contentX == 0) viewerSlideOff.restart()
        Timer {
            id: viewerSlideOff
            onTriggered: viewer.x = main.width
            interval: 50
        }
    }

    MouseArea {
        id: photoViewerSliderOut
        anchors.top: parent.top
        anchors.bottom: toolbar.top
        anchors.left: parent.left
        anchors.right: parent.right

        propagateComposedEvents: true
        property int dragStart: 0
        property int dragEnd: 0
        property int dragThreshold: 50
        onPressed: dragStart = mouse.x
        onReleased: dragEnd = mouse.x
        drag {
            target: viewer
            axis: Drag.XAxis
            maximumX: parent.width
            minimumX: 0
            filterChildren: true
            onActiveChanged: {
                if (!drag.active) {
                    if (dragStart - dragEnd >= dragThreshold) viewer.x = 0
                    else viewer.x = main.width
                }
            }
        }

        enabled: !viewer.onScreen
    }
}
