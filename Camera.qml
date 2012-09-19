import QtQuick 1.1
import "CameraEnums.js" as CameraEnums

/* This component is a mock of the real QT Mobility Camera comonent, to
   allow prototyping of the UI even when we don't have actual camera hardware */


Image {
    source: "dummydata/live_view.jpg"
    sourceSize.width: width
    sourceSize.height: height
    fillMode: Image.PreserveAspectCrop

    property string flashMode: CameraEnums.FlashOff
}
