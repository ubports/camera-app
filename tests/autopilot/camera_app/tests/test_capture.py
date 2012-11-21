# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App"""

from __future__ import absolute_import

from testtools.matchers import Equals, NotEquals
from autopilot.matchers import Eventually

from camera_app.tests import CameraAppTestCase

import time
import os
from os import path

class TestCapture(CameraAppTestCase):
    """Tests the main camera features"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestCapture, self).setUp()
        self.assertThat(self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestCapture, self).tearDown()

    """Test taking a picture"""
    def test_take_picture(self):
        camera_window = self.main_window.get_camera()
        focus_ring = self.main_window.get_focus_ring()
        toolbar = self.main_window.get_toolbar()
        exposure_button = self.main_window.get_exposure_button()
        pictures_dir = path.expanduser("~/Pictures")

        # Remove all pictures from ~/Pictures that match our pattern
        files = [ f for f in os.listdir(pictures_dir) if f[0:5] == "image" and path.isfile(path.join(pictures_dir,f))]
        for f in files:
            os.remove(path.join(pictures_dir, f))

        # The focus ring should be invisible in the beginning
        self.assertEquals(focus_ring.opacity, 0.0)

        center_click_coords = [camera_window.globalRect[2] / 2 + camera_window.globalRect[0], camera_window.globalRect[3] / 2 + camera_window.globalRect[1]]
        self.mouse.move(center_click_coords[0], center_click_coords[1])
        self.mouse.click()

        # The focus ring sould be visible and centered to the mouse click coords now
        focus_ring_center = [focus_ring.globalRect[2] / 2 + focus_ring.globalRect[0], focus_ring.globalRect[3] / 2 + focus_ring.globalRect[1]]
        self.assertThat(focus_ring.opacity, Eventually(Equals(1.0)))
        self.assertEquals(focus_ring_center, center_click_coords)

        # Now take the picture! (Give it a little time to animate)
        self.mouse.move_to_object(exposure_button)
        self.mouse.click()

        # All the ui elements should be invisible again
        self.assertThat(focus_ring.opacity, Eventually(Equals(0.0)))

        # Check that only one picture with the right name pattern is actually there
        one_picture_on_disk = False
        for i in range(0, 10):
            files = [ f for f in os.listdir(pictures_dir) if f[0:5] == "image" and path.isfile(path.join(pictures_dir,f))]
            if len(files) == 1:
                one_picture_on_disk = True
                break
        self.assertEquals(one_picture_on_disk, True)

    """Tests clicking on the record control and checks if the flash changes 
    to torch off mode and the recording time appears"""
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
        self.mouse.move_to_object(record_control)
        self.mouse.click();

        # Click the exposure button to start recording
        self.mouse.move_to_object(exposure_button)
        self.mouse.click();

        # Has the flash changed to be a torch, is the stop watch visible and set to 00:00?
        self.assertThat(flash_button.flashState, Eventually(Equals("off")))
        self.assertThat(flash_button.torchMode, Eventually(Equals(True)))
        self.assertThat(stop_watch.opacity, Eventually(Equals(1.0)))
        self.assertEquals(stop_watch.elapsed, "00:00")

        # Record video for 2 seconds and check if the stop watch actually runs.
        # Since the timer is not precise we don't check the actual time, just that it
        # is not counting zero anymore.
        self.assertThat(stop_watch.elapsed, Eventually(NotEquals("00:00")))

        # Now stop the video and check if everything resets itself to previous states
        self.mouse.click()

        self.assertThat(stop_watch.opacity, Eventually(Equals(0.0)))

        # Now start recording a second video and check if everything still works
        self.mouse.click();

        # Has the flash changed to be a torch, is the stop watch visible and set to 00:00?
        self.assertThat(flash_button.flashState, Eventually(Equals("off")))
        self.assertThat(flash_button.torchMode, Eventually(Equals(True)))
        self.assertThat(stop_watch.opacity, Eventually(Equals(1.0)))
        self.assertEquals(stop_watch.elapsed, "00:00")

        # Record video for 2 seconds and check if the stop watch actually works
        self.assertThat(stop_watch.elapsed, Eventually(NotEquals("00:00")))

        # Now stop the video and go back to picture mode and check if everything resets itself to previous states
        self.mouse.click();
        self.mouse.move_to_object(record_control)
        self.mouse.click();

        self.assertThat(stop_watch.opacity, Eventually(Equals(0.0)))
        self.assertThat(flash_button.flashState, Eventually(Equals(flashlight_old_state)))
        self.assertThat(flash_button.torchMode, Eventually(Equals(torchmode_old_state)))
