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

import QtQuick 2.2

Loader {
    id: loader

    signal exit
    property bool inView
    property bool touchAcquired: loader.item ? loader.item.touchAcquired : false

    function showLastPhotoTaken() {
        loader.item.showLastPhotoTaken();
    }

    asynchronous: true

    Component.onCompleted: {
        loader.setSource("GalleryView.qml", { "inView": Qt.binding(function() { return loader.inView }) });
    }
    onLoaded: {
        loader.item.exit.connect(exit);
    }
}
