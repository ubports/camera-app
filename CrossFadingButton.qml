import QtQuick 2.0
import Ubuntu.Components 0.1

AbstractButton {
    id: button
    property string iconSource

    property Image __active: icon1
    property Image __inactive: icon2

    onIconSourceChanged: {
        if (__active && __inactive) {
            __inactive.source = iconSource
            __active.opacity = 0.0
            __inactive.opacity = 1.0
            var swap = __active
            __active = __inactive
            __inactive = swap
        } else icon1.source = iconSource
    }

    Image {
        id: icon1
        anchors.fill: parent
        Behavior on opacity { NumberAnimation { duration: 500 } }
    }

    Image {
        id: icon2
        anchors.fill: parent
        opacity: 0.0
        Behavior on opacity { NumberAnimation { duration: 500 } }
    }
}

