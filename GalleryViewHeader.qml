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
import QtQuick.Layouts 1.1

Item {
    id: header
    anchors {
        left: parent.left
        right: parent.right
    }
    y: shown ? 0 : -height
    Behavior on y { UbuntuNumberAnimation {} }
    opacity: shown ? 1.0 : 0.0
    Behavior on opacity { UbuntuNumberAnimation {} }

    height: units.gu(7)

    property bool shown: true
    property list<Action> actions
    property list<Action> editModeActions
    property bool gridMode: false
    property bool editMode: false
    property bool validationVisible
    property bool userSelectionMode: false
    signal exit
    signal exitEditor
    signal toggleViews
    signal toggleSelectAll
    signal validationClicked

    function show() {
        shown = true;
    }

    function toggle() {
        if (shown) {
            actionsDrawer.close();
        }
        shown = !shown;
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.6
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        IconButton {
            objectName: "backButton"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: units.gu(8)
            iconName: "back"
            iconColor: "white"
            onClicked: editMode ? header.exitEditor() : header.exit()
        }

        Label {
            text: main.contentExportMode || userSelectionMode ? i18n.tr("Select") :
                  (editMode ? i18n.tr("Edit Photo") : i18n.tr("Photo Roll"))
            fontSize: "x-large"
            color: "white"
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        IconButton {
            objectName: "viewToggleButton"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            iconName: header.gridMode ? "stock_image" : "view-grid-symbolic"
            onClicked: header.toggleViews()
            visible: !main.contentExportMode && !userSelectionMode && !editMode
        }

        IconButton {
            objectName: "selectAllButton"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            iconName: "select"
            onClicked: header.toggleSelectAll()
            visible: header.gridMode && userSelectionMode
        }

        IconButton {
            objectName: "singleActionButton"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            action: actionsDrawer.actions[0]
            visible: actionsDrawer.actions.length == 1 && !editMode
            onTriggered: if (action) action.triggered()
        }

        IconButton {
            objectName: "additionalActionsButton"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            iconName: "contextual-menu"
            visible: actionsDrawer.actions.length > 1 && !editMode
            onClicked: actionsDrawer.opened = !actionsDrawer.opened
        }

        IconButton {
            objectName: "validationButton"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            iconName: "ok"
            onClicked: header.validationClicked()
            visible: header.validationVisible
        }

        Repeater {
            model: header.editMode ? header.editModeActions : null
            IconButton {
                Layout.fillHeight: true
                visible: header.editMode
                action: modelData
            }
        }
    }

    Item {
        id: actionsDrawer
        objectName: "actionsDrawer"

        anchors {
            top: parent.bottom
            right: parent.right
        }
        width: units.gu(20)
        height: actionsColumn.height
        clip: actionsColumn.y != 0
        visible: false

        actions: header.actions

        function close() {
            opened = false;
        }

        property bool opened: false
        property bool fullyOpened: actionsColumn.y == 0
        property bool fullyClosed: actionsColumn.y == -actionsColumn.height
        property list<Action> actions

        onOpenedChanged: {
            if (opened)
                visible = true;
        }

        InverseMouseArea {
            anchors.fill: parent
            onPressed: actionsDrawer.close();
            enabled: actionsDrawer.opened
        }

        Column {
            id: actionsColumn
            anchors {
                left: parent.left
                right: parent.right
            }
            y: actionsDrawer.opened ? 0 : -height
            Behavior on y { UbuntuNumberAnimation {} }

            onYChanged: {
                if (y == -height)
                    actionsDrawer.visible = false;
            }

            Repeater {
                model: actionsDrawer.actions.length > 0 ? actionsDrawer.actions : 0
                delegate: AbstractButton {
                    id: actionButton
                    objectName: "actionButton" + label.text
                    anchors {
                        left: actionsColumn.left
                        right: actionsColumn.right
                    }
                    height: units.gu(6)
                    enabled: action.enabled

                    action: modelData
                    onClicked: actionsDrawer.close()

                    Rectangle {
                        anchors.fill: parent
                        color: actionButton.pressed ? Qt.rgba(1.0, 1.0, 1.0, 0.3) : Qt.rgba(0.0, 0.0, 0.0, 0.6)
                    }

                    Label {
                        id: label
                        anchors {
                            left: icon.right
                            leftMargin: units.gu(2)
                            right: parent.right
                            rightMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                        text: model.text
                        elide: Text.ElideRight
                        color: action.enabled ? "white" : Qt.darker("white", 2.0)
                    }

                    Icon {
                        id: icon
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                        width: height
                        height: label.paintedHeight
                        color: label.color
                        name: model.iconName
                        asynchronous: true
                    }
                }
            }
        }
    }
}
