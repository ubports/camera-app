import QtQuick 1.0
import Ubuntu.Components 0.1

Item {
    property int time: 0
    property alias elapsed: count.text
    property alias fontSize: count.fontSize
    property alias color: count.color

    height: count.paintedHeight + 8 * 2
    width: count.paintedWidth + 22 * 2

    // FIXME: define all properties in one block

    function pad(text, length) {
        while (text.length < length) text = '0' + text;
        return text;
    }

    TextCustom {
        id: count

        anchors.centerIn: parent
        color: "white"
        // FIXME: factor into a named function
        text: {
            var divisor_for_minutes = time % (60 * 60);
            var minutes = String(Math.floor(divisor_for_minutes / 60));

            var divisor_for_seconds = divisor_for_minutes % 60;
            var seconds = String(Math.ceil(divisor_for_seconds));

            return "%1:%2".arg(pad(minutes, 2)).arg(pad(seconds, 2));
        }
        fontSize: "large"
    }
}
