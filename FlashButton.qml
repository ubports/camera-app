import QtQuick 2.0

ToolbarButton {
    id: button

    property bool flashAllowed: true

    states: [
        State { name: "off_flash"
            PropertyChanges { target: button; iconSource: "assets/flash_off.png" }
        },
        State { name: "off_torch"
            PropertyChanges { target: button; iconSource: "assets/torch_off.png" }
        },
        State { name: "on"
            PropertyChanges { target: button; iconSource: "assets/flash_on.png" }
        },
        State { name: "auto"
            PropertyChanges { target: button; iconSource: "assets/flash_auto.png" }
        },
        State { name: "torch"
            PropertyChanges { target: button; iconSource: "assets/torch_on.png" }
        }
    ]
}
