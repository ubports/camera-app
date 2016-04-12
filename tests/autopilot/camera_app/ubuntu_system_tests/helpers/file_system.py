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

import filecmp
import getpass
import glob
import hashlib
import logging
import random
import os
import shutil
import string
import subprocess

logger = logging.getLogger(__name__)

FILE_PREFIX = 'file://'
IMAGE_PREFIX = 'image://'
MUSIC_PREFIX = 'music://'
ALBUM_PREFIX = 'album://'

DIR_MUSIC = 'Music'
DIR_PICTURES = 'Pictures'
DIR_VIDEOS = 'Videos'
DIR_DOCUMENTS = 'Documents'
DIR_DOWNLOADS = 'Downloads'
DIR_CONFIG = '.config'
DIR_CACHE = '.cache'
DIR_LOCAL = '.local'
DIR_CAMERA_PICTURES = 'com.ubuntu.camera'
DIR_MUSIC_CONFIG = 'com.ubuntu.music'
DIR_GALLERY = 'com.ubuntu.gallery'
DIR_WEBBROWSER = 'webbrowser-app'
DIR_SHARE = 'share'
DIR_IMPORTED = 'imported'

# Home dirs
DIR_HOME = os.path.expanduser('~')
DIR_HOME_MUSIC = os.path.join(DIR_HOME, DIR_MUSIC)
DIR_HOME_PICTURES = os.path.join(DIR_HOME, DIR_PICTURES)
DIR_HOME_VIDEOS = os.path.join(DIR_HOME, DIR_VIDEOS)
DIR_HOME_DOCUMENTS = os.path.join(DIR_HOME, DIR_DOCUMENTS)
DIR_HOME_DOWNLOADS = os.path.join(DIR_HOME, DIR_DOWNLOADS)
DIR_HOME_CONFIG = os.path.join(DIR_HOME, DIR_CONFIG)
DIR_HOME_LOCAL = os.path.join(DIR_HOME, DIR_LOCAL)
DIR_HOME_CACHE = os.path.join(DIR_HOME, DIR_CACHE)

# .share dir
DIR_HOME_LOCAL_SHARE = os.path.join(DIR_HOME_LOCAL, DIR_SHARE)

# Camera dirs
DIR_HOME_CAMERA_PICTURES = os.path.join(DIR_HOME_PICTURES,
                                        DIR_CAMERA_PICTURES)
DIR_HOME_CAMERA_VIDEOS = os.path.join(DIR_HOME_VIDEOS,
                                      DIR_CAMERA_PICTURES)
DIR_HOME_CAMERA_CONFIG = os.path.join(DIR_HOME_CONFIG,
                                      DIR_CAMERA_PICTURES)
DIR_HOME_CAMERA_THUMBNAILS = os.path.join(DIR_HOME, DIR_CACHE,
                                          DIR_CAMERA_PICTURES)

# Gallery dirs
DIR_HOME_CACHE_GALLERY = os.path.join(DIR_HOME_CACHE, DIR_GALLERY)

# Music dirs
DIR_HOME_MUSIC_CONFIG = os.path.join(DIR_HOME_CONFIG, DIR_MUSIC_CONFIG)

# Pictures download
DIR_HOME_PICTURES_IMPORTED = os.path.join(DIR_HOME_PICTURES, DIR_IMPORTED)

# Webbrowser dirs
DIR_HOME_LOCAL_SHARE_WEBBROWSER = os.path.join(DIR_HOME_LOCAL_SHARE,
                                               DIR_WEBBROWSER)

# Test data dirs
DIR_TESTS = os.path.realpath(__file__ + '/../../tests')
DIR_TEST_DATA = os.path.join(DIR_TESTS, 'data')
DIR_TEST_DATA_AUDIO = os.path.join(DIR_TEST_DATA, 'audio')
DIR_TEST_DATA_HTML = os.path.join(DIR_TEST_DATA, 'html')
DIR_TEST_DATA_IMAGES = os.path.join(DIR_TEST_DATA, 'images')
DIR_TEST_DATA_SCOPES = os.path.join(DIR_TEST_DATA, 'scopes')
DIR_TEST_DATA_TEXT = os.path.join(DIR_TEST_DATA, 'text')
DIR_TEST_DATA_VIDEO = os.path.join(DIR_TEST_DATA, 'video')
DIR_TEST_DATA_DEVICES = os.path.join(DIR_TEST_DATA, 'devices')
DIR_TEST_DATA_DATABASES = os.path.join(DIR_TEST_DATA, 'databases')

