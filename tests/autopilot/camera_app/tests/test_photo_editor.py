# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2014, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera photo editor"""

from testtools.matchers import Equals
from autopilot.matchers import Eventually
from autopilot.exceptions import StateNotFoundError

from camera_app.tests import CameraAppTestCase


class TestCameraPhotoEditorWithPhoto(CameraAppTestCase):
    """Tests photo editor when a photo is present"""

    def setUp(self):
        self.delete_all_media()
        self.add_sample_photo()
        super(TestCameraPhotoEditorWithPhoto, self).setUp()

    """Tests editor opening and closing correctly for pictures"""
    def test_editor_appears(self):

        self.main_window.get_viewfinder()
        gallery = self.main_window.get_gallery()

        self.main_window.swipe_to_gallery(self)

        self.assertThat(gallery.inView, Eventually(Equals(True)))
        self.main_window.open_actions_drawer(gallery)

        # If the editor button is not there when in the gallery view, then
        # we are not on a system that has the UI extras package installed or
        # has an older version than the one we need. Skip the test in this
        # case.
        try:
            edit = gallery.wait_select_single(objectName="actionButtonEdit")
        except:
            return

        self.assertThat(edit.enabled, Eventually(Equals(True)))
        self.pointing_device.move_to_object(edit)
        self.pointing_device.click()

        editor = gallery.wait_select_single(objectName="photoEditor")
        self.assertThat(editor.visible, Eventually(Equals(True)))

        back = gallery.wait_select_single(objectName="backButton")
        self.pointing_device.move_to_object(back)
        self.pointing_device.click()

        disappeared = False
        try:
            gallery.select_single(objectName="photoEditor")
        except StateNotFoundError:
            disappeared = True
        self.assertThat(disappeared, Equals(True))


class TestCameraPhotoEditorWithVideo(CameraAppTestCase):
    """Tests photo editor when a video is present"""

    def setUp(self):
        self.delete_all_media()
        self.add_sample_video()
        super(TestCameraPhotoEditorWithVideo, self).setUp()

    """Tests editor not being available for videos"""
    def test_editor_not_on_videos(self):
        self.add_sample_video()

        self.main_window.get_viewfinder()
        gallery = self.main_window.get_gallery()

        self.main_window.swipe_to_gallery(self)

        self.assertThat(gallery.inView, Eventually(Equals(True)))
        self.main_window.open_actions_drawer(gallery)

        # If the editor button is not there when in the gallery view, then
        # we are not on a system that has the UI extras package installed or
        # has an older version than the one we need. Skip the test in this
        # case.
        try:
            edit = gallery.wait_select_single(objectName="actionButtonEdit")
        except:
            return

        self.assertThat(edit.enabled, Equals(False))
