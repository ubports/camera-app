import QtQuick 1.1
import "CameraEnums.js" as CameraEnums

/* This component is a mock of the real camera component with live preview, to
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

    // FIXME: there is not recording API yet so we're making this up.
    property bool isRecording: false

    // TODO: maybe randomize this to fail once in a while, or just fail ever other time ?
    function takeSnapshot() { console.log("Taking fake snapshot..."); snapshotSuccess("dummydata/snapshot.jpg"); }

    // TODO: in the real API there's callback that returns the bits of the compressed image. We will need to save it
    // disk in C++ and then pass the path to QML, or maybe that plus a QML image provider ?
    signal snapshotSuccess(string imagePath)

    // TODO: log error messages at least
    signal snapshotFailure()

    onIsRecordingChanged: if (isRecording &&
                              (flashMode == CameraEnums.FlashModeOn || flashMode == CameraEnums.FlashModeAuto))
                              flashMode = CameraEnums.FlashModeOff
}