# Media dirs
DIR_MEDIA = '/media'
DIR_MEDIA_ROOT = os.path.join(DIR_MEDIA, getpass.getuser())

# Misc dirs
DIR_TEMP = '/tmp'

# Preinstalled click apps
DIR_PREINSTALLED_CLICK_APPS = '/usr/share/click/preinstalled/'


def delete_file(file_name):
    """Delete the file passed as parameter. In case the file does not
    exist, the deletion is skipped"""
    if os.path.isfile(file_name):
        os.unlink(file_name)


def create_directory_if_not_exists(directory):
    """Create the directory passed as parameter, if it does not
    already exist"""
    if not os.path.exists(directory):
        os.makedirs(directory)


def clean_files(dir_path):
    """Delete all the files in the directory.
    Subdirs are not deleted"""
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            os.unlink(os.path.join(root, file))


def files_in_dir(dir_path):
    """Retrieve all the files in the directory"""
    f = []
    for (root, dirs, files) in os.walk(dir_path):
        f.extend(files)
        break
    return f


def recursive_files_in_dir(root):
    """Recursively search root dir and return list of absolute file paths."""
    file_list = []
    for dir, subdirs, files in os.walk(root):
        root_dir = os.path.join(root, dir)
        for file in files:
            file_list.append(os.path.abspath(os.path.join(root_dir, file)))
    return file_list


def remove_dir(dir_path):
    """Remove the directory"""
    if os.path.isdir(dir_path):
        shutil.rmtree(dir_path, True)


def clean_dir(dir_path):
    """Delete all the content of the directory"""
    if os.path.isdir(dir_path):
        for obj in os.listdir(dir_path):
            obj_path = os.path.join(dir_path, obj)
            if os.path.isfile(obj_path):
                os.remove(obj_path)
            else:
                remove_dir(obj_path)


def move_folder_contents(src_root, dst_root):
    """
    Move each top-level item individually from src folder to dest folder
    leaving the top-level folder in place. Result will be an empty src folder
    with all items moved to dest folder.

    :param src_folder: The folder containing content to move
    :parap dst_folder: The destination folder for all content

    """
    if os.path.isdir(src_root):
        for item in os.listdir(src_root):
            src = os.path.join(src_root, item)
            dst = os.path.join(dst_root, item)
            dst_folder = os.path.dirname(dst)
            if not os.path.exists(dst_folder):
                os.makedirs(dst_folder)
            shutil.move(src, dst)


def calculate_file_sha1(file_path):
    """Calculates the sha1 digest for the file
    :param file_path: The path to the file to calculate the sha1 digest
    :return The sha1 digest for the file passed as parameter
    :raise EnvironmentError: If the file couldn't be opened
    """
    sha = hashlib.sha1()
    with open(file_path, 'rb') as f:
        while True:
            block = f.read(1024)
            if not block:
                break
            sha.update(block)
        return sha.hexdigest()


def get_random_string(length=10):
    """Get a string with random content"""
    return ''.join(random.choice(string.ascii_uppercase) for i in
                   range(length))


def compare_files(file_1, file_2):
    """Return True if files match exactly, False otherwise."""
    return filecmp.cmp(file_1, file_2)


def _get_media_folders_from_root(root):
    """Return a list of Music, Pictures or Video folders present at root."""
    directories = []
    for directory in [DIR_MUSIC, DIR_PICTURES, DIR_VIDEOS]:
        sub_directory = os.path.join(root, directory)
        if os.path.isdir(sub_directory):
            directories.append(sub_directory)
    return directories


