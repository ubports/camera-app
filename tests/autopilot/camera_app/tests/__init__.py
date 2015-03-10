# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Camera-app autopilot tests."""

import os
import time
import shutil
from time import sleep
from pkg_resources import resource_filename

from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase
from autopilot.matchers import Eventually
from testtools.matchers import Equals

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

    pictures_dir = os.path.expanduser("~/Pictures/com.ubuntu.camera")
    videos_dir = os.path.expanduser("~/Videos/com.ubuntu.camera")
    sample_dir = resource_filename('camera_app', 'data')

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
        shutil.copyfile(os.path.join(self.sample_dir, "sample.jpg"),
                        os.path.join(self.pictures_dir, "sample.jpg"))

    def add_sample_video(self):
        shutil.copyfile(os.path.join(self.sample_dir, "sample.mp4"),
                        os.path.join(self.videos_dir, "sample.mp4"))
