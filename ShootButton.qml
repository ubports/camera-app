import QtQuick 2.0

ToolbarButton {
    id: button

    states: [
        State { name: "camera"
            PropertyChanges { target: button; iconSource: "assets/shoot.png" }
            PropertyChanges { target: recordOn; opacity: 0.0 }
            PropertyChanges { target: pulseAnimation; running: false }
        },
        State { name: "record_off"
            PropertyChanges { target: button; iconSource: "assets/record_off.png" }
            PropertyChanges { target: recordOn; opacity: 0.0 }
            PropertyChanges { target: pulseAnimation; running: false }
        },
        State { name: "record_on"
            PropertyChanges { target: button; iconSource: "assets/record_off.png" }
            PropertyChanges { target: recordOn; opacity: 1.0 }
            PropertyChanges { target: pulseAnimation; running: true }
        }
    ]

    property int pulsePeriod: 750

    Image {
        id: recordOn
        anchors.fill: parent
        source: "assets/record_on.png"
        Behavior on opacity { NumberAnimation { duration: pulsePeriod } }
    }

    Image {
        id: pulse
        anchors.fill: parent
        source: "assets/record_on_pulse.png"
        opacity: 0.0

        SequentialAnimation on opacity  {
            id: pulseAnimation
            loops: Animation.Infinite
            alwaysRunToEnd: true
            running: false

            PropertyAnimation {
                from: 0
                to: 1.0
                duration: pulsePeriod
            }
            PropertyAnimation {
                from: 1.0
                to: 0
                duration: pulsePeriod
            }
        }
    }
}
