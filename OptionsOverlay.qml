/*
 * Copyright 2014 Canonical Ltd.
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
 */

import QtQuick 2.2
import Ubuntu.Components 1.1

Item {
    id: optionsOverlay

    property list<ListModel> options

    function closeValueSelector() {
        optionValueSelector.hide();
    }

    height: optionsGrid.height

    Grid {
        id: optionsGrid
        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        columns: 3
        columnSpacing: units.gu(9.5)
        rowSpacing: units.gu(9.5)

        Repeater {
            model: optionsOverlay.options
            delegate: OptionButton {
                id: optionButton
                model: modelData
                onClicked: optionValueSelector.toggle(model, optionButton)
            }
        }
    }

    Column {
        id: optionValueSelector
        objectName: "optionValueSelector"
        anchors {
            bottom: optionsGrid.top
            bottomMargin: units.gu(2)
        }
        width: units.gu(12)

        function toggle(model, callerButton) {
            if (optionValueSelectorVisible && optionsRepeater.model === model) {
                hide();
            } else {
                show(model, callerButton);
            }
        }

        function show(model, callerButton) {
            alignWith(callerButton);
            optionsRepeater.model = model;
            optionValueSelectorVisible = true;
        }

        function hide() {
            optionValueSelectorVisible = false;
        }

        function alignWith(item) {
            // horizontally center optionValueSelector with the center of item
            // if there is enough space to do so, that is as long as optionValueSelector
            // does not get cropped by the edge of the screen
            var itemX = parent.mapFromItem(item, 0, 0).x;
            var centeredX = itemX + item.width / 2.0 - width / 2.0;
            var margin = units.gu(1);

            if (centeredX < margin) {
                x = itemX;
            } else if (centeredX + width > item.parent.width - margin) {
                x = itemX + item.width - width;
            } else {
                x = centeredX;
            }
        }

        visible: opacity !== 0.0
        onVisibleChanged: if (!visible) optionsRepeater.model = null;
        opacity: optionValueSelectorVisible ? 1.0 : 0.0
        Behavior on opacity {UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration}}

        Repeater {
            id: optionsRepeater

            delegate: OptionValueButton {
                anchors {
                    right: optionValueSelector.right
                    left: optionValueSelector.left
                }
                label: model.label
                iconName: model.icon
                selected: optionsRepeater.model.selectedIndex == index
                isLast: index === optionsRepeater.count - 1
                onClicked: settings[optionsRepeater.model.settingsProperty] = optionsRepeater.model.get(index).value
            }
        }
    }
}
