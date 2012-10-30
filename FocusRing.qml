import QtQuick 2.0
import Ubuntu.Components 0.1

Image {
    source: "assets/focus_ring.png"

    Behavior on opacity { NumberAnimation { duration: 500 } }
}
