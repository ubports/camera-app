import QtQuick 1.1

/* This control is by default entirely meant to be right aligned and operated with the right thumb.
   However setting the leftHanded property to true will allow to anchor it on the left side and operate
   it via the left thumb. This should be completely transparent in the code since all calculations
   are done for the right handed case and QT takes care of flipping everything using Item.transform.
*/
Item {
    id: arc
    property int zoomLevels: 10
    property int zoom: 5
    property bool leftHanded: false

    property variant center
    center: { return { x: width, y: height } }

    Image {
        anchors.fill: parent

        source: "assets/zoom_arc.svg"
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width
    }

    Image {
        id: handle
        anchors.fill: parent

        property double angle: 0
        property double maxAngle: 85 //FIXME: This is arbitrary, need to be calculated according to cursor size
        property double baseAngle
        baseAngle: {
            var base = { x: width, y: height };
            var dpx = base.x - arc.center.x;
            var dpy = base.y - arc.center.y;
            return Math.atan2(dpy, dpx);
        }

        source: "assets/zoom_cursor.svg"
        smooth: true
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width

        rotation: angle
        transformOrigin: { x: width; y: height }

        MouseArea {
            anchors.fill: parent
            property bool dragging: false
            onPressed: dragging = true
            onPositionChanged: if (dragging) {
                var dragPoint = mapToItem(arc, mouse.x, mouse.y)
                var dx = dragPoint.x - arc.center.x;
                var dy = dragPoint.y - arc.center.y;
                var currentAngle = radToDeg(Math.atan2(dy, dx) - handle.baseAngle) + 180;

                if (currentAngle < 0 || currentAngle > handle.maxAngle) return;

                handle.angle = currentAngle;
                var level = Math.round(currentAngle * arc.zoomLevels / handle.maxAngle);
                if (level != arc.zoom) arc.zoom = level;
            }
            onReleased: dragging = false

            function radToDeg(rad) {
                return (rad * (180 / Math.PI));
            }
        }
    }

    Rotation {
        id: flip

        origin.x: width / 2;
        origin.y: height / 2;
        axis.x:0; axis.y:1; axis.z:0
        angle:180
    }

    transform: leftHanded ? flip : null
}
