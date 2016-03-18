# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App"""

from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools.matchers import Equals, GreaterThan
from camera_app.tests import CameraAppTestCase

import unittest


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

    def verify_focus_ring_after_click_at(self, ring, x, y):
        # The focus ring should be invisible in the beginning
        self.assertThat(ring.opacity, Eventually(Equals(0.0)))

        focus_mouse_area = self.main_window.get_focus_mouse_area()
        self.assertThat(focus_mouse_area.enabled, Eventually(Equals(True)))

        # Click in the designated spot
        self.pointing_device.move(x, y)
        self.pointing_device.click()

        # The focus ring sould be visible now
        self.assertThat(ring.opacity, Eventually(GreaterThan(0.1)))

        # After some seconds the focus ring should fade out
        self.assertThat(ring.opacity, Eventually(Equals(0.0)))

    """Test focusing in an area where we know the picture is"""
    @unittest.skipIf(model() == 'Galaxy Nexus', 'Unusable with Mir on maguro')
    def test_focus_valid_and_disappear(self):
        geometry = self.main_window.get_viewfinder_geometry()
        focus_ring = self.main_window.get_focus_ring()
        switch_cameras = self.main_window.get_swap_camera_button()
        exposure_button = self.main_window.get_exposure_button()

        # Click in the center of the viewfinder area
        mid_x, mid_y = self.get_center(geometry)
        self.verify_focus_ring_after_click_at(focus_ring, mid_x, mid_y)

        # Then try on the side edges and top edge to verify they
        # are focusable too
        self.verify_focus_ring_after_click_at(focus_ring,
                                              geometry.globalRect.x + 1, mid_y)
        self.verify_focus_ring_after_click_at(focus_ring,
                                              geometry.globalRect.x +
                                              geometry.globalRect.width - 1,
                                              mid_y)
        self.verify_focus_ring_after_click_at(focus_ring, mid_x, 1)

        # Switch cameras, wait for camera to settle, and try again
        self.pointing_device.move_to_object(switch_cameras)
        self.pointing_device.click()
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))

        # Click in the center of the viewfinder area
        self.verify_focus_ring_after_click_at(focus_ring, mid_x, mid_y)

        # Then try on the left, right and above the center to verify they
        # are focusable too
        self.verify_focus_ring_after_click_at(focus_ring,
                                              geometry.globalRect.x + 1, mid_y)
        self.verify_focus_ring_after_click_at(focus_ring,
                                              geometry.globalRect.x +
                                              geometry.globalRect.width - 1,
                                              mid_y)
        self.verify_focus_ring_after_click_at(focus_ring, mid_x, 1)

    @unittest.skipIf(model() == 'Galaxy Nexus', 'Unusable with Mir on maguro')
    def test_focus_invalid(self):
        """Tests clicking outside of the viewfinder image area, where it should
        not focus."""
        bottom_edge = self.main_window.get_bottom_edge()
        zoom = self.main_window.get_zoom_control()
        feed = self.main_window.get_viewfinder_geometry()
        focus_ring = self.main_window.get_focus_ring()
        switch_cameras = self.main_window.get_swap_camera_button()
        exposure_button = self.main_window.get_exposure_button()

        # The focus ring should be invisible in the beginning
        self.assertThat(focus_ring.opacity, Eventually(Equals(0.0)))

        x, y, w, h = bottom_edge.globalRect
        tx = x + (w // 2)
        ty = y + h
        # Click at the bottom of the window. It should never focus there.
        self.pointing_device.move(tx, ty)
        self.pointing_device.click()
        self.assertThat(focus_ring.opacity, Eventually(Equals(0.0)))

        # Check if there's a gap between the viewfinder feed and the zoom
        # control. If there is, test that focusing there won't show the focus
        # ring.
        if zoom.y > feed.height:  # Feed is aligned to the top of the window
            x, y, h, w = zoom.globalRect
            click_coords = [x + (h // 2), y - 2]
            self.pointing_device.move(click_coords[0], click_coords[1])
            self.pointing_device.click()
        self.assertThat(focus_ring.opacity, Eventually(Equals(0.0)))

        # Switch cameras, wait for camera to settle, and try again
        self.pointing_device.move_to_object(switch_cameras)
        self.pointing_device.click()
        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))

        # Maybe we will have the gap when we switch the camera, test it again
        if zoom.y > feed.height:
            x, y, h, w = zoom.globalRect
            click_coords = [x + (h // 2), y - 2]
            self.pointing_device.move(click_coords[0], click_coords[1])
            self.pointing_device.click()
        self.assertThat(focus_ring.opacity, Eventually(Equals(0.0)))
