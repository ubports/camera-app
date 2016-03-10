# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2014, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App zoom"""

from testtools.matchers import Equals, NotEquals
from autopilot.matchers import Eventually

from camera_app.tests import CameraAppTestCase

from time import sleep


class TestCameraGalleryViewMixin(object):
    def move_from_slideshow_to_photogrid(self):
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

    def select_media(self, index=0):
        # select the photo with index, default to the first one
        gallery = self.main_window.get_gallery()
        photo = gallery.wait_select_single(objectName="mediaItem" + str(index))
        checkbox = photo.wait_select_single(objectName="mediaItemCheckBox")

        self.pointing_device.move_to_object(checkbox)

        if checkbox.visible:
            self.click()
        else:
            # do a long press to enter Multiselection mode
            self.pointing_device.press()
            sleep(1)
            self.pointing_device.release()


class TestCameraGalleryView(CameraAppTestCase, TestCameraGalleryViewMixin):
    """Tests the camera gallery view without media already present"""

    def setUp(self):
        self.delete_all_media()
        super(TestCameraGalleryView, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

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
        self.move_from_slideshow_to_photogrid()

    """Tests swiping to the gallery/photo roll with no media in it"""
    def test_swipe_to_empty_gallery(self):
        viewfinder = self.main_window.get_viewfinder()
        gallery = self.main_window.get_gallery()

        self.main_window.swipe_to_gallery(self)

        self.assertThat(viewfinder.inView, Eventually(Equals(False)))
        self.assertThat(gallery.inView, Eventually(Equals(True)))

        hint = self.main_window.get_no_media_hint()

        self.assertThat(hint.visible, Eventually(Equals(True)))

        # Take a picture and verify that the no media hint disappears
        self.main_window.swipe_to_viewfinder(self)
        exposure_button = self.main_window.get_exposure_button()
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))
        self.pointing_device.move_to_object(exposure_button)
        self.pointing_device.click()

        self.assertThat(hint.visible, Eventually(Equals(False)))


class TestCameraGalleryViewWithVideo(
        TestCameraGalleryViewMixin, CameraAppTestCase):
    """Tests the camera gallery view with video already present"""

    def setUp(self):
        self.delete_all_media()
        self.add_sample_video()

        super(TestCameraGalleryViewWithVideo, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestCameraGalleryViewWithVideo, self).tearDown()

    """Tests the thumnails for video load correctly in slideshow view"""
    def test_video_thumbnails(self):
        viewfinder = self.main_window.get_viewfinder()
        gallery = self.main_window.get_gallery()
        thumb_error = self.main_window.get_broken_video_icon()

        self.main_window.swipe_to_gallery(self)

        self.assertThat(viewfinder.inView, Eventually(Equals(False)))
        self.assertThat(gallery.inView, Eventually(Equals(True)))

        spinner = gallery.wait_select_single("ActivityIndicator")
        self.assertThat(spinner.running, Eventually(Equals(False)))
        self.assertThat(thumb_error.opacity, Eventually(Equals(0.0)))


class TestCameraGalleryViewWithBrokenVideo(
        TestCameraGalleryViewMixin, CameraAppTestCase):
    """Tests the camera gallery view with a broken video already present"""

    def setUp(self):
        self.delete_all_media()
        self.add_sample_video(broken=True)

        super(TestCameraGalleryViewWithBrokenVideo, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestCameraGalleryViewWithBrokenVideo, self).tearDown()

    """Tests the placeholder thumnails for broken video loads correctly"""
    def test_video_thumbnails(self):
        viewfinder = self.main_window.get_viewfinder()
        gallery = self.main_window.get_gallery()
        thumb_error = self.main_window.get_broken_video_icon()

        self.main_window.swipe_to_gallery(self)

        self.assertThat(viewfinder.inView, Eventually(Equals(False)))
        self.assertThat(gallery.inView, Eventually(Equals(True)))

        spinner = gallery.wait_select_single("ActivityIndicator")
        self.assertThat(spinner.running, Eventually(Equals(False)))
        self.assertThat(thumb_error.opacity, Eventually(NotEquals(0.0)))


class TestCameraGalleryViewWithPhoto(
        TestCameraGalleryViewMixin, CameraAppTestCase):
    """Tests the camera gallery view with photo already present"""

    def setUp(self):
        self.delete_all_media()
        self.add_sample_photo()

        super(TestCameraGalleryViewWithPhoto, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestCameraGalleryViewWithPhoto, self).tearDown()

    """Test deleting photo from multiselection"""
    def test_delete_photo_from_multiselection(self):
        self.main_window.swipe_to_gallery(self)
        self.move_from_slideshow_to_photogrid()
        self.select_media()

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

    """Tests entering/leaving multiselection mode in the photogrid view"""
    def test_multiselection_mode(self):
        self.main_window.swipe_to_gallery(self)
        self.move_from_slideshow_to_photogrid()
        self.select_media()

        # exit the multiselection mode
        gallery = self.main_window.get_gallery()
        back_button = gallery.wait_select_single(objectName="backButton")
        self.pointing_device.move_to_object(back_button)
        self.pointing_device.click()

        slideshow_view = gallery.wait_select_single("SlideshowView")
        photogrid_view = gallery.wait_select_single("PhotogridView")

        self.assertThat(slideshow_view.visible, Eventually(Equals(False)))
        self.assertThat(photogrid_view.visible, Eventually(Equals(True)))


class TestCameraGalleryViewWithPhotosAndVideo(
        TestCameraGalleryViewMixin, CameraAppTestCase):
    """Tests the camera gallery view with two photos and a video"""

    def setUp(self):
        self.delete_all_media()
        self.add_sample_photo()
        self.add_sample_video()

        super(TestCameraGalleryViewWithPhotosAndVideo, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestCameraGalleryViewWithPhotosAndVideo, self).tearDown()

    def verify_share_state(self, expectedState, close=True):
        # open actions drawer
        gallery = self.main_window.get_gallery()
        opt = gallery.wait_select_single(objectName="additionalActionsButton")
        self.pointing_device.move_to_object(opt)
        self.pointing_device.click()

        # verify expected state
        share = gallery.wait_select_single(objectName="actionButtonShare")
        self.assertThat(share.enabled, Eventually(Equals(expectedState)))

        if (close):
            # close actions drawer
            self.pointing_device.move_to_object(opt)
            self.pointing_device.click()
        else:
            return share

    """Tests share button enable or disabled correctly in multiselection"""
    def test_multiselection_share_enabled(self):
        self.main_window.swipe_to_gallery(self)
        self.move_from_slideshow_to_photogrid()

        # Verify options button disabled until we select something
        gallery = self.main_window.get_gallery()
        opt = gallery.wait_select_single(objectName="additionalActionsButton")
        self.assertThat(opt.visible, Eventually(Equals(False)))

        # Verify that if we select one photo options and share are enabled
        self.select_media(0)
        self.assertThat(opt.visible, Eventually(Equals(True)))
        self.verify_share_state(True)

        # Verify that it stays enabled with mixed media selected
        self.select_media(1)
        self.verify_share_state(True)

    """Tests sharing with mixed media generates a warning dialog"""
    def test_no_share_mixed_media(self):
        self.main_window.swipe_to_gallery(self)
        self.move_from_slideshow_to_photogrid()

        self.select_media(0)
        self.select_media(1)
        share = self.verify_share_state(True, close=False)

        self.pointing_device.move_to_object(share)
        self.pointing_device.click()

        gallery = self.main_window.get_gallery()
        gallery.wait_select_single(objectName="unableShareDialog")
