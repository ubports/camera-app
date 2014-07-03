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
import Ubuntu.Components 1.0
import Ubuntu.Thumbnailer 0.1

Item {
    id: photogridView

    property int itemsPerRow: 3
    property var model
    signal photoClicked(int index)
    property real headerHeight
    property list<Action> actions

    function showPhotoAtIndex(index) {
        gridView.positionViewAtIndex(index, GridView.Center);
    }

    function exit() {
    }

    GridView {
        id: gridView
        anchors.fill: parent
        // FIXME: prevent the header from overlapping the beginning of the grid
        // when Qt 5.3 is landed, use property 'displayMarginBeginning' instead
        // cf. http://qt-project.org/doc/qt-5/qml-qtquick-gridview.html#displayMarginBeginning-prop
        header: Item {
            width: gridView.width
            height: headerHeight
        }
        
        Component.onCompleted: {
            // FIXME: workaround for qtubuntu not returning values depending on the grid unit definition
            // for Flickable.maximumFlickVelocity and Flickable.flickDeceleration
            var scaleFactor = units.gridUnit / 8;
            maximumFlickVelocity = maximumFlickVelocity * scaleFactor;
            flickDeceleration = flickDeceleration * scaleFactor;
        }

        cellWidth: width / photogridView.itemsPerRow
        cellHeight: cellWidth

        model: photogridView.model
        delegate: Item {
            id: cellDelegate
            
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight


            function endsWith(string, suffix) {
                return string.indexOf(suffix, string.length - suffix.length) !== -1;
            }

            property bool isVideo: endsWith(fileURL.toString(), ".mp4")

            Image {
                id: thumbnail
                property real margin: units.dp(2)
                anchors {
                    top: parent.top
                    topMargin: index < photogridView.itemsPerRow ? 0 : margin/2
                    bottom: parent.bottom
                    bottomMargin: margin/2
                    left: parent.left
                    leftMargin: index % photogridView.itemsPerRow == 0 ? 0 : margin/2
                    right: parent.right
                    rightMargin: index % photogridView.itemsPerRow == photogridView.itemsPerRow - 1 ? 0 : margin/2
                }
                
                asynchronous: true
                cache: false
                source: "image://thumbnailer/" + fileURL.toString()
                sourceSize {
                    width: width
                    height: height
                }
                fillMode: Image.PreserveAspectCrop
                opacity: status == Image.Ready ? 1.0 : 0.0
                Behavior on opacity { UbuntuNumberAnimation {duration: UbuntuAnimation.FastDuration} }
            }

            Icon {
                width: units.gu(3)
                height: units.gu(3)
                anchors.centerIn: parent
                name: "media-playback-start"
                color: "white"
                opacity: 0.8
                visible: isVideo
            }

            MouseArea {
                anchors.fill: parent
                onClicked: photogridView.photoClicked(index)
            }
        }
    }
}
