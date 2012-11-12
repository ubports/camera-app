# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App"""

from __future__ import absolute_import

from testtools.matchers import Equals
from autopilot.matchers import Eventually

from camera_app.tests import CameraAppTestCase

import time


class TestCameraFeatures(CameraAppTestCase):
    """Tests the main camera features"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestCameraFeatures, self).setUp()
        self.assertThat(self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    """ Ignore this for now... I'll fix and comment it, or remove it if not needed"""
    def tearDown(self):
#        self.keyboard.press_and_release("Alt+F4")
#        self.assertThat(self.main_window.get_qml_view().visible, Eventually(Equals(False)))
        super(TestCameraFeatures, self).tearDown()

    """Of course, first thing we do is taking a picture"""
    def test_take_picture(self):
        camera_window = self.main_window.get_camera()
        focus_ring = self.main_window.get_focus_ring()
        toolbar = self.main_window.get_toolbar()
        exposure_button = self.main_window.get_exposure_button()
        
        # The focus ring should be invisible in the beginning
        self.assertEquals(focus_ring.opacity, 0.0)

        self.mouse.move_to_object(camera_window)
        self.mouse.click()

        # The focus ring sould be visible and centered to the mouse click coords now
        center_click_coords = [camera_window.globalRect[2] / 2 + camera_window.globalRect[0], camera_window.globalRect[3] / 2 + camera_window.globalRect[1]]
        focus_ring_center = [focus_ring.globalRect[2] / 2 + focus_ring.globalRect[0], focus_ring.globalRect[3] / 2 + focus_ring.globalRect[1]]
        self.assertThat(focus_ring.opacity, Eventually(Equals(1.0)))
        self.assertEquals(focus_ring_center, center_click_coords)

        # Now take the picture! (Give it a little time to animate)
        self.mouse.move_to_object(exposure_button)
        self.mouse.click()

        # All the ui elements should be invisible again
        self.assertThat(focus_ring.opacity, Eventually(Equals(0.0)))


    """Tests clicking on the record control and checks if the flash changes 
    to torch off mode and the recording time appears"""
    def test_record_control(self):
        # Get all the elements
        camera_window = self.main_window.get_camera()
        toolbar = self.main_window.get_toolbar()
        record_control = self.main_window.get_record_control()
        flash_button = self.main_window.get_flash_button()
        stop_watch = self.main_window.get_stop_watch()
        exposure_button = self.main_window.get_exposure_button()

        # Store the flashlight state
        flashlight_old_state = flash_button.state

        # Click the record button to toggle photo/video mode
        self.mouse.move_to_object(record_control)
        self.mouse.click();

        # Click the exposure button to start recording
        self.mouse.move_to_object(exposure_button)
        self.mouse.click();

        # Has the flash changed to be a torch, is the stop watch visible and set to 00:00?
        self.assertEquals(flash_button.state, "off_torch")
        self.assertThat(stop_watch.opacity, Eventually(Equals(1.0)))
        self.assertEquals(stop_watch.elapsed, "00:00")


        # Record video for 2 seconds and check if the stop watch actually works
        # Now, ideally this should be used as in that case we check if the time actually works.
        #time.sleep(2)
        #self.assertThat(stop_watch.elapsed, Equals("00:02"))
        
        # However, the camera app seems to start a bit delayed (which might be also true for real hardware)
        # so we just check if the counter reaches 00:02 at some point (max. 10s)
        self.assertThat(stop_watch.elapsed, Eventually(Equals("00:02")))

        # Now stop the video and check if everything resets itself to previous states
        self.mouse.click()

        self.assertThat(stop_watch.opacity, Eventually(Equals(0.0)))

        # Now start recording a second video and check if everything still works
        self.mouse.click();

        # Has the flash changed to be a torch, is the stop watch visible and set to 00:00?
        self.assertEquals(flash_button.state, "off_torch")
        self.assertThat(stop_watch.opacity, Eventually(Equals(1.0)))
        self.assertEquals(stop_watch.elapsed, "00:00")


        # Record video for 2 seconds and check if the stop watch actually works
        self.assertThat(stop_watch.elapsed, Eventually(Equals("00:02")))

        # Now stop the video and go back to picture mode and check if everything resets itself to previous states
        self.mouse.click();
        self.mouse.move_to_object(record_control)
        self.mouse.click();

        self.assertThat(stop_watch.opacity, Eventually(Equals(0.0)))
        self.assertThat(flash_button.state, Eventually(Equals(flashlight_old_state)))


    """Tests clicking on the flash button and checks if it cycles the state after exactly 3 clicks"""
    def test_flash_button(self):
        camera_window = self.main_window.get_camera()
        self.mouse.move_to_object(camera_window)
        self.mouse.click()

        flash_button = self.main_window.get_flash_button()

        flash_button_old_state = flash_button.state

        self.mouse.move_to_object(flash_button)
        self.mouse.click();
        self.assertNotEqual(flash_button_old_state, flash_button.state)

        self.mouse.click();
        self.assertNotEqual(flash_button_old_state, flash_button.state)

        self.mouse.click();
        self.assertEqual(flash_button_old_state, flash_button.state)


    """Tests the zoom slider"""
    def test_zoom(self):
        camera_window = self.main_window.get_camera()
        zoom_control = self.main_window.get_zoom_control()

        zoom_button = self.main_window.get_zoom_slider_button()
        self.mouse.move_to_object(zoom_button)
        
        self.mouse.press()
        self.mouse.move(self.mouse.x + camera_window.width, self.mouse.y)
        self.mouse.release()
        self.assertEqual(zoom_control.value, 6.0)
