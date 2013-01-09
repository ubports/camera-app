/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import QtTest 1.0
import "../../"
import "../../.." //Needed for out of source build

TestCase {
    name: "ViewFinderImage"

    function test_16_9_camera_portrait_in_16_9_screen_portrait() {
        image.cameraResolution = Qt.size(720, 1280)
        image.viewFinderOrientation = 0
        image.viewFinderWidth = 720
        image.viewFinderHeight = 1280
        compare(image.width, 720, "Width not calculated correctly")
        compare(image.height, 1280, "Height not calculated correctly")
    }  

    function test_16_9_camera_landscape_in_16_9_screen_landscape() {
        image.cameraResolution = Qt.size(1280, 720)
        image.viewFinderOrientation = 0
        image.viewFinderWidth = 1280
        image.viewFinderHeight = 720
        compare(image.width, 1280, "Width not calculated correctly")
        compare(image.height, 720, "Height not calculated correctly")
    }

    function test_16_9_camera_landscape_in_16_9_screen_portrait() {
        image.cameraResolution = Qt.size(1280, 720)
        image.viewFinderOrientation = 0
        image.viewFinderWidth = 720
        image.viewFinderHeight = 1280
        compare(image.width, 720, "Width not calculated correctly")
        compare(image.height, 405, "Height not calculated correctly")
    }

    function test_16_9_camera_portrait_in_16_9_screen_landscape() {
        image.cameraResolution = Qt.size(720, 1280)
        image.viewFinderOrientation = 0
        image.viewFinderWidth = 1280
        image.viewFinderHeight = 720
        compare(image.width, 405, "Width not calculated correctly")
        compare(image.height, 720, "Height not calculated correctly")
    }

    function test_4_3_camera_landscape_in_16_9_screen_portrait() {
        image.cameraResolution = Qt.size(640, 480)
        image.viewFinderOrientation = 0
        image.viewFinderWidth = 720
        image.viewFinderHeight = 1280
        compare(image.width, 720, "Width not calculated correctly")
        compare(image.height, 540, "Height not calculated correctly")
    }

    function test_16_9_camera_landscape_rotated_in_16_9_screen_landscape() {
        image.cameraResolution = Qt.size(1280, 720)
        image.viewFinderOrientation = 90
        image.viewFinderWidth = 1280
        image.viewFinderHeight = 720
        compare(image.width, 405, "Width not calculated correctly")
        compare(image.height, 720, "Height not calculated correctly")
    }

    ViewFinderImage {
        id: image
    }
}
