import QtQuick 2.0

Item {
    id: record

    signal clicked()
    height: button.height
    width: button.width

    states: [
        State { name: "off"
            PropertyChanges { target: button; source: "assets/record_off.png" }
            PropertyChanges { target: counter; opacity: 0.0 }
            PropertyChanges { target: timer; running: false; startTime: 0 }
        },
        State { name: "on"
            PropertyChanges { target: button; source: "assets/record_on.png" }
            PropertyChanges { target: counter; opacity: 1.0 }
            PropertyChanges { target: timer; running: true; startTime: Date.now() }
        }
    ]

    ToolbarButton {
        id: button
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        onClicked: record.clicked()
    }

    StopWatch {
        id: counter
        anchors.left: button.right
        anchors.verticalCenter: parent.verticalCenter
        color: "red"
    }

    Timer {
        id: timer
        interval: 1000
        repeat: true
        triggeredOnStart: true

        onTriggered: counter.time = (Date.now() - timer.startTime) / 1000

        // variant is needed as Date.now is unsigned long and QML int is signed
        property variant startTime: 0

    }
}
