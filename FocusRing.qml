import QtQuick 2.0
import Ubuntu.Components 0.1

Image {
    source: "assets/focus_ring.svg"
    sourceSize.width: 120
    sourceSize.height: 120

    Behavior on opacity { NumberAnimation { duration: 500 } }
}
