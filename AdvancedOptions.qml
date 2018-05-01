import QtQuick 2.0
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0
import Ubuntu.Components.ListItems 1.3 as ListItems

Page {
    id:_advancedOptionsPage
    signal back();

    header: PageHeader {
        id:_advancedOptionsPageHeader
        StyleHints {
            backgroundColor:"transparent"
            foregroundColor:"white"
        }
        title: i18n.tr("Settings")
        leadingActionBar.actions: [
               Action {
                   iconName: "down"
                   text: "Back"
                   onTriggered: _advancedOptionsPage.back();
               }
           ]
    }

    Flickable {
        id:advancedOptions

        property Settings settings: viewFinderOverlay.settings

        anchors {
            top: _advancedOptionsPageHeader.bottom
            left:parent.left
            right:parent.right
            bottom:parent.bottom
            margins: units.gu(2)
        }

        interactive: true

        Column {

            anchors.fill: parent

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
                        // TRANSLATORS: this refers to the opacity  of date stamp added to captured images
                        title.text: i18n.tr("Format")
                        title.color: "white"
                        TextField {
                            id:dateFormatText
                            SlotsLayout.position: SlotsLayout.Last
                            focus: true
                            width:units.gu(20)
                            text: advancedOptions.settings.dateStampFormat
                            placeholderText:  Qt.locale().dateFormat(Locale.ShortFormat)
                            onActiveFocusChanged: if(!text) {text = Qt.locale().dateFormat(Locale.ShortFormat);}
                            onTextChanged: {
                                advancedOptions.settings.dateStampFormat = text;
                            }
                        }
                    }
                }
                ListItems.Expandable {
                    id:dateStampFormatExpand
                    z:1
                    anchors {
                        top:datestampFormatItem.bottom
                        right: datestampFormatItem.right
                        left:datestampFormatItem.left
                        bottom: dateStampExpand.bottom
                    }
                    collapseOnClick: false
                    highlightWhenPressed: false
                    collapsedHeight: 0
                    expandedHeight: units.gu(20)
                    expanded: dateFormatText.activeFocus || dateStampFormatExpandFocus.activeFocus
                    FocusScope {
                        id:dateStampFormatExpandFocus
                        anchors {
                            right: parent.right
                            left:parent.left
                        }
                        height:dateStampFormatExpand.expandedHeight
                        UbuntuShapeOverlay {
                            width:dateStampFormatExpandList.width
                            height:dateStampFormatExpandList.height
                            backgroundColor: "white"
                            overlayRect: Qt.rect(0,0,1,1)
                        }

                        ListView {
                            id:dateStampFormatExpandList
                            anchors.fill: parent
                            orientation: ListView.Vertical
                            interactive: true

                            header:Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:i18n.tr("Date formating keywords")
                                horizontalAlignment: Text.horizontalCenter
                            }

                            model:[
                                { "seq" : "d", "desc" : i18n.tr("the day as number without a leading zero (1 to 31)") },
                                { "seq" : "dd", "desc" : i18n.tr("the day as number with a leading zero (01 to 31)") },
                                { "seq" : "ddd", "desc" : i18n.tr("the abbreviated localized day name (e.g. 'Mon' to 'Sun').") },
                                { "seq" : "dddd", "desc" : i18n.tr("the long localized day name (e.g. 'Monday' to 'Sunday').") },
                                { "seq" : "M", "desc" : i18n.tr("the month as number without a leading zero (1 to 12)") },
                                { "seq" : "MM", "desc" : i18n.tr("the month as number with a leading zero (01 to 12)") },
                                { "seq" : "MMM", "desc" : i18n.tr("the abbreviated localized month name (e.g. 'Jan' to 'Dec').") },
                                { "seq" : "MMMM", "desc" : i18n.tr("the long localized month name (e.g. 'January' to 'December').") },
                                { "seq" : "yy", "desc" : i18n.tr("the year as two digit number (00 to 99)") },
                                { "seq" : "yyyy", "desc" : i18n.tr("the year as four digit number. If the year is negative, a minus sign is prepended in addition.") },
                                { "seq" : "h", "desc" : i18n.tr("the hour without a leading zero (0 to 23 or 1 to 12 if AM/PM display)") },
                                { "seq" : "hh", "desc" : i18n.tr("the hour with a leading zero (00 to 23 or 01 to 12 if AM/PM display)") },
                                { "seq" : "H", "desc" : i18n.tr("the hour without a leading zero (0 to 23, even with AM/PM display)") },
                                { "seq" : "HH", "desc" : i18n.tr("the hour with a leading zero (00 to 23, even with AM/PM display)") },
                                { "seq" : "m", "desc" : i18n.tr("the minute without a leading zero (0 to 59)") },
                                { "seq" : "mm", "desc" : i18n.tr("the minute with a leading zero (00 to 59)") },
                                { "seq" : "s", "desc" : i18n.tr("the second without a leading zero (0 to 59)") },
                                { "seq" : "ss", "desc" : i18n.tr("the second with a leading zero (00 to 59)") },
                                { "seq" : "z", "desc" : i18n.tr("the milliseconds without leading zeroes (0 to 999)") },
                                { "seq" : "zzz", "desc" : i18n.tr("the milliseconds with leading zeroes (000 to 999)") },
                                { "seq" : "AP", "desc" : i18n.tr("use AM/PM display. AP will be replaced by either 'AM' or 'PM'.") },
                                { "seq" : "ap", "desc" : i18n.tr("use am/pm display. ap will be replaced by either 'am' or 'pm'.") },
                                { "seq" : "t", "desc" : i18n.tr("the timezone (for example 'CEST')") }
                            ]
                            delegate: ListItem {
                                height:units.gu(8)
                                divider.visible: false
                                highlightColor: color
                                trailingActions: ListItemActions {
                                    actions: [
                                        Action {
                                            text: i18n.tr("Add to Format")
                                            iconName:"add"
                                            onTriggered:{
                                                var addSpace = dateFormatText.text.match(/\w$/);
                                                dateFormatText.text += (addSpace ? " " : "") + modelData.seq;
                                                dateFormatText.focus = true;
                                            }
                                        }
                                    ]

                                }
                                ListItemLayout {
                                    title.text: modelData.seq
                                    summary.text: modelData.desc
                                }
                            }
                        }
                    }
                }

                ListItem {
                    id:  dateStampColorItem
                    anchors.top : dateStampFormatExpand.bottom
                    anchors.margins:units.gu(1)
                    height:units.gu(5)
                    divider.visible: false
                    ListItemLayout {
                        id:  dateStampColorItemLayout

                        title.color: "white"
                        // TRANSLATORS: this refers to the color of date stamp added to captured images
                        title.text:i18n.tr("Color")

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

                            function getItemIdx(item) {
                                for(var i in model ) {
                                    if(item == model[i]) {
                                      return i;
                                    }
                                }
                                return -1;
                            }

                            Component.onCompleted: {
                                var newColors = [];
                                for(var i in UbuntuColors) {
                                    if( typeof(UbuntuColors[i]) == "object" && !(UbuntuColors[i].stops) ) {
                                        newColors.push(UbuntuColors[i]);
                                    }
                                }
                                model = newColors;
                                currentIndex = dateStampColor.getItemIdx( advancedOptions.settings.dateStampColor);
                                positionViewAtIndex(currentIndex, ListView.Center);
                            }

                            onWidthChanged: if(currentIndex > 0 ) { positionViewAtIndex(currentIndex, ListView.Center); }

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
                    id:  dateStampAlignmentItem
                    anchors.top : dateStampColorItem.bottom
                    anchors.margins:units.gu(1)

                    height:units.gu(6)
                    divider.visible: false
                    ListItemLayout {
                        id:  dateStampAlignmentItemLayout
                        title.color: "white"
                        // TRANSLATORS: this refers to the alignment of date stamp within captured images (bottom left, top right,etc..)
                        title.text:i18n.tr("Alignment")
                        Row {
                            id:dateStampAlignment
                            anchors.topMargin:units.gu(1)
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
                                    height:dateStampAlignmentItem.height - units.gu(1)
                                    width:height
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

                ListItem {
                    anchors.top : dateStampAlignmentItem.bottom
                    anchors.margins:units.gu(1)
                    id:  dateStampOpacityItem
                    height:units.gu(3)
                    divider.visible: false

                    ListItemLayout {
                        id:  dateStampOpacityItemLayout
                        height: dateStampOpacityItem.height
                        title.color: "white"
                        // TRANSLATORS: this refers to the opacity  of date stamp added to captured images
                        title.text:i18n.tr("Opacity")

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
            }

        }
    }
}
