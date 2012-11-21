# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App zoom"""

from __future__ import absolute_import

from testtools.matchers import Equals, NotEquals, GreaterThan, LessThan
from autopilot.matchers import Eventually

from camera_app.tests import CameraAppTestCase

import time

class TestCameraZoom(CameraAppTestCase):
    """Tests the main camera features"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestCameraZoom, self).setUp()
        self.assertThat(self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestCameraZoom, self).tearDown()

    """Tests the zoom slider"""
    def test_slider(self):
        camera_window = self.main_window.get_camera()
        zoom_control = self.main_window.get_zoom_control()

        zoom_button = self.main_window.get_zoom_slider_button()

        self.mouse.move_to_object(zoom_button)
        self.mouse.press()
        self.mouse.move(self.mouse.x + zoom_control.width, self.mouse.y)
        self.mouse.release()
        self.assertThat(zoom_control.value, Eventually(Equals(6.0)))

        self.mouse.move_to_object(zoom_button)
        self.mouse.press()
        self.mouse.move(zoom_control.x, self.mouse.y)
        self.mouse.release()
        self.assertThat(zoom_control.value, Eventually(Equals(1.0)))

    """Tests the plus and minus buttons"""
    def test_plus_minus(self):
        zoom_control = self.main_window.get_zoom_control()
        plus = self.main_window.get_zoom_plus()
        minus = self.main_window.get_zoom_minus()

        # Test that minus when at minimum zoom does nothing
        self.assertThat(zoom_control.value, Eventually(Equals(1.0)))
        self.mouse.move_to_object(minus)
        self.mouse.click()
        self.assertThat(zoom_control.value, Eventually(Equals(1.0)))

        # Test that plus moves to some non-minimum value
        # and that minus goes back to the minimum
        self.assertEqual(zoom_control.value, 1.0)
        self.mouse.move_to_object(plus)
        self.mouse.click()
        self.assertThat(zoom_control.value, Eventually(GreaterThan(1.0)))

        value_before_minus = zoom_control.value

        self.mouse.move_to_object(minus)
        self.mouse.click()
        self.assertThat(zoom_control.value, Eventually(LessThan(value_before_minus)))

        # Test that keeping the plus button pressed eventually reaches max zoom
        self.mouse.move_to_object(plus)
        self.mouse.press()
        self.assertThat(zoom_control.value, Eventually(Equals(6.0)))
        self.mouse.release()

        # Test that plus when at maximum zoom does nothing
        self.assertThat(zoom_control.value, Eventually(Equals(6.0)))
        self.mouse.move_to_object(plus)
        self.mouse.click()
        self.assertThat(zoom_control.value, Eventually(Equals(6.0)))

        # Test that minus moves to some non-maximum value
        # and that plus goes back up
        self.assertThat(zoom_control.value, Eventually(Equals(6.0)))
        self.mouse.move_to_object(minus)
        self.mouse.click()
        self.assertThat(zoom_control.value, Eventually(NotEquals(6.0)))

        value_before_plus = zoom_control.value

        self.mouse.move_to_object(plus)
        self.mouse.click()
        self.assertThat(zoom_control.value, Eventually(GreaterThan(value_before_plus)))

        # Test that keeping the minus button pressed eventually reaches min zoom
        self.mouse.move_to_object(minus)
        self.mouse.press()
        self.assertThat(zoom_control.value, Eventually(Equals(1.0)))
        self.mouse.release()

