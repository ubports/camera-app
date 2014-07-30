# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App options overlay"""

from testtools.matchers import Equals
from autopilot.matchers import Eventually

from camera_app.tests import CameraAppTestCase

class TestCameraOptions(CameraAppTestCase):
    """Tests the options overlay"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestCameraOptions, self).setUp()
        # FIXME: this should be in parent class
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    """Test that the options overlay closes properly by tapping"""
    def test_overlay_tap_to_close(self):
        bottom_edge = self.main_window.get_bottom_edge()
        bottom_edge.open()

        # check overlay is opened
        self.assertThat(bottom_edge.opened, Eventually(Equals(True)))

        # tap to close overlay
        root = self.main_window.get_root()
        x = root.globalRect.x + root.width / 2.0
        y = root.globalRect.y + root.height / 4.0
        self.pointing_device.move(x, y)
        self.pointing_device.click()

        # check overlay is closed
        self.assertThat(bottom_edge.opened, Eventually(Equals(False)))
