# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

import autopilot
from autopilot import (
    input,
    platform
)
from autopilot.introspection import dbus


def get_pointing_device():
    """Return the pointing device depending on the platform.

    If the platform is `Desktop`, the pointing device will be a `Mouse`.
    If not, the pointing device will be `Touch`.

    """
    if platform.model() == 'Desktop':
        input_device_class = input.Mouse
    else:
        input_device_class = input.Touch
    return input.Pointer(device=input_device_class.create())


class CameraCustomProxyObjectBase(dbus.CustomEmulatorBase):
    """A base class for all the Camera App emulators."""

    def __init__(self, *args):
        super(CameraCustomProxyObjectBase, self).__init__(*args)
        self.pointing_device = get_pointing_device()
