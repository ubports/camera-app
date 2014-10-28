# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App zoom"""

from testtools.matchers import Equals, NotEquals, GreaterThan, LessThan
from autopilot.matchers import Eventually

from camera_app.tests import CameraAppTestCase

import unittest
import os


class TestCameraGalleryView(CameraAppTestCase):
    """Tests the main camera features"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestCameraGalleryView, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))
        self.pictures_dir = os.path.expanduser("~/Pictures/com.ubuntu.camera")
        self.videos_dir = os.path.expanduser("~/Videos/com.ubuntu.camera")

    def tearDown(self):
        super(TestCameraGalleryView, self).tearDown()

    """Tests swiping to the gallery and pressing the back button"""
    def test_swipe_to_gallery(self):
        viewfinder = self.main_window.get_viewfinder()
        gallery = self.main_window.get_gallery()

        self.main_window.swipe_to_gallery(self)

        self.assertThat(viewfinder.inView, Eventually(Equals(False)))
        self.assertThat(gallery.inView, Eventually(Equals(True)))

        back_button = gallery.wait_select_single(objectName="backButton")
        self.pointing_device.move_to_object(back_button)
        self.pointing_device.click()

        self.assertThat(viewfinder.inView, Eventually(Equals(True)))
        self.assertThat(gallery.inView, Eventually(Equals(False)))

    """Tests toggling between grid and slideshow views"""
    def test_toggling_view_type(self):
        self.main_window.swipe_to_gallery(self)

        gallery = self.main_window.get_gallery()
        slideshow_view = gallery.wait_select_single("SlideshowView")
        photogrid_view = gallery.wait_select_single("PhotogridView")

        self.assertThat(slideshow_view.visible, Eventually(Equals(True)))
        self.assertThat(photogrid_view.visible, Eventually(Equals(False)))

        button = gallery.wait_select_single(objectName="viewToggleButton")
        self.pointing_device.move_to_object(button)
        self.pointing_device.click()

        slideshow_view = gallery.wait_select_single("SlideshowView")
        photogrid_view = gallery.wait_select_single("PhotogridView")

        self.assertThat(slideshow_view.visible, Eventually(Equals(False)))
        self.assertThat(photogrid_view.visible, Eventually(Equals(True)))

    def delete_all_media(self):
        picture_files = os.listdir(self.pictures_dir)
        for f in picture_files:
            os.remove(os.path.join(self.pictures_dir, f))

        video_files = os.listdir(self.videos_dir)
        for f in video_files:
            os.remove(os.path.join(self.videos_dir, f))

    """Tests swiping to the gallery/photo roll with no media in it"""
    def test_swipe_to_empty_gallery(self):
        self.delete_all_media()
        viewfinder = self.main_window.get_viewfinder()
        gallery = self.main_window.get_gallery()

        self.main_window.swipe_to_gallery(self)

        self.assertThat(viewfinder.inView, Eventually(Equals(False)))
        self.assertThat(gallery.inView, Eventually(Equals(True)))

        hint = self.main_window.get_no_media_hint()

        self.assertThat(hint.visible, Eventually(Equals(True)))

        # add a fake photo to pictures_dir
        photo_path = os.path.join(self.pictures_dir, "fake_photo.jpg")
        with open(photo_path, 'a'):
            os.utime(photo_path, None)

        self.assertThat(hint.visible, Eventually(Equals(False)))
