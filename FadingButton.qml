import QtQuick 2.0
import Ubuntu.Components 0.1
import "constants.js" as Const

AbstractButton {
    id: button
    property string iconSource

    property Image __active: icon1
    property Image __inactive: icon2

    onIconSourceChanged: {
        if (__active && __inactive) {
            __inactive.source = iconSource
            __active.opacity = 0.0
        } else icon1.source = iconSource
    }

    Image {
        id: icon1
        anchors.fill: parent
        Behavior on opacity {
            NumberAnimation {
                duration: Const.iconFadeDuration; easing.type: Easing.InOutQuad
            }
        }
    }

    Image {
        id: icon2
        anchors.fill: parent
        opacity: 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: Const.iconFadeDuration; easing.type: Easing.InOutQuad
            }
        }
    }

    Connections {
        target: __active
        onOpacityChanged: if (__active.opacity == 0.0) __inactive.opacity = 1.0
    }

    Connections {
        target: __inactive
        onOpacityChanged: {
            if (__inactive.opacity == 1.0) {
                var swap = __active
                __active = __inactive
                __inactive = swap
            }
        }
    }
}

