# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App zoom"""

from testtools.matchers import Equals, NotEquals, GreaterThan, LessThan
from autopilot.matchers import Eventually
from autopilot.gestures import pinch

from camera_app.tests import CameraAppTestCase

import unittest


class TestCameraZoom(CameraAppTestCase):
    """Tests the main camera features"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestCameraZoom, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestCameraZoom, self).tearDown()

    def activate_zoom(self):
        viewfinder = self.main_window.get_viewfinder_geometry()
        viewfinder_center = self.get_center(viewfinder)

        pinch(viewfinder_center, (0, 0), (15, 0))
        pinch(viewfinder_center, (15, 0), (0, 0))

    """Tests the zoom slider to zoom in"""
    def test_slider_zoom_in(self):
        zoom_control = self.main_window.get_zoom_control()
        zoom_slider = self.main_window.get_zoom_slider()

        self.activate_zoom()

        x, y, w, h = zoom_slider.globalRect

        tx = x + (w // 2)
        ty = y + (h // 2)

        self.pointing_device.drag(tx, ty, (tx + zoom_control.width), ty)

        self.assertThat(
            zoom_control.value, Eventually(Equals(zoom_control.maximumValue)))

    """Tests the zoom slider to zoom out"""
    @unittest.skip("Temporarily disabled as it fails")
    def test_slider_zoom_out(self):
        zoom_control = self.main_window.get_zoom_control()
        zoom_slider = self.main_window.get_zoom_slider()

        self.activate_zoom()

        x, y, w, h = zoom_slider.globalRect

        tx = x + (w // 2)
        ty = y + (h // 2)

        self.pointing_device.drag(tx, ty, (tx - zoom_control.width), ty)
        self.assertThat(zoom_control.value, Eventually(Equals(1.0)))
