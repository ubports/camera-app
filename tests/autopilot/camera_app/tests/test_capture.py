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
from wand.image import Image

from camera_app.tests import CameraAppTestCase

import unittest
import time
import os


class TestCapture(CameraAppTestCase):
    """Tests the main camera features"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        # Remove configuration file where knowledge of the photo roll hint's necessity is stored
        config_file = os.path.expanduser("~/.config/com.ubuntu.camera/com.ubuntu.camera.conf")
        os.remove(config_file)

        super(TestCapture, self).setUp()

        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))
        self.pictures_dir = os.path.expanduser("~/Pictures/com.ubuntu.camera")
        self.videos_dir = os.path.expanduser("~/Videos/com.ubuntu.camera")

    def tearDown(self):
        super(TestCapture, self).tearDown()

    """Test taking a picture"""
    def test_take_picture(self):
        exposure_button = self.main_window.get_exposure_button()

        # Remove all pictures from self.pictures_dir that match our pattern
        files = [
            f for f in os.listdir(self.pictures_dir)
            if f[0:5] == "image" and
            os.path.isfile(os.path.join(self.pictures_dir, f))
        ]
        for f in files:
            os.remove(os.path.join(self.pictures_dir, f))

        # Wait for the camera to have finished focusing
        # (the exposure button gets enabled when ready)
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))
        self.assertThat(exposure_button.width, Eventually(NotEquals(0)))
        self.assertThat(exposure_button.height, Eventually(NotEquals(0)))

        # Now take the picture! (Give it a little time to animate)
        self.pointing_device.move_to_object(exposure_button)
        self.pointing_device.click()

        # Check that only one picture with the right name pattern
        # is actually there
        one_picture_on_disk = False
        for i in range(0, 10):
            files = [
                f for f in os.listdir(self.pictures_dir)
                if f[0:5] == "image" and
                os.path.isfile(os.path.join(self.pictures_dir, f))
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
        self.assertThat(exposure_button.width, Eventually(NotEquals(0)))
        self.assertThat(exposure_button.height, Eventually(NotEquals(0)))
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

    def test_hint_after_first_picture(self):
        hint = self.main_window.get_photo_roll_hint()
        photo_button = self.main_window.get_exposure_button()

        # Wait for the camera to be ready to take a picture
        self.assertThat(photo_button.enabled, Eventually(Equals(True)))
        self.assertThat(photo_button.width, Eventually(NotEquals(0)))
        self.assertThat(photo_button.height, Eventually(NotEquals(0)))

        # Check that the photo roll hint is hidden
        self.assertEquals(hint.visible, False)

        # Take a picture
        self.pointing_device.move_to_object(photo_button)
        self.pointing_device.click()

        # Check that the photo roll hint is displayed
        #self.assertEquals(hint.visible, True)
        self.assertThat(hint.visible, Eventually(Equals(True)))

        # Swipe to photo roll
        self.main_window.swipe_to_gallery(self)
        self.main_window.swipe_to_viewfinder(self)

        # Check that the photo roll hint is hidden
        self.assertEquals(hint.visible, False)

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

    """Test taking pictures at various levels of quality"""
    def test_picture_quality_setting(self):
        qualities = [("Basic Quality", 60),
                     ("Normal Quality", 80),
                     ("Fine Quality", 90)
                    ]
        for quality, expectedCompression in qualities:
            self.delete_all_photos()
            self.set_compression_quality(quality)
            self.take_picture()
            picture_file = self.get_first_picture()
            compression = self.get_compression_quality(picture_file)
            self.assertThat(compression, Equals(expectedCompression))
            self.dismiss_first_photo_hint()

    def delete_all_photos(self):
        picture_files = os.listdir(self.pictures_dir)
        for f in picture_files:
            os.remove(os.path.join(self.pictures_dir, f))

    def get_first_picture(self, timeout=10):
        pictures = []
        for i in range(0, timeout):
            pictures = os.listdir(self.pictures_dir)
            if len(pictures) != 0:
                break
            time.sleep(1)

        picture_file = os.path.join(self.pictures_dir, pictures[0])
        return picture_file

    def take_picture(self):
        exposure_button = self.main_window.get_exposure_button()

        # Wait for the camera to have finished focusing
        # (the exposure button gets enabled when ready)
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))
        self.assertThat(exposure_button.width, Eventually(NotEquals(0)))
        self.assertThat(exposure_button.height, Eventually(NotEquals(0)))

        # Press the shoot a picture button
        self.pointing_device.move_to_object(exposure_button)
        self.pointing_device.click()

    def get_compression_quality(self, picture_file):
        quality = 0
        with Image(filename=picture_file) as image:
            quality = image.compression_quality
        return quality

    def dismiss_first_photo_hint(self):
        # Swipe to photo roll and back to viewfinder
        self.main_window.swipe_to_gallery(self)
        self.main_window.swipe_to_viewfinder(self)

    def set_compression_quality(self, quality="Normal Quality"):
        # open bottom edge
        bottom_edge = self.main_window.get_bottom_edge()
        bottom_edge.open()

        # open encoding quality option value selector showing the possible values
        encoding_quality_button = self.main_window.get_encoding_quality_button()
        self.pointing_device.move_to_object(encoding_quality_button)
        self.pointing_device.click()
        option_value_selector = self.main_window.get_option_value_selector()
        self.assertThat(option_value_selector.visible, Eventually(Equals(True)))

        # tap on chosen compression quality option
        option = self.main_window.get_option_value_button(quality)
        self.pointing_device.move_to_object(option)
        self.pointing_device.click()

        bottom_edge.close()
