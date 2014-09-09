# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App"""

from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools.matchers import Equals, NotEquals

from camera_app.tests import CameraAppTestCase

import unittest
import time
import os


class TestCapture(CameraAppTestCase):
    """Tests the main camera features"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestCapture, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestCapture, self).tearDown()

    """Test taking a picture"""
    def test_take_picture(self):
        exposure_button = self.main_window.get_exposure_button()
        pictures_dir = os.path.expanduser("~/Pictures/com.ubuntu.camera")

        # Remove all pictures from pictures_dir that match our pattern
        files = [
            f for f in os.listdir(pictures_dir)
            if f[0:5] == "image" and
            os.path.isfile(os.path.join(pictures_dir, f))
        ]
        for f in files:
            os.remove(os.path.join(pictures_dir, f))

        # Wait for the camera to have finished focusing
        # (the exposure button gets enabled when ready)
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))

        # Now take the picture! (Give it a little time to animate)
        self.pointing_device.move_to_object(exposure_button)
        self.pointing_device.click()

        # Check that only one picture with the right name pattern
        # is actually there
        one_picture_on_disk = False
        for i in range(0, 10):
            files = [
                f for f in os.listdir(pictures_dir)
                if f[0:5] == "image" and
                os.path.isfile(os.path.join(pictures_dir, f))
            ]
            if len(files) == 1:
                one_picture_on_disk = True
                break
            time.sleep(1)
        self.assertEquals(one_picture_on_disk, True)

        # check that the camera is able to capture another photo
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))

    """Tests clicking on the record control and checks if the recording time appears"""
    def test_record_video(self):
        # Get all the elements
        record_control = self.main_window.get_record_control()
        stop_watch = self.main_window.get_stop_watch()
        exposure_button = self.main_window.get_exposure_button()

        # Click the record button to toggle photo/video mode
        self.pointing_device.move_to_object(record_control)
        self.pointing_device.click()

        # Before recording the stop watch should read zero recording time
        # and not be visible anyway.
        self.assertThat(stop_watch.opacity, Equals(0.0))
        self.assertEquals(stop_watch.label, "00:00")

        # Click the exposure button to start recording
        self.pointing_device.move_to_object(exposure_button)
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))
        self.pointing_device.click()

        # Record video for 2 seconds and check if the stop watch actually
        # runs and is visible.
        # Since the timer is not precise we don't check the actual time,
        # just that it is not counting zero anymore.
        self.assertThat(stop_watch.opacity, Eventually(Equals(1.0)))
        self.assertThat(stop_watch.label, Eventually(NotEquals("00:00")))

        # Now stop the video and check if everything resets itself to
        # previous states.
        self.pointing_device.click()

        self.assertThat(stop_watch.opacity, Eventually(Equals(0.0)))

        # Now start recording a second video and check if everything
        # still works
        self.pointing_device.click()

        # Is the stop watch visible and set to 00:00?
        self.assertEquals(stop_watch.label, "00:00")
        self.assertThat(stop_watch.opacity, Eventually(Equals(1.0)))

        # Record video for 2 seconds and check if the stop watch actually works
        self.assertThat(stop_watch.label, Eventually(NotEquals("00:00")))

        # Now stop the video and go back to picture mode and check if
        # everything resets itself to previous states
        self.pointing_device.click()
        self.pointing_device.move_to_object(record_control)
        self.pointing_device.click()

        self.assertThat(stop_watch.opacity, Eventually(Equals(0.0)))

    """Test that the shoot button gets disabled for a while then re-enabled
    after shooting"""
    @unittest.skip("Disabled this test due race condition see bug 1227373")
    def test_shoot_button_disable(self):
        exposure_button = self.main_window.get_exposure_button()

        # The focus ring should be invisible in the beginning
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))

        # Now take the picture! (Give it a little time to animate)
        self.pointing_device.move_to_object(exposure_button)
        self.pointing_device.click()

        # autopilot might check this too late, so the exposure_button.enabled
        # is True again already before the first check
        self.assertThat(exposure_button.enabled, Eventually(Equals(False)))
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))
