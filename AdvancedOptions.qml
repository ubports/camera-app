import QtQuick 2.0
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0
import Ubuntu.Components.ListItems 1.3 as ListItems

Flickable {
    id:advancedOptions

    property Settings settings: viewFinderOverlay.settings

    height:units.gu(50)

    anchors {
        left: parent.left
        right: parent.right
        leftMargin: units.gu(4)
        rightMargin: units.gu(4)
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
        }
        ListItems.Expandable {
            id:dateStampExpand
            expanded: advancedOptions.settings.dateStampImages
            collapsedHeight: 0
            expandedHeight: units.gu(27)
            collapseOnClick: false
            highlightWhenPressed: false

            ListItem {
                id: datestampFormatItem
                divider.visible: false
                ListItemLayout {
                    title.text: i18n.tr("Date Format")
                    title.color: "white"
                    TextField {
                        id:dateFormatText
                        SlotsLayout.position: SlotsLayout.Last
                        autoScroll: true
                        width:units.gu(20)
                        text: advancedOptions.settings.dateStampFormat
                        placeholderText:  Qt.locale().dateFormat(Locale.ShortFormat)
                        onTextChanged: {
                            if(!text) {text = Qt.locale().dateFormat(Locale.ShortFormat);}
                            advancedOptions.settings.dateStampFormat = text;
                        }
                    }
                }
            }
            ListItem {
                anchors.top : datestampFormatItem.bottom
                anchors.margins:units.gu(1)
                id:  dateStampColorItem
                height:units.gu(5)
                divider.visible: false
                ListItemLayout {
                    id:  dateStampColorItemLayout
                    title.color: "white"
                    title.text:i18n.tr("Stamp Color :")
                    ListView {
                        id:dateStampColor
                        width:dateStampColorItem.width - units.gu(18)
                        height:dateStampColorItem.height
                        SlotsLayout.position: SlotsLayout.Last

                        spacing: units.gu(1)
                        orientation: ListView.Horizontal
                        interactive: true
                        snapMode: ListView.SnapToItem
                        highlightFollowsCurrentItem: true
                        highlightMoveDuration: UbuntuAnimation.SnapDuration
                        clip:true
                        Component.onCompleted: {
                            var newColors = [];
                            var currItem = null;
                            var idx =0;
                            for(var i in UbuntuColors) {
                                idx += currItem ? 1 :0;
                                if(typeof(UbuntuColors[i]) == "object" ) {
                                    console.log(i)
                                    console.log(UbuntuColors[i])
                                    newColors.push(UbuntuColors[i]);
                                    if(advancedOptions.settings.dateStampColor == UbuntuColors[i]) {
                                      currItem = UbuntuColors[i];
                                    }
                                }
                            }
                            model = newColors;
                            currentIndex = idx;
                            positionViewAtIndex(idx, ListView.Center);
                        }
                        onWidthChanged: positionViewAtIndex(currentIndex, ListView.Center);
                      //  onDataChanged: positionViewAtIndex(currentIndex, ListView.Center);
                        delegate: Button {
                            height:dateStampColorItem.height - units.gu(1)
                            width:height
                            color: modelData
                            iconName: advancedOptions.settings.dateStampColor == modelData ? "tick" : ""
                            onClicked: {
                                dateStampColor.currentIndex = index;
                                advancedOptions.settings.dateStampColor = modelData;
                            }
                            Component.onCompleted: if( advancedOptions.settings.dateStampColor == modelData) {dateStampColor.positionViewAtIndex(index, ListView.Center);  }
                        }
                    }
                }
            }
            ListItem {
                anchors.top : dateStampColorItem.bottom
                anchors.margins:units.gu(1)
                id:  dateStampOpacityItem
                height:units.gu(5)
                divider.visible: false
                clip:false
                ListItemLayout {
                    id:  dateStampOpacityItemLayout
                    title.color: "white"
                    title.text:i18n.tr("Stamp Opacity :")

                    Slider {
                        id: dateStampOpacity
                        width:dateStampOpacityItem.width - units.gu(18)
                        height:dateStampOpacityItem.height
                        value:advancedOptions.settings.dateStampOpacity
                        SlotsLayout.position: SlotsLayout.Last
                        maximumValue: 1.0
                        minimumValue: 0.25
                        stepSize: 0.1
                        live:true
                        onValueChanged: {
                             advancedOptions.settings.dateStampOpacity = dateStampColor.opacity = value;

                        }
                    }
                }
            }
            ListItem {
                id:  dateStampAlignmentItem
                anchors.top : dateStampOpacityItem.bottom
                anchors.margins:units.gu(1)

                height:units.gu(6)
                divider.visible: false
                ListItemLayout {
                    id:  dateStampAlignmentItemLayout
                    title.color: "white"
                    title.text:i18n.tr("Alignment :")
                    Row {
                        id:dateStampAlignment
                        SlotsLayout.position: SlotsLayout.Last
                        width:dateStampAlignmentItem.width - units.gu(18)
                        height:dateStampAlignmentItem.height
                        spacing:units.gu(0.5)
                        layoutDirection: Qt.RightToLeft

                        Repeater {
                            height:dateStampAlignmentItem.height

                            model:[
                                {"value" :Qt.AlignBottom | Qt.AlignRight,"icon":"assets/align_bottom_right.png"},
                                {"value" :Qt.AlignBottom | Qt.AlignLeft,"icon":"assets/align_bottom_left.png"},
                                {"value" :Qt.AlignTop | Qt.AlignRight,"icon":"assets/align_top_right.png"},
                                {"value" :Qt.AlignTop | Qt.AlignLeft,"icon":"assets/align_top_left.png"},
                            ]
                            delegate: CircleButton {
                                automaticOrientation:false
                                iconSource: Qt.resolvedUrl( modelData.icon )
                                on:(modelData.value == advancedOptions.settings.dateStampAlign)
                                onClicked: {
                                    advancedOptions.settings.dateStampAlign = modelData.value;
                                }
                            }
                        }
                    }
                }
            }
        }

    }
}
