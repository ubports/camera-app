import QtQuick 2.0

ToolbarButton {
    id: button

    states: [
        State { name: "camera"
            PropertyChanges { target: button; iconSource: "assets/shoot.png" }
            PropertyChanges { target: button; opacity: 1.0 }
            PropertyChanges { target: pulseTimer; running: false }
        },
        State { name: "record"
            PropertyChanges { target: button; iconSource: "assets/record_on.png" }
            PropertyChanges { target: button; opacity: 1.0 }
            PropertyChanges { target: pulseTimer; running: false }
        },
        State { name: "pulsing"
            PropertyChanges { target: button; iconSource: "assets/record_on.png" }
            PropertyChanges { target: pulseTimer; running: true }
        }
    ]

    Behavior on opacity { NumberAnimation { duration: button.pulsePeriod; easing: Easing.InOutExpo } }

    property int pulsePeriod: 500

    Timer {
        id: pulseTimer
        interval: button.pulsePeriod
        repeat: true
        triggeredOnStart: true
        onTriggered: button.opacity = (button.opacity == 0.0) ? 1.0 : 0.0
    }
}
