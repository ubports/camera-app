import QtQuick 1.1

ToolbarButton {
    id: button

    states: [
        State { name: "off"
            PropertyChanges { target: button; source: "assets/flash_off.png" }
        },
        State { name: "on"
            PropertyChanges { target: button; source: "assets/flash_on.png" }
        },
        State { name: "auto"
            PropertyChanges { target: button; source: "assets/flash_auto.png" }
        }
    ]
}
