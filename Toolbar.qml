import QtQuick 1.1

Rectangle {
    id: toolbar
    color: "black" //#30000000"

    Behavior on y { NumberAnimation { duration: 500 } }
}