def is_media_folder_dir(media_dir):
    """
    Indicate if the media dir exists or not and checks its permissions
    :param media_dir: The media dir required such as: Music, Videos, etc
    :return: True if the media dir exists and False otherwise
    """
    try:
        dir = get_media_folder_dir(media_dir)
        return os.access(dir, os.R_OK) and os.access(dir, os.W_OK)
    except RuntimeError:
        return False


def get_media_folder_dir(media_dir):
    """Get the first media folders that matches with the media dir passed as
    parameter.
    :param media_dir: The media dir required such as: Music, Videos, etc
    :return: The path to the media path
    :raises: RuntimeError: when the media dir does not exist
    """
    if not os.path.isdir(DIR_MEDIA_ROOT):
        raise RuntimeError('Media directory does not exist: ' + DIR_MEDIA_ROOT)

    media_dirs = glob.glob(DIR_MEDIA_ROOT + '/*/{name}'.format(name=media_dir))
    if not media_dirs:
        raise RuntimeError('Media directory does not exist.')

    return media_dirs[0]


def _get_media_folders_for_home_folder():
    """Get media folders from home folder."""
    return _get_media_folders_from_root(DIR_HOME)


def _get_media_folders_for_media_devices():
    """Get media directories for any storage devices present."""
    directories = []
    if os.path.exists(DIR_MEDIA_ROOT):
        for directory in os.listdir(DIR_MEDIA_ROOT):
            media_directory = os.path.abspath(
                os.path.join(DIR_MEDIA_ROOT, directory))
            directories += _get_media_folders_from_root(media_directory)
    return directories


def get_media_folder_list():
    """Return a list of media folder paths for current user."""
    home_folders = _get_media_folders_for_home_folder()
    media_folders = _get_media_folders_for_media_devices()
    return home_folders + media_folders


def create_random_file(path, ext='', length=10):
    """ Create a file with random name and content in the specified dir
    :param path: The path to create the file
    :param ext: The extension for the file
    :param length: the length of the file content
    :return: The path of the created file
    """
    file_path = os.path.join(path, get_random_string() + ext)
    if os.path.isfile(file_path):
        raise RuntimeError('The file to be created already exists')

    with open(file_path, 'w') as f:
        f.write(get_random_string(length))

    return file_path


def get_file_path(path):
    return FILE_PREFIX + path


def remove_file_path(file_path):
    return file_path.split(FILE_PREFIX)[1]


def create_empty_file(file_path):
    """ Create an empty file in case the file does not exist, otherwise skip
    :param file_path: the path to the file
    """
    if not os.path.exists(file_path):
        subprocess.call('touch {}'.format(file_path), shell=True)


def _get_free_space(cmd, line):
    """ Retrieve the free scpace in the disk measured in KB using df command
    :param cmd: df command line
    :param line: line in which the desired results are displayed
    """
    # df output is (device, size, used, available, percent, mountpoint)
    return int(
        subprocess.check_output(cmd, universal_newlines=True,
                                shell=True).split('\n')[line].split()[3])


def get_disk_usage(path):
    """ Retrieve the usage in KB used in a specific path, in case the path is
    a dir, the result includes the subdirs
    """
    return int(subprocess.check_output('du -bs {}'.format(path),
                                       universal_newlines=True,
                                       shell=True).split()[0])


def get_user_data_free_space():
    """ Retrieve the free scpace in /userdata disk measured in KB
    :return:
    """
    return _get_free_space('df /userdata', 1)


def get_total_free_space():
    """ Retrieve the free scpace in the disk measured in KB """
    return _get_free_space('df --total', -2)


def get_content_list_from_file_list(file_path_list, sort_content=False):
    """Return a list of file contents from a list of file paths.
    :param file_path_list: List of file paths to read.
    :param sort_content: Whether to sort return list by content.
    :return: List of file contents.
    """
    content_list = []
    for file_path in file_path_list:
        with open(file_path, 'rb') as f:
            content_list.append(f.read())
    if sort_content:
        content_list = sorted(content_list)
    return content_list
