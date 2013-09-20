# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App"""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools.matchers import Equals, NotEquals, GreaterThan

from camera_app.tests import CameraAppTestCase

import unittest
import time
import os
from os import path


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
        toolbar = self.main_window.get_toolbar()
        exposure_button = self.main_window.get_exposure_button()
        pictures_dir = path.expanduser("~/Pictures")

        # Remove all pictures from ~/Pictures that match our pattern
        files = [f for f in os.listdir(pictures_dir) if f[0:5] == "image" and path.isfile(path.join(pictures_dir, f))]
        for f in files:
            os.remove(path.join(pictures_dir, f))

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
            files = [f for f in os.listdir(pictures_dir) if f[0:5] == "image" and path.isfile(path.join(pictures_dir, f))]
            if len(files) == 1:
                one_picture_on_disk = True
                break
            time.sleep(1)
        self.assertEquals(one_picture_on_disk, True)

        # check that the camera is able to capture another photo
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))

    """Tests clicking on the record control and checks if the flash changes
    to torch off mode and the recording time appears"""
    @unittest.skipIf(model() != 'Desktop', 'recording not available on device yet')
    def test_record_video(self):
        # Get all the elements
        camera_window = self.main_window.get_camera()
        toolbar = self.main_window.get_toolbar()
        record_control = self.main_window.get_record_control()
        flash_button = self.main_window.get_flash_button()
        stop_watch = self.main_window.get_stop_watch()
        exposure_button = self.main_window.get_exposure_button()

        # Store the torch mode and the flash state
        flashlight_old_state = flash_button.flashState
        torchmode_old_state = flash_button.torchMode

        # Click the record button to toggle photo/video mode
        self.pointing_device.move_to_object(record_control)
        self.pointing_device.click()

        # Has the flash changed to be a torch ?
        self.assertThat(flash_button.flashState, Eventually(Equals("off")))
        self.assertThat(flash_button.torchMode, Eventually(Equals(True)))

        # Before recording the stop watch should read zero recording time
        # and not be visible anyway.
        self.assertThat(stop_watch.opacity, Equals(0.0))
        self.assertEquals(stop_watch.elapsed, "00:00")

        # Click the exposure button to start recording
        self.pointing_device.move_to_object(exposure_button)
        self.pointing_device.click()

        # Record video for 2 seconds and check if the stop watch actually
        # runs and is visible.
        # Since the timer is not precise we don't check the actual time,
        # just that it is not counting zero anymore.
        self.assertThat(stop_watch.opacity, Eventually(Equals(1.0)))
        self.assertThat(stop_watch.elapsed, Eventually(NotEquals("00:00")))

        # Now stop the video and check if everything resets itself to
        # previous states.
        self.pointing_device.click()

        self.assertThat(stop_watch.opacity, Eventually(Equals(0.0)))

        # Now start recording a second video and check if everything
        # still works
        self.pointing_device.click()

        # Has the flash changed to be a torch, is the stop watch visible
        # and set to 00:00?
        self.assertThat(flash_button.flashState, Eventually(Equals("off")))
        self.assertThat(flash_button.torchMode, Eventually(Equals(True)))
        self.assertThat(stop_watch.opacity, Eventually(Equals(1.0)))
        self.assertEquals(stop_watch.elapsed, "00:00")

        # Record video for 2 seconds and check if the stop watch actually works
        self.assertThat(stop_watch.elapsed, Eventually(NotEquals("00:00")))

        # Now stop the video and go back to picture mode and check if
        # everything resets itself to previous states
        self.pointing_device.click()
        self.pointing_device.move_to_object(record_control)
        self.pointing_device.click()

        self.assertThat(stop_watch.opacity, Eventually(Equals(0.0)))
        self.assertThat(
            flash_button.flashState, Eventually(Equals(flashlight_old_state)))
        self.assertThat(
            flash_button.torchMode, Eventually(Equals(torchmode_old_state)))

    """Test that the shoot button gets disabled for a while then re-enabled
    after shooting"""
    @unittest.skip("Disabled this failing test due race condition)
    def test_shoot_button_disable(self):
        exposure_button = self.main_window.get_exposure_button()

        # The focus ring should be invisible in the beginning
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))

        # Now take the picture! (Give it a little time to animate)
        self.pointing_device.move_to_object(exposure_button)
        self.pointing_device.click()

        # autopilot might check this too late, so the exposure_button.enabled
        # is True again already before the first check
        # enable that test once autopilot can handle it
        self.assertThat(exposure_button.enabled, Eventually(Equals(False)))
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))
