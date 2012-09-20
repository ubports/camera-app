import QtQuick 1.1
import "CameraEnums.js" as CameraEnums

/* This component is a mock of the real camera comonent, to
   allow prototyping of the UI even when we don't have actual camera hardware
   It is a QML-ized version of the API described here:
   https://bazaar.launchpad.net/~rocket-scientists/aal%2B/trunk/view/head%3A/compat/camera/camera_compatibility_layer.h
*/

Image {
    source: "dummydata/live_view.jpg"
    sourceSize.width: width
    sourceSize.height: height
    fillMode: Image.PreserveAspectCrop

    property string flashMode: CameraEnums.FlashModeOff
}
