/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.4
import QtTest 1.0
import "../../"
import "../../.." //Needed for out of source build

TestCase {
    name: "BottomEdgeIndicators"
    when: windowShown
    visible: true

    property list<ListModel> noOptions
    property list<ListModel> noVisibleOptions: [
        ListModel {
            property string settingsProperty: "invisibleOption"
            property string icon
            property string label: ""
            property bool isToggle: true
            property int selectedIndex
            property bool available: true
            property bool visible: true
            property bool showInIndicators: false

            ListElement {
                icon: ""
                label: QT_TR_NOOP("On")
                value: true
            }
            ListElement {
                icon: ""
                label: QT_TR_NOOP("Off")
                value: false
            }
        }
    ]
    property list<ListModel> someVisibleOptions: [
        ListModel {
            property string settingsProperty: "invisibleOption"
            property string icon
            property string label: ""
            property bool isToggle: true
            property int selectedIndex
            property bool available: true
            property bool visible: true
            property bool showInIndicators: false

            ListElement {
                icon: ""
                label: QT_TR_NOOP("On")
                value: true
            }
            ListElement {
                icon: ""
                label: QT_TR_NOOP("Off")
                value: false
            }
        },
        ListModel {
            property string settingsProperty: "visibleOption"
            property string icon
            property string label: ""
            property bool isToggle: true
            property int selectedIndex
            property bool available: true
            property bool visible: true
            property bool showInIndicators: true

            ListElement {
                icon: ""
                label: QT_TR_NOOP("On")
                value: true
            }
            ListElement {
                icon: ""
                label: QT_TR_NOOP("Off")
                value: false
            }
        }
    ]

    function test_options_data() {
        return [
            {tag: "no options", options: noOptions, visibleChildren: 1, hintVisible: true },
            {tag: "no visible options", options: noVisibleOptions, visibleChildren: 1, hintVisible: true },
            {tag: "some visible options", options: someVisibleOptions, visibleChildren: 2, hintVisible: false },
        ]
    }

    function test_options(data) {
        try {
            Qt.createQmlObject("import QtQuick 2.4; Item {}", indicators);
        } catch (e) {
            skip("This test requires Qt 5.4");
        }
        indicators.options = data.options;
        var emptyIndicatorsHint = findChild(indicators, "emptyIndicatorsHint");
        var indicatorsRow = findChild(indicators, "indicatorsRow");
        compare(indicatorsRow.visibleChildren.length, data.visibleChildren, "Incorrect number of visible children in indicatorsRow");
        compare(emptyIndicatorsHint.visible, data.hintVisible, "Incorrect emptyIndicatorsHint's visibility");
    }

    BottomEdgeIndicators {
        id: indicators
    }
}
