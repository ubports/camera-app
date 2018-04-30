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

import QtQuick 2.4

CircleButton {
    id: optionButton
    objectName: "optionButton"

    property var model
    property string settingsProperty: model.settingsProperty

    iconName: (!model.get(model.selectedIndex) || !model.get(model.selectedIndex).icon) ?
                                                    (model.icon ? model.icon : "") :
                                                    model.get(model.selectedIndex).icon
    iconSource: (!model.get(model.selectedIndex) || !model.get(model.selectedIndex).iconSource) ?
                    ((model && model.iconSource) ? model.iconSource : "") :
                    model.get(model.selectedIndex).iconSource

    on: model.isToggle ? model.get(model.selectedIndex).value : true
    enabled: model.visible && model.available
    label: model.label
    visible: model.visible && model.available
    automaticOrientation: false
}
