# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App flash"""

from testtools.matchers import Equals, NotEquals
from autopilot.matchers import Eventually

from camera_app.tests import CameraAppTestCase

import unittest
import os.path
import os
from ctypes import *

LOW_THRESHOLD = 200
CRITICAL_THRESHOLD = 50
MEGABYTE = 1024 * 1024

class TestCameraDiskSpace(CameraAppTestCase):
    """Tests low disk space situations"""

    def diskSpaceAvailable(self):
        stats = os.statvfs(os.path.expanduser("~"))
        return stats.f_bavail * stats.f_frsize

    def setFreeSpaceTo(self, size):
        fillerSize = (self.diskSpaceAvailable() + self.currentFillerSize) - size
        self.currentFillerSize = fillerSize

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestCameraDiskSpace, self).setUp()

        videoPath = os.path.expanduser("~/Videos/")
        self.diskFiller = os.path.join(videoPath, "filler")
        self.diskFillerFile = open(self.diskFiller, "w")
        self.currentFillerSize = 0
        self.libc = CDLL("libc.so.6")

        # we can't start tests when the disk space is already below the threshold
        self.assertThat(self.diskSpaceAvailable(), GreaterThan(LOW_THRESHOLD * MEGABYTE));
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestCameraDiskSpace, self).tearDown()
        self.diskFillerFile.close()
        os.remove(self.diskFiller)

    def test_low_disk(self):
        pass
