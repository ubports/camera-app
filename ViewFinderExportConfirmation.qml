/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: viewFinderExportConfirmation

    property string mediaPath
    property Snapshot snapshot

    function confirmExport(path) {
        viewFinder.visible = false;
        viewFinderOverlay.visible = false;
        mediaPath = path;
        snapshot.visible = true;
        visible = true;
    }

    function hide() {
        viewFinder.visible = true;
        viewFinderOverlay.visible = true;
        snapshot.source = "";
        snapshot.visible = false;
        visible = false;
    }

    visible: false

    Loader {
        anchors.fill: parent
        asynchronous: true
        sourceComponent: Component {
            Item {
                CircleButton {
                    id: retryButton
                    objectName: "retryButton"

                    anchors {
                        right: validateButton.left
                        rightMargin: units.gu(7.5)
                        bottom: parent.bottom
                        bottomMargin: units.gu(6)
                    }

                    iconName: "reload"
                    onClicked: viewFinderExportConfirmation.hide()
                }

                CircleButton {
                    id: validateButton
                    objectName: "validateButton"

                    width: units.gu(8)
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: units.gu(5)
                        horizontalCenter: parent.horizontalCenter
                    }

                    iconName: "ok"
                    onClicked: {
                        viewFinderExportConfirmation.hide();
                        main.exportContent([mediaPath]);
                    }
                }

                CircleButton {
                    id: cancelButton
                    objectName: "cancelButton"

                    anchors {
                        left: validateButton.right
                        leftMargin: units.gu(7.5)
                        bottom: parent.bottom
                        bottomMargin: units.gu(6)
                    }

                    iconName: "close"
                    onClicked: {
                        viewFinderExportConfirmation.hide();
                        main.cancelExport();
                    }
                }
            }
        }
    }
}
