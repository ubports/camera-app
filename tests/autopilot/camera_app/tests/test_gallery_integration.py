# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from __future__ import absolute_import

from autopilot.introspection import get_proxy_object_for_existing_process
from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools import skipIf
from testtools.matchers import Equals

from camera_app.tests import CameraAppTestCase
from unity8 import process_helpers as helpers

import os


@skipIf(model() == 'Desktop', "Phablet only")
class TestGalleryIntegration(CameraAppTestCase):

    def setUp(self):
        super(TestGalleryIntegration, self).setUp()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestGalleryIntegration, self).tearDown()
        os.system("pkill gallery-app")

    def get_unity8_proxy_object(self):
        pid = helpers._get_unity_pid()
        return get_proxy_object_for_existing_process(pid)

    def get_current_focused_appid(self):
        return self.select_single("Shell").currentFocusedAppId

    def test_gallery_button_opens_gallery(self):
        gallery_button = self.main_window.get_gallery_button()
        unity8 = self.get_unity8_proxy_object()
        current_focused_app = unity8.get_current_focused_appid()

        self.pointing_device.click_object(gallery_button)

        self.assertThat(current_focused_app, Eventually(Equals("gallery-app")))
