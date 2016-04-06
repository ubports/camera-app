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

import QtQuick 2.4

Item {
    property size cameraResolution;
    property bool cameraResolutionValid: cameraResolution.width != -1
                                         && cameraResolution.height != -1
    property int viewFinderHeight;
    property int viewFinderWidth;
    property int viewFinderOrientation;

    property int __cameraWidth: Math.abs(viewFinderOrientation) == 90 || Math.abs(viewFinderOrientation) == 270 ?
                                cameraResolution.height : cameraResolution.width
    property int __cameraHeight: Math.abs(viewFinderOrientation) == 90 || Math.abs(viewFinderOrientation) == 270 ?
                                 cameraResolution.width : cameraResolution.height

    property real widthScale: viewFinderWidth / __cameraWidth
    property real heightScale: viewFinderHeight / __cameraHeight

    width: cameraResolutionValid ? ((widthScale <= heightScale) ? viewFinderWidth : __cameraWidth * heightScale)
                                 : viewFinderWidth
    height: cameraResolutionValid ? ((widthScale <= heightScale) ? __cameraHeight * widthScale : viewFinderHeight)
                                  : viewFinderHeight
}
