/*
 * Copyright 2016 Canonical Ltd.
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
 *
 */

import QtQuick 2.4
import QtTest 1.0
import "../../"
import "../../.." //Needed for out of source build

TestCase {
    name: "PhotogridView"

    function test_mixedMediaSelection_data() {
        return [
            { // one item only
                isMixedMedia: false,
                listItems: [
                    { fileType: "image", selected: true, fileURL: "" }
                ]
            },
            { // mixed media but only non-mixed selected
                isMixedMedia: false,
                listItems: [
                      { fileType: "video", selected: false, fileURL: "" },
                      { fileType: "image", selected: true, fileURL: "" },
                      { fileType: "image", selected: true, fileURL: "" }
                ]
            },
            { // mixed media
                isMixedMedia: true,
                listItems: [
                      { fileType: "video", selected: true, fileURL: "" },
                      { fileType: "image", selected: true, fileURL: "" },
                      { fileType: "image", selected: true, fileURL: "" }
                ]
            },
        ];
    }

    function test_mixedMediaSelection(data) {
        list.clear()
        list.data = data.listItems;
        for (var i = 0; i < data.listItems.length; i++) {
            list.append(data.listItems[i]);
        }
        list.updateSelectedFiles();
        grid.model = list
        compare(grid.selectionContainsMixedMedia(), data.isMixedMedia, "Mixed media not detected correctly")
    }

    ListModel {
        id: list
        property var data
        property var selectedFiles: []
        function updateSelectedFiles() {
            // need to re-assign entire list due to the way list properties work in QML
            var selected = [];
            for (var i = 0; i < list.count; i++) {
                if (list.data[i].selected) selected.push(i);
            }
            list.selectedFiles = selected;
        }
        function get(i, key) {
            return list.data[i][key];
        }
    }

    PhotogridView {
        id: grid
        width: 600
        height: 800
        inView: true
        inSelectionMode: true
    }
}
