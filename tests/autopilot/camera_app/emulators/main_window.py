# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from camera_app.emulators.panel import Panel
from autopilot.matchers import Eventually
from testtools.matchers import Equals


class MainWindow(object):
    """An emulator class that makes it easy to interact with the camera-app."""

    def __init__(self, app):
        self.app = app

    def get_qml_view(self):
        """Get the main QML view"""
        return self.app.wait_select_single("QQuickView")

    def get_root(self):
        """Returns the root QML Item"""
        return self.app.wait_select_single(objectName="main")

    def get_viewfinder(self):
        """Returns the viewfinder view"""
        return self.app.wait_select_single("ViewFinderView")

    def get_gallery(self):
        """Returns the gallery view"""
        return self.app.wait_select_single("GalleryView")

    def get_no_media_hint(self):
        """Returns the Item representing the hint that no media is available"""
        return self.app.wait_select_single(objectName="noMediaHint")

    def get_focus_ring(self):
        """Returns the focus ring of the camera"""
        return self.app.wait_select_single("FocusRing")

    def get_exposure_button(self):
        """Returns the button that takes pictures"""
        return self.app.wait_select_single("ShootButton")

    def get_photo_roll_hint(self):
        """Returns the layer that serves at hinting to the existence of the photo roll"""
        return self.app.wait_select_single("PhotoRollHint")

    def get_record_control(self):
        """Returns the button that toggles between photo and video recording"""
        return self.app.wait_select_single("CircleButton",
                                           objectName="recordModeButton")

    def get_option_button(self, settingsProperty):
        """Returns the option button that corresponds to the setting stored
           in settingsProperty
        """
        optionButtons = self.app.select_many("OptionButton")
        return next(button for button in optionButtons
                    if button.settingsProperty == settingsProperty)

    def get_flash_button(self):
        """Returns the flash control button of the camera"""
        return self.get_option_button("flashMode")

    def get_video_flash_button(self):
        """Returns the flash control button of the camera"""
        return self.get_option_button("videoFlashMode")

    def get_encoding_quality_button(self):
        """Returns the encoding quality button of the camera"""
        return self.get_option_button("encodingQuality")

    def get_grid_lines_button(self):
        """Returns the grid lines toggle button of the camera"""
        return self.get_option_button("gridEnabled")

    def get_video_resolution_button(self):
        """Returns the video resolution button of the camera"""
        return self.get_option_button("videoResolution")

    def get_stop_watch(self):
        """Returns the stop watch when using the record button of the camera"""
        return self.app.wait_select_single("StopWatch")

    def get_zoom_control(self):
        """Returns the whole left control"""
        return self.app.wait_select_single("ZoomControl")

    def get_zoom_slider(self):
        """Returns the zoom slider"""
        return self.get_zoom_control().wait_select_single("Slider")

    def get_viewfinder_geometry(self):
        """Returns the viewfinder geometry tracker"""
        return self.app.wait_select_single("ViewFinderGeometry")

    def get_swap_camera_button(self):
        """Returns the button that switches between front and back cameras"""
        return self.app.wait_select_single("CircleButton",
                                           objectName="swapButton")

    def get_bottom_edge(self):
        """Returns the bottom edge panel"""
        return self.app.wait_select_single(Panel)

    def get_option_value_selector(self):
        """Returns the option value selector"""
        return self.app.wait_select_single(objectName="optionValueSelector")

    def get_option_value_button(self, label):
        """Returns the button corresponding to an option with the given label
           of the option value selector
        """
        selector = self.get_option_value_selector()
        optionButtons = selector.select_many("OptionValueButton")
        return next(button for button in optionButtons
                    if button.label == label)

    def get_no_space_hint(self):
        """Returns the no space hint"""
        return self.app.wait_select_single(objectName="noSpace")

    def get_low_space_dialog(self):
        """Returns the dialog informing of low disk space"""
        try:
            return self.app.wait_select_single(objectName="lowSpaceDialog")
        except:
            return None

    def swipe_to_gallery(self, testCase):
        main_view = self.get_root()
        x, y, w, h = main_view.globalRect

        tx = x + (w // 2)
        ty = y + (h // 2)

        testCase.pointing_device.drag(tx, ty, (tx - main_view.width // 2), ty)
        viewfinder = self.get_viewfinder()
        testCase.assertThat(viewfinder.inView, Eventually(Equals(False)))

    def swipe_to_viewfinder(self, testCase):
        main_view = self.get_root()
        x, y, w, h = main_view.globalRect

        tx = x + (w // 2)
        ty = y + (h // 2)

        testCase.pointing_device.drag(tx, ty, (tx + main_view.width // 2), ty)
        viewfinder = self.get_viewfinder()
        testCase.assertThat(viewfinder.inView, Eventually(Equals(True)))
