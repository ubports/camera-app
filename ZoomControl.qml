import QtQuick 1.1

Item {
    id: box
    property int zoomLevels: 10
    property int zoom: 5
    property bool flipped: false

    property variant center
    center: { return { x: width, y: height } }
    property double baseAngle
    baseAngle: {
        var base = { x: width, y: height };
        var dpx = base.x - box.center.x;
        var dpy = base.y - box.center.y;
        return Math.atan2(dpy, dpx);
    }

    Image {
        id: arc
        anchors.fill: parent

        source: "assets/zoom_arc.svg"
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width
    }

    Image {
        id: handle
        anchors.fill: parent

        // FIXME: the 85 max angle is arbitrary, need a way to properly calculate it
        // based on the image size.
        property double maxAngle: 85
        property double angle: 0

        source: "assets/zoom_cursor.svg"
        smooth: true
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width

        rotation: angle
        transformOrigin: { x: width; y: height }

        MouseArea {
            anchors.fill: parent
            property bool dragging: false
            onPressAndHold: dragging = true
            onReleased: dragging = false
            onPositionChanged: {
                var drag = mapToItem(box, mouse.x, mouse.y)
                var dx = drag.x - box.center.x;
                var dy = drag.y - box.center.y;
                var a = Math.atan2(dy, dx);

                var angle = radToDeg(a - box.baseAngle) + 180;
                if (angle >= 0 && angle <= 85) handle.angle = angle;

            }
        }
    } 

    function constraintPos(x, y) {
        var result = limit(x, y);
        var angle = radToDeg(result.rad) - handle.angle
        return angle;
    }

    function limit(x, y) {
        var dist = distance([x, y], box.center);
        var radians = Math.atan2((y - box.center[1]), (x - box.center[0]));
        return {
            x:       Math.cos(radians) * box.width,
            y:       Math.sin(radians) * box.width,
            rad:     radians
        }
    }

    function distance(dot1, dot2) {
        var x1 = dot1[0], y1 = dot1[1], x2 = dot2[0], y2 = dot2[1];
        return Math.sqrt(Math.pow((x1 - x2), 2) + Math.pow((y1 - y2), 2));
    }

    function radToDeg(rad) {
        return (rad * (180 / Math.PI));
    }

    Rotation {
        id: flip

        origin.x: width / 2;
        origin.y: height / 2;
        axis.x:0; axis.y:1; axis.z:0
        angle:180
    }

    transform: flipped ? flip : null
}
