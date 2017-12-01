/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0

FastBlur {
    id: overlayBlurEffect
    property var overlayItem
    property var backgroundItem
    property int offestX: 0
    property int offestY: 0

    anchors.fill: overlayItem

    radius: units.gu(2)
    source:  ShaderEffectSource {
        clip: true
        sourceItem: backgroundItem
        sourceRect: Qt.rect( overlayItem.mapToItem(backgroundItem).x+offestX,
                             overlayItem.mapToItem(backgroundItem).y+offestY,
                             overlayItem.width,
                             overlayItem.height)
    }


}
