import QtQuick 2.0
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0


Column {

    id:advancedOptions

    property Settings settings: viewFinderOverlay.settings

    height:units.gu(20)
    anchors {
        left: parent.left
        right: parent.right
        leftMargin: units.gu(5)
        rightMargin: units.gu(5)
    }

    ListItem {
        Label {
            color: UbuntuColors.slate
            text: i18n.tr("Advnaced Options")
        }
    }

    ListItem {
        ListItemLayout {
            id: datestampSwitchLayout
            title.text: i18n.tr("Add date stamp on captured images")
            title.color: UbuntuColors.slate
            Switch {
                SlotsLayout.position: SlotsLayout.Last
                checked: settings.dateStampImages
                onClicked: settings.dateStampImages = checked
            }
        }
        divider.visible: false
        height: datestampSwitchLayout.height
    }

}
