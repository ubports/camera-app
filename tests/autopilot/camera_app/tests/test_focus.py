# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App"""

from __future__ import absolute_import

from testtools.matchers import Equals, NotEquals, GreaterThan
from autopilot.matchers import Eventually

from camera_app.tests import CameraAppTestCase

import unittest
import time


class TestFocus(CameraAppTestCase):
    """Tests the focus"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestFocus, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestFocus, self).tearDown()

    """Test focusing in an area where we know the picture is"""
    def test_focus_valid_and_disappear(self):
        camera_window = self.main_window.get_camera()
        focus_ring = self.main_window.get_focus_ring()
        toolbar = self.main_window.get_toolbar()
        feed = self.main_window.get_viewfinder_geometry()
        switch_cameras = self.main_window.get_swap_camera_button()
        exposure_button = self.main_window.get_exposure_button()

        # The focus ring should be invisible in the beginning
        self.assertEquals(focus_ring.opacity, Eventually(0.0))

        self.pointing_device.move_to_object(feed)
        self.pointing_device.click()
        click_coords = list(self.pointing_device.position())

        # The focus ring sould be visible and centered to the mouse click
        # coords now
        focus_ring_center = self.get_center(focus_ring)
        self.assertThat(focus_ring.opacity, Eventually(Equals(1.0)))
        self.assertEquals(focus_ring_center, click_coords)

        # After some seconds the focus ring should fade out
        self.assertThat(focus_ring.opacity, Eventually(Equals(0.0)))

        # Switch cameras, wait for camera to settle, and try again
        self.pointing_device.move_to_object(switch_cameras)
        self.pointing_device.click()
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))

        # Click in the center of the viewfinder area
        click_coords =[feed.globalRect[2] / 2 + feed.globalRect[0], feed.globalRect[3] / 2 + feed.globalRect[1]]
        self.pointing_device.move(click_coords[0], click_coords[1])
        self.pointing_device.click()

        # The focus ring sould be visible and centered to the mouse
        # click coords now
        focus_ring_center = self.get_center(focus_ring)
        self.assertThat(focus_ring.opacity, Eventually(Equals(1.0)))
        self.assertEquals(focus_ring_center, click_coords)

        # After some seconds the focus ring should fade out
        self.assertThat(focus_ring.opacity, Eventually(Equals(0.0)))

    def test_focus_invalid(self):
        """Tests clicking outside of the viewfinder image area, where it should
        not focus."""
        camera_window = self.main_window.get_camera()
        toolbar = self.main_window.get_toolbar()
        zoom = self.main_window.get_zoom_control()
        feed = self.main_window.get_viewfinder_geometry()
        focus_ring = self.main_window.get_focus_ring()
        switch_cameras = self.main_window.get_swap_camera_button()
        exposure_button = self.main_window.get_exposure_button()

        # The focus ring should be invisible in the beginning
        self.assertEquals(focus_ring.opacity, Eventually(0.0))

        x, y, h, w = toolbar.globalRect
        tx = x + (h / 2)
        ty = y + (w + 2)
        # Click at the bottom of the window below the toolbar. It should never
        # focus there.
        self.pointing_device.move(tx, ty)
        self.pointing_device.click()
        self.assertEquals(focus_ring.opacity, Eventually(0.0))

        # Check if there's a gap between the viewfinder feed and the zoom
        # control. If there is, test that focusing there won't show the focus
        #ring.
        if zoom.y > feed.height: # Feed is aligned to the top of the window
            x, y, h, w = zoom.globalRect
            click_coords = [x + (h / 2), y - 2]
            self.pointing_device.move(click_coords[0], click_coords[1])
            self.pointing_device.click()
        self.assertEquals(focus_ring.opacity, Eventually(0.0))

        # Switch cameras, wait for camera to settle, and try again
        self.pointing_device.move_to_object(switch_cameras)
        self.pointing_device.click()
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))

        # Maybe we will have the gap when we switch the camera, test it again
        if zoom.y > feed.height:
            x, y, h, w = zoom.globalRect
            click_coords = [x + (h / 2), y - 2]
            self.pointing_device.move(click_coords[0], click_coords[1])
            self.pointing_device.click()
        self.assertEquals(focus_ring.opacity, Eventually(0.0))

    """Tests dragging the focus ring"""
    def test_move_focus_ring(self):
        camera_window = self.main_window.get_camera()
        focus_ring = self.main_window.get_focus_ring()
        feed = self.main_window.get_viewfinder_geometry()
        switch_cameras = self.main_window.get_swap_camera_button()
        exposure_button = self.main_window.get_exposure_button()

        # The focus ring should be invisible in the beginning
        self.assertEquals(focus_ring.opacity, Eventually(0.0))

        # Focus to the center of the viewfinder feed
        self.pointing_device.move_to_object(feed)
        self.pointing_device.click()
        center_click_coords = list(self.pointing_device.position())

        focus_ring_center = self.get_center(focus_ring)
        self.assertThat(focus_ring.opacity, Eventually(Equals(1.0)))
        self.assertEquals(focus_ring_center, center_click_coords)

        # Now drag it halfway across the feed, verify that it has moved there
        tx = focus_ring_center[0]
        ty = focus_ring_center[1]
        self.pointing_device.drag(tx, ty, tx / 2, ty / 2)

        focus_ring_center = self.get_center(focus_ring)
        self.assertThat(focus_ring_center[1], GreaterThan(ty / 2 - 2))

        # Switch cameras, wait for camera to settle, and try again
        self.pointing_device.move_to_object(switch_cameras)
        self.pointing_device.click()
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))

        self.pointing_device.move_to_object(feed)
        self.pointing_device.click()
        center_click_coords = list(self.pointing_device.position())

        focus_ring_center = self.get_center(focus_ring)
        self.assertThat(focus_ring.opacity, Eventually(Equals(1.0)))
        self.assertEquals(focus_ring_center, center_click_coords)

        tx = focus_ring_center[0]
        ty = focus_ring_center[1]
        self.pointing_device.drag(tx, ty, tx / 2, ty / 2)

        focus_ring_center = self.get_center(focus_ring)
        self.assertThat(focus_ring_center[1], GreaterThan(ty / 2 - 2))
