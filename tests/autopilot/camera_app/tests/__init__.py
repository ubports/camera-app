# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Camera-app autopilot tests."""

from os import remove
import os.path

from autopilot.introspection.qt import QtIntrospectionTestMixin
from autopilot.testcase import AutopilotTestCase

from camera_app.emulators.main_window import MainWindow

class CameraAppTestCase(AutopilotTestCase, QtIntrospectionTestMixin):

    """A common test case class that provides several useful methods for camera-app tests."""

    def setUp(self):
        super(CameraAppTestCase, self).setUp()
        # Lets assume we are installed system wide if this file is somewhere in /usr
        if os.path.realpath(__file__).startswith("/usr/"):
            self.launch_test_installed()
        else:
            self.launch_test_local()

    def launch_test_local(self):
        self.app = self.launch_test_application(
            "qmlscene",
            "-testability", "-I", "../..", "-I", "../../../../tavastia/modules",
            "../../camera-app.qml")

    def launch_test_installed(self):
        self.app = self.launch_test_application(
           "camera-app",
           "--fullscreen")

    @property
    def main_window(self):
        return MainWindow(self.app)

