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
from time import sleep


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

    def move_from_slideshow_to_photogrid(self):
        # make sure we move from slideshow to photogrid view
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
            f = os.path.join(self.pictures_dir, f)
            if os.path.isfile(f):
                os.remove(f)

        video_files = os.listdir(self.videos_dir)
        for f in video_files:
            f = os.path.join(self.videos_dir, f)
            if os.path.isfile(f):
                os.remove(f)

    def add_sample_photo(self):
        self.main_window.swipe_to_viewfinder(self)
        exposure_button = self.main_window.get_exposure_button()
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))
        self.pointing_device.move_to_object(exposure_button)
        self.pointing_device.click()

    def add_sample_video(self):
        self.main_window.swipe_to_viewfinder(self)
        video_button = self.main_window.get_record_control()
        self.pointing_device.move_to_object(video_button)
        self.pointing_device.click()

        exposure_button = self.main_window.get_exposure_button()
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))
        self.pointing_device.move_to_object(exposure_button)
        self.pointing_device.click()
        sleep(3)
        self.pointing_device.click()

    def select_first_photo(self):
        # select the first photo
        gallery = self.main_window.get_gallery()
        photo = gallery.wait_select_single(objectName="mediaItem0")
        self.pointing_device.move_to_object(photo)

        # do a long press to enter Multiselection mode
        self.pointing_device.press()
        sleep(1)
        self.pointing_device.release()

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
        self.move_from_slideshow_to_photogrid()

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

        self.add_sample_photo()

        self.assertThat(hint.visible, Eventually(Equals(False)))

    """Tests the thumnails for video load correctly in slideshow view"""
    def test_video_thumbnails(self):
        self.add_sample_video()
        self.delete_all_media()
        viewfinder = self.main_window.get_viewfinder()
        gallery = self.main_window.get_gallery()

        self.main_window.swipe_to_gallery(self)

        self.assertThat(viewfinder.inView, Eventually(Equals(False)))
        self.assertThat(gallery.inView, Eventually(Equals(True)))

        spinner = gallery.wait_select_single("ActivityIndicator")
        self.assertThat(spinner.running, Eventually(Equals(False)))

    """Tests entering/leaving multiselection mode in the photogrid view"""
    def test_multiselection_mode(self):
        self.add_sample_photo()
        self.main_window.swipe_to_gallery(self)
        self.move_from_slideshow_to_photogrid()
        self.select_first_photo()

        # exit the multiselection mode
        gallery = self.main_window.get_gallery()
        back_button = gallery.wait_select_single(objectName="backButton")
        self.pointing_device.move_to_object(back_button)
        self.pointing_device.click()

        slideshow_view = gallery.wait_select_single("SlideshowView")
        photogrid_view = gallery.wait_select_single("PhotogridView")

        self.assertThat(slideshow_view.visible, Eventually(Equals(False)))
        self.assertThat(photogrid_view.visible, Eventually(Equals(True)))

    """Test deleting photo from multiselection"""
    def test_delete_photo_from_multiselection(self):
        self.delete_all_media()
        self.add_sample_photo()
        self.main_window.swipe_to_gallery(self)
        self.move_from_slideshow_to_photogrid()
        self.select_first_photo()

        # open actions drawer
        gallery = self.main_window.get_gallery()
        opt = gallery.wait_select_single(objectName="additionalActionsButton")
        self.pointing_device.move_to_object(opt)
        self.pointing_device.click()

        # click delete action button
        delete = gallery.wait_select_single(objectName="actionButtonDelete")
        self.pointing_device.move_to_object(delete)
        self.pointing_device.click()

        # click confirm button on dialog
        confirm = self.app.wait_select_single(objectName="deleteButton")
        self.pointing_device.move_to_object(confirm)
        self.pointing_device.click()

        hint = self.main_window.get_no_media_hint()
        self.assertThat(hint.visible, Eventually(Equals(True)))
