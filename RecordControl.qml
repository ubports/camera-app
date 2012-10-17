import QtQuick 2.0

Item {
    id: record

    states: [
        State { name: "off"
            PropertyChanges { target: counter; opacity: 0.0 }
            PropertyChanges { target: timer; running: false; startTime: 0 }
        },
        State { name: "on"
            PropertyChanges { target: counter; opacity: 1.0 }
            PropertyChanges { target: timer; running: true; startTime: Date.now() }
        }
    ]

    StopWatch {
        id: counter
        anchors.left: parent.left
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
