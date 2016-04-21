# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Camera-app autopilot tests."""

import os
import shutil
from pkg_resources import resource_filename

import ubuntuuitoolkit
from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase

from camera_app.emulators.main_window import MainWindow
from camera_app.ubuntu_system_tests.helpers.camera.fixture_setup import (
    SetCameraAccessRequests)


CUSTOM_PROXY_OBJECT_BASE = ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase


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
        self.useFixture(SetCameraAccessRequests())
        # Remove configuration file
        config_file = os.path.expanduser(
            "~/.config/com.ubuntu.camera/com.ubuntu.camera.conf")
        if os.path.exists(config_file):
            os.remove(config_file)

        self.pointing_device = Pointer(self.input_device_class.create())
        super(CameraAppTestCase, self).setUp()
        if os.path.exists(self.local_location):
            self.launch_test_local()
        elif os.path.exists(self.deb_location):
            self.launch_test_installed()
        else:
            self.launch_click_installed()

        self.main_window.get_qml_view().visible.wait_for(True)

    def launch_test_local(self):
        self.app = self.launch_test_application(
            self.local_location,
            emulator_base=CUSTOM_PROXY_OBJECT_BASE)

    def launch_test_installed(self):
        if model() == 'Desktop':
            self.app = self.launch_test_application(
                "camera-app",
                emulator_base=CUSTOM_PROXY_OBJECT_BASE)
        else:
            self.app = self.launch_test_application(
                "camera-app",
                "--fullscreen",
                "--desktop_file_hint="
                "/usr/share/applications/camera-app.desktop",
                app_type='qt',
                emulator_base=CUSTOM_PROXY_OBJECT_BASE)

    def launch_click_installed(self):
        self.app = self.launch_click_package(
            "com.ubuntu.camera",
            emulator_base=CUSTOM_PROXY_OBJECT_BASE)

    def get_center(self, object_proxy):
        x, y, w, h = object_proxy.globalRect
        return [x + (w // 2), y + (h // 2)]

    @property
    def main_window(self):
        return MainWindow(self.app)

    def delete_all_media(self):
        if os.path.exists(self.pictures_dir):
            self.delete_all_files_in_directory(self.pictures_dir)

        if os.path.exists(self.videos_dir):
            self.delete_all_files_in_directory(self.videos_dir)

    def delete_all_files_in_directory(self, directory):
        files = os.listdir(directory)
        for f in files:
            f = os.path.join(directory, f)
            if os.path.isfile(f):
                os.remove(f)

    def add_sample_photo(self):
        shutil.copyfile(os.path.join(self.sample_dir, "sample.jpg"),
                        os.path.join(self.pictures_dir, "sample.jpg"))

    def add_sample_video(self, broken=False):
        if broken:
            path = os.path.join(self.videos_dir, "sample_broken.mp4")
            with open(path, "w") as video:
                video.write("I AM NOT A VIDEO")
        else:
            shutil.copyfile(os.path.join(self.sample_dir, "sample.mp4"),
                            os.path.join(self.videos_dir, "sample.mp4"))
