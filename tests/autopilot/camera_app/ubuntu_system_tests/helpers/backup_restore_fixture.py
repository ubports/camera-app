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
import shutil
import time

from camera_app.ubuntu_system_tests.helpers import file_system as fs
from camera_app.ubuntu_system_tests.helpers import sqlite

DEFAULT_STORE_ROOT = os.path.expanduser('~/.tmp_backup')


class BackupRestoreFixture(fixtures.Fixture):
    """Generic fixture class to backup and restore a specific directory."""

    def __init__(self, backup_dir, storage_root_dir=DEFAULT_STORE_ROOT,
                 start_clean=True):
        """
        :param backup_dir: Directory to be backed up.
        :param storage_root_dir: Root directoty to use as backup.
        :param start_clean: Whether to clean the backup directory.
        """
        if not os.path.exists(storage_root_dir):
            os.makedirs(storage_root_dir)
        self.backup_dir = backup_dir
        self.storage_dir = fixtures.TempDir(storage_root_dir)
        self.start_clean = start_clean

    def setUp(self):
        """Backup the required directory and register restore actions."""
        super().setUp()
        self.useFixture(self.storage_dir)
        self.addCleanup(self._restore_directory)
        shutil.rmtree(self.storage_dir.path)
        if os.path.exists(self.backup_dir):
            if self.start_clean:
                fs.move_folder_contents(self.backup_dir, self.storage_dir.path)
            else:
                shutil.copytree(self.backup_dir, self.storage_dir.path)

    def _restore_directory(self):
        """Move the backup data back to original location."""
        if os.path.exists(self.backup_dir):
            fs.clean_dir(self.backup_dir)
        if os.path.exists(self.storage_dir.path):
            fs.move_folder_contents(self.storage_dir.path, self.backup_dir)


class BackupRestoreRequestAccessFixture(fixtures.Fixture):
    """Fill the access requests for the an app by adding the answer in the
    its db and restoring the original data after the test execution."""

    REQUESTS_SCHEMA = 'ApplicationId, Feature, Timestamp, Answer'

    def __init__(self, db, app_id, feature, answer):
        """ Create a Fixture
        :param db: the path to the db
        :param app_id: the application id as it appears in the db
        :param feature: the feature as it appears in the db
        :param answer: True to allow access, False to deny access
        """
        self.db = db
        self.app_id = app_id
        self.feature = feature
        self.timestamp = int(str(time.time()).replace('.', ''))
        self.answer = int(answer)

    def setUp(self):
        super().setUp()

        # Get the initial request access state
        initial_state = self.get_access_request()

        # Fill the db with the desired answer
        self.fill_access_request(self.app_id, self.feature, self.timestamp,
                                 self.answer)

        # Restore the initial access state
        self.clean_request(initial_state)

    def clean_request(self, state):
        """ Restore this request in case there was an initial state, otherwise
        delete the access request when there wasn't an initial state
        """
        if state:
            self.addCleanup(self.fill_access_request, *state)
        else:
            self.addCleanup(self.delete_access_request)

    def fill_access_request(self, app_id, feature, timestamp, answer):
        """ Complete the db with the desired state to allow/deny the access
        to the app_id from the camera app
        """
        cmd = "INSERT OR REPLACE INTO requests (Id, {schema}) VALUES " \
              "((SELECT Id FROM requests WHERE ApplicationId = '{app_id}'), " \
              "'{app_id}', {feature}, {timestamp}, {answer});".\
            format(schema=self.REQUESTS_SCHEMA, app_id=app_id,
                   feature=feature, timestamp=timestamp, answer=answer)
        sqlite.execute(self.db, cmd)

    def delete_access_request(self):
        """ Delete the current state  """
        cmd = "DELETE FROM requests WHERE ApplicationId = '{app_id}' AND " \
              "Feature = {feature}".format(app_id=self.app_id,
                                           feature=self.feature)
        sqlite.execute(self.db, cmd)

    def get_access_request(self):
        """ Retrieve the first access request in the db for the current
        application id and feature
        :return: a list with the values following the table structure
        """
        cmd = "SELECT {schema} FROM requests WHERE ApplicationId = " \
              "'{app_id}' AND Feature = {feature}".\
            format(schema=self.REQUESTS_SCHEMA, app_id=self.app_id,
                   feature=self.feature)
        return sqlite.query_one(self.db, cmd)
