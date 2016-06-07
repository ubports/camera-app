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

Loader {
    id: loader

    signal exit
    property bool inView
    property bool touchAcquired: loader.item ? loader.item.touchAcquired : false

    function showLastPhotoTaken() {
        loader.item.showLastPhotoTaken();
    }

    function prependMediaToModel(filePath) {
        loader.item.prependMediaToModel(filePath);
    }

    function precacheThumbnail(filePath) {
        loader.item.precacheThumbnail(filePath);
    }

    asynchronous: true

    Component.onCompleted: {
        loader.setSource("GalleryView.qml");
    }

    onLoaded: {
        loader.item.inView = Qt.binding(function() { return loader.inView });
        loader.item.exit.connect(exit);
    }
}
