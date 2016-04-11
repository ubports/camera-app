# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2014, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from camera_app.emulators.panel import Panel
from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals


class MainWindow(object):
    """An emulator class that makes it easy to interact with the camera-app."""

    def __init__(self, app):
        self.app = app

    def get_qml_view(self):
        """Get the main QML view"""
        return self.get_root()

    def get_root(self):
        """Returns the root QML Item"""
        return self.app.wait_select_single(objectName="main")

    def get_view_switcher(self):
        """Returns the switcher Flickable"""
        return self.app.wait_select_single(objectName="viewSwitcher")

    def get_viewfinder(self):
        """Returns the viewfinder view"""
        return self.app.wait_select_single("ViewFinderView")

    def get_gallery(self):
        """Returns the gallery view"""
        return self.app.wait_select_single("GalleryView")

    def get_media(self, index=0):
        """Returns media at index in the currently loaded view in gallery"""
        gallery = self.get_gallery()
        view = gallery.select_single("SlideshowView")
        if not view.visible:
            view = gallery.select_single("PhotogridView")

        return view.wait_select_single(objectName="mediaItem" + str(index))

    def get_broken_media_icon(self, index=0):
        """Returns the broken media icon"""
        media = self.get_media(index)
        return media.wait_select_single(objectName="thumbnailLoadingErrorIcon")

    def get_no_media_hint(self):
        """Returns the Item representing the hint that no media is available"""
        return self.app.wait_select_single(objectName="noMediaHint")

    def get_focus_mouse_area(self):
        """Returns the focus mouse area"""
        return self.app.wait_select_single("QQuickMouseArea",
                                           objectName="manualFocusMouseArea")

    def get_focus_ring(self):
        """Returns the focus ring of the camera"""
        return self.app.wait_select_single("FocusRing")

    def get_exposure_button(self):
        """Returns the button that takes pictures"""
        return self.app.wait_select_single("ShootButton")

    def get_photo_roll_hint(self):
        """Returns the photo roll hint"""
        return self.app.wait_select_single("PhotoRollHint",
                                           objectName="photoRollHint")

    def get_record_control(self):
        """Returns the button that toggles between photo and video recording"""
        return self.app.wait_select_single("CircleButton",
                                           objectName="recordModeButton")

    def get_option_button(self, settingsProperty):
        """Returns the option button that corresponds to the setting stored
           in settingsProperty
        """
        optionButtons = self.app.select_many("OptionButton")
        optionButton = next(button for button in optionButtons
                            if button.settingsProperty == settingsProperty)
        if optionButton.visible:
            return optionButton
        else:
            return None

    def get_flash_button(self):
        """Returns the flash control button of the camera"""
        return self.get_option_button("flashMode")

    def get_hdr_button(self):
        """Returns the hdr control button of the camera"""
        return self.get_option_button("hdrEnabled")

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

    def get_timer_delay_button(self):
        """Returns the timer delay option button of the camera"""
        return self.get_option_button("selfTimerDelay")

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

    def open_actions_drawer(self, gallery):
        """Opens action drawer of gallery"""
        actionsDrawerButton = gallery.wait_select_single(
            "IconButton",
            objectName="additionalActionsButton")
        self.app.pointing_device.move_to_object(actionsDrawerButton)
        self.app.pointing_device.click()
        actionsDrawer = gallery.wait_select_single("QQuickItem",
                                                   objectName="actionsDrawer")
        actionsDrawer.fullyOpened.wait_for(True)

    def close_actions_drawer(self, gallery):
        """Closes action drawer of gallery"""
        actionsDrawerButton = gallery.wait_select_single(
            "IconButton",
            objectName="additionalActionsButton")
        self.app.pointing_device.move_to_object(actionsDrawerButton)
        self.app.pointing_device.click()
        actionsDrawer = gallery.wait_select_single("QQuickItem",
                                                   objectName="actionsDrawer")
        actionsDrawer.fullyClosed.wait_for(True)

    def swipe_to_gallery(self, testCase):
        view_switcher = self.get_view_switcher()
        viewfinder = self.get_viewfinder()
        view_switcher.interactive.wait_for(True)
        view_switcher.enabled.wait_for(True)
        view_switcher.settling.wait_for(False)
        view_switcher.switching.wait_for(False)
        viewfinder.inView.wait_for(True)

        x, y = view_switcher.x, view_switcher.y
        w, h = view_switcher.width, view_switcher.height
        center_x = x + (w // 2)
        center_y = y + (h // 2)

        # FIXME: a rate higher than 1 does not always make view_switcher move
        if view_switcher.state == "PORTRAIT":
            self.app.pointing_device.drag(center_x, center_y,
                                          x, center_y,
                                          rate=1, time_between_events=0.0001)
        elif view_switcher.state == "LANDSCAPE":
            self.app.pointing_device.drag(center_x, y + (3 * h // 4),
                                          center_x, center_y,
                                          rate=1, time_between_events=0.0001)
        elif view_switcher.state == "INVERTED_LANDSCAPE":
            self.app.pointing_device.drag(center_x, y + (h // 4),
                                          center_x, center_y,
                                          rate=1, time_between_events=0.0001)
        else:
            self.app.pointing_device.drag(center_x, center_y,
                                          x + w - 1, center_y,
                                          rate=1, time_between_events=0.0001)

        testCase.assertThat(viewfinder.inView, Eventually(Equals(False)))
        view_switcher.settling.wait_for(False)
        view_switcher.switching.wait_for(False)

    def swipe_to_viewfinder(self, testCase):
        view_switcher = self.get_view_switcher()
        viewfinder = self.get_viewfinder()
        view_switcher.interactive.wait_for(True)
        view_switcher.enabled.wait_for(True)
        view_switcher.settling.wait_for(False)
        view_switcher.switching.wait_for(False)
        viewfinder.inView.wait_for(False)

        x, y = view_switcher.x, view_switcher.y
        w, h = view_switcher.width, view_switcher.height
        center_x = x + (w // 2)
        center_y = y + (h // 2)

        # FIXME: a rate higher than 1 does not always make view_switcher move
        if view_switcher.state == "PORTRAIT":
            self.app.pointing_device.drag(center_x, center_y,
                                          x + w - 1, center_y,
                                          rate=1, time_between_events=0.0001)
        elif view_switcher.state == "LANDSCAPE":
            self.app.pointing_device.drag(center_x, y + (h // 4),
                                          center_x, center_y,
                                          rate=1, time_between_events=0.0001)
        elif view_switcher.state == "INVERTED_LANDSCAPE":
            self.app.pointing_device.drag(center_x, y + (3 * h // 4),
                                          center_x, center_y,
                                          rate=1, time_between_events=0.0001)
        else:
            self.app.pointing_device.drag(center_x, center_y,
                                          x, center_y,
                                          rate=1, time_between_events=0.0001)

        testCase.assertThat(viewfinder.inView, Eventually(Equals(True)))
        view_switcher.settling.wait_for(False)
        view_switcher.switching.wait_for(False)

    def switch_cameras(self):
        # Swap cameras and wait for camera to settle
        shoot_button = self.get_exposure_button()
        swap_camera_button = self.get_swap_camera_button()
        self.app.pointing_device.move_to_object(swap_camera_button)
        self.app.pointing_device.click()
        shoot_button.enabled.wait_for(True)

    def switch_recording_mode(self):
        record_control = self.get_record_control()

        # Wait for the camera overlay to be loaded
        record_control.enabled.wait_for(True)
        record_control.width.wait_for(NotEquals(0))
        record_control.height.wait_for(NotEquals(0))

        self.app.pointing_device.move_to_object(record_control)
        self.app.pointing_device.click()
