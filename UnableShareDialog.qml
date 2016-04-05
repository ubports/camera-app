/*
 * Copyright (C) 2016 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
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
import Ubuntu.Components.Popups 1.3

Dialog {
    id: dialog
    objectName: "unableShareDialog"

    title: i18n.tr("Unable to share")
    text: i18n.tr("Unable to share photos and videos at the same time")

    Button {
        objectName: "unableShareDialogOk"
        text: i18n.tr("Ok")
        color: UbuntuColors.orange
        onClicked: PopupUtils.close(dialog);
    }
}
