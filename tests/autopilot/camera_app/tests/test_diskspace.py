# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Camera App in low disk space situations"""

from testtools.matchers import Equals, NotEquals, GreaterThan, LessThan
from autopilot.matchers import Eventually

from camera_app.tests import CameraAppTestCase

import os.path
import os
from ctypes import CDLL, c_longlong as ll

MEGABYTE = 1024 * 1024
LOW_THRESHOLD = 200 * MEGABYTE
CRITICAL_THRESHOLD = 50 * MEGABYTE


class TestCameraDiskSpace(CameraAppTestCase):
    """Tests low disk space situations"""

    def diskSpaceAvailable(self):
        """Check the amount of free disk space"""
        stats = os.statvfs(os.path.expanduser(self.videoPath))
        return stats.f_bavail * stats.f_frsize

    def setFreeSpaceTo(self, size):
        """Reduce the amount of space available to 'size'"""

        # Take into account the currently existing filler file, if any, as we
        # will be overwriting it to the new size.
        fillerSize = (
            self.diskSpaceAvailable() + self.currentFillerSize) - size
        fd = open(self.diskFiller, "w")
        ret = CDLL("libc.so.6").posix_fallocate64(
            fd.fileno(), ll(0), ll(fillerSize))
        self.assertThat(ret, Equals(0))
        self.currentFillerSize = fillerSize

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestCameraDiskSpace, self).setUp()

        # We write the filler file in the same directory as the Videos, so that
        # we are sure we are filling up the same filesystem
        self.videoPath = os.path.expanduser("~/Videos/")
        self.diskFiller = os.path.join(self.videoPath, "filler")
        self.currentFillerSize = 0

        # remove the filler file before starting, in case a previous test
        # crashed
        os.remove(self.diskFiller) if os.path.exists(self.diskFiller) else None

        # we can't start tests when the disk space is already below the
        # threshold as they all expect a normal situation at the start
        self.assertThat(self.diskSpaceAvailable(), GreaterThan(LOW_THRESHOLD))

    def tearDown(self):
        super(TestCameraDiskSpace, self).tearDown()
        os.remove(self.diskFiller) if os.path.exists(self.diskFiller) else None

    def test_critically_low_disk(self):
        """Verify proper behavior when disk space becomes critically low and
        back"""

        exposure_button = self.main_window.get_exposure_button()
        no_space_hint = self.main_window.get_no_space_hint()

        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))
        self.assertThat(no_space_hint.visible, Eventually(Equals(False)))

        self.setFreeSpaceTo(CRITICAL_THRESHOLD - MEGABYTE)
        self.assertThat(
            self.diskSpaceAvailable(), LessThan(CRITICAL_THRESHOLD))

        self.assertThat(exposure_button.enabled, Eventually(Equals(False)))
        self.assertThat(no_space_hint.visible, Eventually(Equals(True)))

        self.setFreeSpaceTo(CRITICAL_THRESHOLD + MEGABYTE)
        self.assertThat(
            self.diskSpaceAvailable(), GreaterThan(CRITICAL_THRESHOLD))

        self.assertThat(exposure_button.enabled, Eventually(Equals(True)))
        self.assertThat(no_space_hint.visible, Eventually(Equals(False)))

    def test_low_disk(self):
        """Verify proper behavior when disk space becomes low"""
        self.main_window.get_exposure_button()
        self.main_window.get_no_space_hint()
        dialog = self.main_window.get_low_space_dialog()
        self.assertThat(dialog, Equals(None))

        self.setFreeSpaceTo(LOW_THRESHOLD - MEGABYTE)
        self.assertThat(self.diskSpaceAvailable(), LessThan(LOW_THRESHOLD))

        dialog = self.main_window.get_low_space_dialog()
        self.assertThat(dialog.visible, Eventually(Equals(True)))

    def test_recording_stop(self):
        """Verify recording is stopped on critically low disk space"""

        record_control = self.main_window.get_record_control()
        stop_watch = self.main_window.get_stop_watch()
        exposure_button = self.main_window.get_exposure_button()

        # Click the record button to toggle photo/video mode then start
        # recording
        self.pointing_device.move_to_object(record_control)
        self.pointing_device.click()
        self.pointing_device.move_to_object(exposure_button)
        self.pointing_device.click()

        # Start recording video
        self.assertThat(stop_watch.opacity, Eventually(Equals(1.0)))
        self.assertThat(stop_watch.label, Eventually(NotEquals("00:00")))

        # Now reduce the space to critically low, then see if recording stops
        self.setFreeSpaceTo(CRITICAL_THRESHOLD - MEGABYTE)
        self.assertThat(
            self.diskSpaceAvailable(), LessThan(CRITICAL_THRESHOLD))
        self.assertThat(stop_watch.opacity, Eventually(Equals(0.0)))
