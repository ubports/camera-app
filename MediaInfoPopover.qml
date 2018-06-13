import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Popover {
    id: infoPopover
    property Image currentMedia: null
    property var model: null

    autoClose: true

    Item {
        height: childrenRect.height + units.gu(4)
        anchors {
            centerIn: parent
            margins: units.gu(2)
        }
        Column {
            anchors {
                centerIn: parent
            }

            spacing:units.gu(1)
            Label {
                text:i18n.tr("Media info");
                textSize: Label.Large
                color: theme.palette.normal.overlayText
            }
            Label {
                text:i18n.tr("Name: %1".arg(infoPopover.model.fileName))
            }
            Label {
                text:i18n.tr("Type : %1").arg(infoPopover.model.fileType)
            }
            Label {
                visible:null !== infoPopover.currentMedia;
                text:visible ? i18n.tr("Width : %1").arg( infoPopover.currentMedia.sourceSize.width) : "";
            }
            Label {
                visible:null !==  infoPopover.currentMedia;
                text: visible ? i18n.tr("Height : %1").arg( infoPopover.currentMedia.sourceSize.height) : "";
            }

        }
    }

    }
 
