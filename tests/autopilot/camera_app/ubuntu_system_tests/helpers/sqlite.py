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

import sqlite3


def open_db(db):
    """ Open the sqlite db
    :param db: The path to the DB
    :return: the connection to the db
    """
    try:
        conn = sqlite3.connect(db)
    except sqlite3.Error as e:
        e.args += 'DB {} cannot be opened'.format(db)
        raise

    return conn


def query_one(db, command):
    """ Query the db an retrieve one result
    :param db: The path to the db
    :param command: The query command
    :return: a list with the query result
    """
    conn = open_db(db)

    with conn:
        cur = conn.cursor()
        cur.execute(command)
        return cur.fetchone()


def execute(db, command, **kwargs):
    """ Execute a command in the specified db
    :param db: The path to the db
    :param command: The command to execute
    :param **kwargs: Keyword arguments for parameter substitution
    """
    conn = open_db(db)

    with conn:
        c = conn.cursor()
        c.execute(command, kwargs)
        conn.commit()
