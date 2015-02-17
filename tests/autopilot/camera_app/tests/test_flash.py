# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App flash"""

from testtools.matchers import Equals, NotEquals
from autopilot.matchers import Eventually

from camera_app.tests import CameraAppTestCase

import unittest


class TestCameraFlash(CameraAppTestCase):
    """Tests the flash"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestCameraFlash, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestCameraFlash, self).tearDown()

    """Test that flash modes activate properly"""
    def test_cycle_flash(self):
        bottom_edge = self.main_window.get_bottom_edge()
        bottom_edge.open()
        flash_button = self.main_window.get_flash_button()
        option_value_selector = self.main_window.get_option_value_selector()

        # open option value selector showing the possible values
        self.pointing_device.move_to_object(flash_button)
        self.pointing_device.click()
        self.assertThat(option_value_selector.visible,
                        Eventually(Equals(True)))

        # set flash to "on"
        option = self.main_window.get_option_value_button("On")
        self.pointing_device.move_to_object(option)
        self.pointing_device.click()
        self.assertThat(flash_button.iconName, Equals("flash-on"))

        # set flash to "off"
        option = self.main_window.get_option_value_button("Off")
        self.pointing_device.move_to_object(option)
        self.pointing_device.click()
        self.assertThat(flash_button.iconName, Equals("flash-off"))

        # set flash to "auto"
        option = self.main_window.get_option_value_button("Auto")
        self.pointing_device.move_to_object(option)
        self.pointing_device.click()
        self.assertThat(flash_button.iconName, Equals("flash-auto"))

    """Test that video flash modes cycles properly"""
    def test_cycle_video_flash(self):
        # Click the record button to toggle photo/video mode
        record_control = self.main_window.get_record_control()
        self.pointing_device.move_to_object(record_control)
        self.pointing_device.click()

        bottom_edge = self.main_window.get_bottom_edge()
        bottom_edge.open()
        flash_button = self.main_window.get_video_flash_button()
        option_value_selector = self.main_window.get_option_value_selector()

        # ensure initial state
        self.assertThat(flash_button.iconName, Equals("torch-off"))

        # open option value selector showing the possible values
        self.pointing_device.move_to_object(flash_button)
        self.pointing_device.click()

        self.assertThat(option_value_selector.visible,
                        Eventually(Equals(True)))

        # set flash to "on"
        option = self.main_window.get_option_value_button("On")
        self.pointing_device.move_to_object(option)
        self.pointing_device.click()
        self.assertThat(flash_button.iconName, Equals("torch-on"))

        # set flash to "off"
        option = self.main_window.get_option_value_button("Off")
        self.pointing_device.move_to_object(option)
        self.pointing_device.click()
        self.assertThat(flash_button.iconName, Equals("torch-off"))

    """Test that flash and hdr modes are mutually exclusive"""
    def test_flash_hdr_mutually_exclusive(self):
        bottom_edge = self.main_window.get_bottom_edge()
        bottom_edge.open()
        flash_button = self.main_window.get_flash_button()
        hdr_button = self.main_window.get_hdr_button()
        option_value_selector = self.main_window.get_option_value_selector()

        # open option value selector showing the possible values
        self.pointing_device.move_to_object(flash_button)
        self.pointing_device.click()
        self.assertThat(option_value_selector.visible, Eventually(Equals(True)))

        # set flash to "on"
        option = self.main_window.get_option_value_button("On")
        self.pointing_device.move_to_object(option)
        self.pointing_device.click()
        self.assertThat(flash_button.iconName, Equals("flash-on"))

        # closes the flash options menu and open the hdr options menu
        self.pointing_device.move_to_object(hdr_button)
        self.pointing_device.click()
        self.assertThat(option_value_selector.visible, Eventually(Equals(False)))
        self.pointing_device.click()
        self.assertThat(option_value_selector.visible, Eventually(Equals(True)))

        # set hdr to "on" and verify that flash is "off"
        option = self.main_window.get_option_value_button("On")
        self.pointing_device.move_to_object(option)
        self.pointing_device.click()
        self.assertThat(flash_button.iconName, Equals("flash-off"))
        self.assertThat(hdr_button.on, Equals(True))

        # closes the hdr options menu and open the flash options menu
        self.pointing_device.move_to_object(flash_button)
        self.pointing_device.click()
        self.assertThat(option_value_selector.visible, Eventually(Equals(False)))
        self.pointing_device.click()
        self.assertThat(option_value_selector.visible, Eventually(Equals(True)))

        # set flash to "on" and verify that hdr is "off"
        option = self.main_window.get_option_value_button("On")
        self.pointing_device.move_to_object(option)
        self.pointing_device.click()
        self.assertThat(flash_button.iconName, Equals("flash-on"))
        self.assertThat(hdr_button.on, Equals(False))
