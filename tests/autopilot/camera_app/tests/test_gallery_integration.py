# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from __future__ import absolute_import

from autopilot import introspection
from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools import skipIf
from testtools.matchers import Equals

from camera_app.tests import CameraAppTestCase

import os
import subprocess


@skipIf(model() == 'Desktop', "Phablet only")
class TestGalleryIntegration(CameraAppTestCase):

    upstart_override = os.path.expanduser("~/.config/upstart/unity8.override")

    def setUp(self):
        super(TestGalleryIntegration, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestGalleryIntegration, self).tearDown()
        subprocess.check_call(["pkill", "gallery-app"])

    def _restart_unity8_in_testability(self):
        """Adds an upstart override for unity8 and restarts it in
        testability.

        """
        open(self.upstart_override, 'w').write("exec unity8 -testability")
        # Incase unity8 is not already running, don't fail
        try:
            subprocess.check_call(["stop", "-q", "unity8"])
        except subprocess.CalledProcessError:
            pass

        subprocess.check_call(["start", "-q", "unity8"])

    def _get_unity8_proxy_object(self):
        conn = "com.canonical.Shell.BottomBarVisibilityCommunicator"
        try:
            return introspection.get_proxy_object_for_existing_process(
                connection_name=conn)
        except RuntimeError:
            # Didn't use logging here because we want to really print
            # on the screen that unity8 is being restart so that devs
            # may not think that their test suite hanged incase restarting
            # unity8 takes a few seconds.
            print("Could not find autopilot interface for unity8 "
                  "restarting it in testability mode")

            self._restart_unity8_in_testability()
            return introspection.get_proxy_object_for_existing_process(
                connection_name=conn)

    def _get_current_focused_appid(self, unity8):
        return unity8.select_single("Shell").currentFocusedAppId

    def test_gallery_button_opens_gallery(self):
        unity8 = self._get_unity8_proxy_object()
        current_focused_app = self._get_current_focused_appid(unity8)
        gallery_button = self.main_window.get_gallery_button()

        self.pointing_device.click_object(gallery_button)

        self.assertThat(current_focused_app, Eventually(Equals("gallery-app")))
