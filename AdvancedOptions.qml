import QtQuick 2.0
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0


Flickable {
    id:advancedOptions

    property Settings settings: viewFinderOverlay.settings

    height:units.gu(25)

    anchors {
        left: parent.left
        right: parent.right
        leftMargin: units.gu(5)
        rightMargin: units.gu(5)
    }

    interactive: true

    Column {

        anchors.fill: parent

        ListItem {
            Label {
                color: "white"
                text: i18n.tr("Advanced Options")
            }
        }

        ListItem {
            ListItemLayout {
                id: datestampSwitchLayout
                title.text: i18n.tr("Add date stamp on captured images")
                title.color: "white"
                Switch {
                    SlotsLayout.position: SlotsLayout.Last
                    checked: advancedOptions.settings.dateStampImages
                    onClicked: advancedOptions.settings.dateStampImages = checked
                }
            }
            divider.visible: false
            height: datestampSwitchLayout.height
        }

    }
}
