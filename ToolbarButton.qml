import QtQuick 2.0
import Ubuntu.Components 0.1

AbstractButton {
    property alias iconWidth: icon.width
    property alias iconHeight: icon.height
    property alias iconSource: icon.source

    width: icon.paintedWidth
    height: icon.paintedHeight

    Image {
        id: icon
    }
}

