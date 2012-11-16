import QtQuick 2.0

Item {
    id: button

    property bool flashAllowed: true
    property bool torchMode: false
    property string flashState: "off"
    signal clicked()

    CrossFadingButton {
        id: flash
        anchors.fill: parent
        iconSource: (flashState == "off") ? "assets/flash_off.png" :
                    ((flashState == "on") ? "assets/flash_on.png" : "assets/flash_auto.png")
        onClicked: button.clicked()
        enabled: !torchMode
    }

    CrossFadingButton {
        id: torch
        anchors.fill: parent
        iconSource: (flashState == "on") ? "assets/torch_on.png" : "assets/torch_off.png"
        enabled: torchMode
        onClicked: button.clicked()
    }

    states: [
        State { name: "flash"; when: !torchMode
            PropertyChanges { target: flash; opacity: 1.0 }
            PropertyChanges { target: torch; opacity: 0.0 }
        },
        State { name: "torch"; when: torchMode
            PropertyChanges { target: flash; opacity: 0.0 }
            PropertyChanges { target: torch; opacity: 1.0 }
        }
    ]

    transitions: [
        Transition { from: "flash"; to: "torch";
            SequentialAnimation {
                NumberAnimation { target: flash; property: "opacity"; duration: 500 }
                NumberAnimation { target: torch; property: "opacity"; duration: 500 }
            }
        },
        Transition { from: "torch"; to: "flash";
            SequentialAnimation {
                NumberAnimation { target: torch; property: "opacity"; duration: 500 }
                NumberAnimation { target: flash; property: "opacity"; duration: 500 }
            }
        }
    ]
}
