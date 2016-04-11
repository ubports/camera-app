# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2014, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

import logging

import ubuntuuitoolkit
from autopilot import logging as autopilot_logging


logger = logging.getLogger(__name__)


class Panel(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):
    """Panel Autopilot emulator."""

    @autopilot_logging.log_action(logger.info)
    def open(self):
        """Open the panel if it's not already opened.

        :return: The panel.

        """
        self.ready.wait_for(True)
        self.animating.wait_for(False)
        if not self.opened:
            self._drag_to_open()
            self.opened.wait_for(True)
            self.animating.wait_for(False)

        return self

    def _drag_to_open(self):
        x, y, _, _ = self.globalRect
        center_x = x + self.width * 0.50
        center_y = y + self.height * 0.50

        view_switcher = self.get_root_instance().wait_select_single(
            objectName="viewSwitcher")

        # FIXME: a rate higher than 1 does not always make panel move
        if view_switcher.state == "PORTRAIT":
            self.pointing_device.drag(center_x, y + self.height - 1,
                                      center_x, y, rate=1,
                                      time_between_events=0.0001)
        elif view_switcher.state == "LANDSCAPE":
            self.pointing_device.drag(0, center_y,
                                      self.height - 1, center_y, rate=1,
                                      time_between_events=0.0001)
        elif view_switcher.state == "INVERTED_LANDSCAPE":
            self.pointing_device.drag(x + self.height - 1, center_y,
                                      x, center_y, rate=1,
                                      time_between_events=0.0001)
        else:
            self.pointing_device.drag(center_x, y + self.height - 1,
                                      center_x, y, rate=1,
                                      time_between_events=0.0001)

    @autopilot_logging.log_action(logger.info)
    def close(self):
        """Close the panel if it's opened."""
        self.ready.wait_for(True)
        self.animating.wait_for(False)
        if self.opened:
            self._drag_to_close()
            self.opened.wait_for(False)
            self.animating.wait_for(False)

    def _drag_to_close(self):
        x, y, _, _ = self.globalRect
        center_x = x + self.width * 0.50
        center_y = y + self.height * 0.50

        view_switcher = self.get_root_instance().wait_select_single(
            objectName="viewSwitcher")

        # FIXME: a rate higher than 1 does not always make panel move
        if view_switcher.state == "PORTRAIT":
            self.pointing_device.drag(x, y,
                                      x, y + self.height - 1, rate=1,
                                      time_between_events=0.0001)
        elif view_switcher.state == "LANDSCAPE":
            self.pointing_device.drag(self.height - 1, center_y,
                                      0, center_y, rate=1,
                                      time_between_events=0.0001)
        elif view_switcher.state == "INVERTED_LANDSCAPE":
            self.pointing_device.drag(x, center_y,
                                      x + self.height - 1, center_y, rate=1,
                                      time_between_events=0.0001)
        else:
            self.pointing_device.drag(x, y,
                                      x, y + self.height - 1, rate=1,
                                      time_between_events=0.0001)
