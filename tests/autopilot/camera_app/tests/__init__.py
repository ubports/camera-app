# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Camera-app autopilot tests."""

from os import remove
import os.path

from autopilot.input import Mouse, Touch, Pointer
from autopilot.matchers import Eventually
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase
from testtools.matchers import Equals

from camera_app.emulators.main_window import MainWindow


class CameraAppTestCase(AutopilotTestCase):

    """A common test case class that provides several useful methods
    for camera-app tests.

    """
    if model() == 'Desktop':
        scenarios = [
        ('with mouse', dict(input_device_class=Mouse))]
    else:
        scenarios = [
        ('with touch', dict(input_device_class=Touch))]

    local_location = "../../camera-app"

    def setUp(self):
        self.pointing_device = Pointer(self.input_device_class.create())
        super(CameraAppTestCase, self).setUp()
        if os.path.exists(self.local_location):
            self.launch_test_local()
        else:
            self.launch_test_installed()

    def launch_test_local(self):
        self.app = self.launch_test_application(
            self.local_location)

    def launch_test_installed(self):
        if model() == 'Desktop':
            self.app = self.launch_test_application(
                "camera-app")
        else:
            self.app = self.launch_test_application(
                "camera-app",
                "--fullscreen",
                "--desktop_file_hint=/usr/share/applications/camera-app.desktop",
                app_type='qt')

    def get_center(self, object_proxy):
        x, y, w, h = object_proxy.globalRect
        return [x + (w / 2), y + (h / 2)]

    @property
    def main_window(self):
        return MainWindow(self.app)
