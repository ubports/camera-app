# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

#
# Ubuntu System Tests
# Copyright (C) 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

import fixtures
import os

from camera_app.ubuntu_system_tests.helpers import file_system as fs
from camera_app.ubuntu_system_tests.helpers.backup_restore_fixture import (
    BackupRestoreRequestAccessFixture)

SERVICE_DB = os.path.join(fs.DIR_HOME_LOCAL, 'share', 'CameraService',
                          'trust.db')
AUDIO_DB = os.path.join(fs.DIR_HOME_LOCAL, 'share', 'PulseAudio', 'trust.db')

FEATURE = 0
APP_ID = 'com.ubuntu.camera_camera'


class SetCameraAccessRequests(fixtures.Fixture):
    """ Fill the camera and audio access request for the camera app and
    restore their initial state during the cleanup. """

    def __init__(self, camera=True, audio=True):
        """ Init the fixture
        :param camera: Desired answer for the camera service
        :param audio: Desired answer for the audio service
        """
        self.camera = camera
        self.audio = audio

    def setUp(self):
        super().setUp()

        self.useFixture(BackupRestoreRequestAccessFixture(SERVICE_DB,
                                                          APP_ID,
                                                          FEATURE,
                                                          self.camera))
        self.useFixture(BackupRestoreRequestAccessFixture(AUDIO_DB,
                                                          APP_ID,
                                                          FEATURE,
                                                          self.audio))
