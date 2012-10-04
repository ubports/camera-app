import QtQuick 2.0

ToolbarButton {
    id: button

    property bool flashAllowed: true

    states: [
        State { name: "off_flash"
            PropertyChanges { target: button; source: "assets/flash_off.png" }
        },
        State { name: "off_torch"
            PropertyChanges { target: button; source: "assets/torch_off.png" }
        },
        State { name: "on"
            PropertyChanges { target: button; source: "assets/flash_on.png" }
        },
        State { name: "auto"
            PropertyChanges { target: button; source: "assets/flash_auto.png" }
        },
        State { name: "torch"
            PropertyChanges { target: button; source: "assets/torch_on.png" }
        }
    ]
}
