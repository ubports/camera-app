import QtQuick 2.0
import Ubuntu.Components 0.1 as SDK

Item {
    id: zoom
    property alias maximumValue: slider.maximumValue
    property alias value: slider.value
    property real zoomStep: (slider.maximumValue - slider.minimumValue) / 20

    SDK.AbstractButton {
        id: minus
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: minusIcon.width
        height: minusIcon.height
        onClicked: slider.value = Math.max(value - zoom.zoomStep, slider.minimumValue)

        Image {
            id: minusIcon
            anchors.centerIn: parent
            source: "assets/zoom_minus.png"
            sourceSize.height: 33
            smooth: true
        }
    }

    Slider {
        id: slider
        anchors.left: minus.right
        anchors.right: plus.left
        anchors.verticalCenter: parent.verticalCenter
        height: zoom.height

        live: true
        minimumValue: 1.0 // No zoom => 1.0 zoom factor

        backgroundDelegate: Image {
            source: Qt.resolvedUrl("assets/zoom_bar.png")
        }

        thumbDelegate: Image {
            source: Qt.resolvedUrl("assets/zoom_point.png")
            height: 16
            width: height
        }
    }

    SDK.AbstractButton {
        id: plus
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: plusIcon.width
        height: plusIcon.height
        onClicked: slider.value = Math.min(value + zoom.zoomStep, slider.maximumValue)

        Image {
            id: plusIcon
            anchors.centerIn: parent
            source: "assets/zoom_plus.png"
            sourceSize.height: 33
            smooth: true
        }
    }
}

