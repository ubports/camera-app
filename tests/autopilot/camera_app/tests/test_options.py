# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2014, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App options overlay"""

from testtools.matchers import Equals
from autopilot.matchers import Eventually

from camera_app.tests import CameraAppTestCase


class TestCameraOptions(CameraAppTestCase):
    """Tests the options overlay"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestCameraOptions, self).setUp()
        # FIXME: this should be in parent class
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    """Test that the options overlay closes properly by tapping"""
    def test_overlay_tap_to_close(self):
        bottom_edge = self.main_window.get_bottom_edge()
        bottom_edge.open()

        # check overlay is opened
        self.assertThat(bottom_edge.opened, Eventually(Equals(True)))

        # tap to close overlay
        viewfinder = self.main_window.get_viewfinder()
        x = viewfinder.globalRect.x + viewfinder.width / 2.0
        y = viewfinder.globalRect.y + viewfinder.height / 4.0
        self.pointing_device.move(x, y)
        self.pointing_device.click()

        # check overlay is closed
        self.assertThat(bottom_edge.opened, Eventually(Equals(False)))

        # try opening and closing by tapping on the bottom of the viewfinder
        bottom_edge = self.main_window.get_bottom_edge()
        bottom_edge.open()

        # check overlay is opened
        self.assertThat(bottom_edge.opened, Eventually(Equals(True)))

        # tap on the bottom of the viewfinder to close overlay
        viewfinder = self.main_window.get_viewfinder()
        x = viewfinder.globalRect.x + viewfinder.width / 2.0
        y = viewfinder.globalRect.y + viewfinder.height - 1.0
        self.pointing_device.move(x, y)
        self.pointing_device.click()

        # check overlay is closed
        self.assertThat(bottom_edge.opened, Eventually(Equals(False)))

    """Test that the options overlay opens properly by tapping on the hint"""
    def test_overlay_open_tapping_hint(self):
        options_hint = self.app.wait_select_single(objectName="indicatorsRow")
        self.pointing_device.move_to_object(options_hint)
        self.pointing_device.click()

        # check overlay is opened
        bottom_edge = self.main_window.get_bottom_edge()
        self.assertThat(bottom_edge.opened, Eventually(Equals(True)))

    """Test toggling on/off grid lines option"""
    def test_toggle_grid_lines(self):
        gridlines = self.app.wait_select_single(
            "QQuickItem", objectName="gridlines")
        self.set_grid_lines_value("On")
        self.assertEquals(gridlines.visible, True)
        self.set_grid_lines_value("Off")
        self.assertEquals(gridlines.visible, False)

    def set_grid_lines_value(self, value="On"):
        # open bottom edge
        bottom_edge = self.main_window.get_bottom_edge()
        bottom_edge.open()

        # open grid lines option value selector showing the possible values
        grid_lines_button = self.main_window.get_grid_lines_button()
        self.pointing_device.move_to_object(grid_lines_button)
        self.pointing_device.click()
        option_value_selector = self.main_window.get_option_value_selector()
        self.assertThat(
            option_value_selector.visible, Eventually(Equals(True)))

        # tap on chosen value
        option = self.main_window.get_option_value_button(value)
        self.pointing_device.move_to_object(option)
        self.pointing_device.click()

        bottom_edge.close()
