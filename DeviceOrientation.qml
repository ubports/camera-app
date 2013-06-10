/*
 * Copyright 2013 Canonical Ltd.
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

import QtQuick 2.0
import QtQuick.Window 2.0

// We must use Item element because Screen component does not works with QtObject
Item {
    property string naturalOrientation: Screen.primaryOrientation == Qt.LandscapeOrientation ? "landscape" : "portrait"

    /* Is the device currently rotated to be in lanscape orientation ? */
    property bool isLandscape: Screen.orientation == Qt.LandscapeOrientation ||
                               Screen.orientation == Qt.InvertedLandscapeOrientation

    /* Is the device currently rotated upside down ? */
    property bool isInverted: Screen.orientation == Qt.InvertedLandscapeOrientation ||
                              Screen.orientation == Qt.InvertedPortraitOrientation

    /* The rotation angle in 90 degrees increments with respect to the device being in its
       default position */
    property int rotationAngle: Screen.angleBetween(Screen.primaryOrientation, Screen.orientation)

    visible: false
}
