# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Camera-app autopilot tests."""

import os
import time

from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase

from camera_app.emulators.main_window import MainWindow
from camera_app.emulators.baseemulator import CameraCustomProxyObjectBase


class CameraAppTestCase(AutopilotTestCase):

    """A common test case class that provides several useful methods
    for camera-app tests.

    """
    if model() == 'Desktop':
        scenarios = [('with mouse', dict(input_device_class=Mouse))]
    else:
        scenarios = [('with touch', dict(input_device_class=Touch))]

    local_location = "../../camera-app"
    deb_location = '/usr/bin/camera-app'

    def setUp(self):
        self.pointing_device = Pointer(self.input_device_class.create())
        super(CameraAppTestCase, self).setUp()
        if os.path.exists(self.local_location):
            self.launch_test_local()
        elif os.path.exists(self.deb_location):
            self.launch_test_installed()
        else:
            self.launch_click_installed()

        #  wait and sleep as workaround for bug #1373039. To
        #  make sure large components get loaded asynchronously on start-up
        #  -- Chris Gagnon 11-17-2014
        self.main_window.get_qml_view().visible.wait_for(True)
        time.sleep(5)

    def launch_test_local(self):
        self.app = self.launch_test_application(
            self.local_location,
            emulator_base=CameraCustomProxyObjectBase)

    def launch_test_installed(self):
        if model() == 'Desktop':
            self.app = self.launch_test_application(
                "camera-app",
                emulator_base=CameraCustomProxyObjectBase)
        else:
            self.app = self.launch_test_application(
                "camera-app",
                "--fullscreen",
                "--desktop_file_hint="
                "/usr/share/applications/camera-app.desktop",
                app_type='qt',
                emulator_base=CameraCustomProxyObjectBase)

    def launch_click_installed(self):
        self.app = self.launch_click_package(
            "com.ubuntu.camera",
            emulator_base=CameraCustomProxyObjectBase)

    def get_center(self, object_proxy):
        x, y, w, h = object_proxy.globalRect
        return [x + (w // 2), y + (h // 2)]

    @property
    def main_window(self):
        return MainWindow(self.app)
