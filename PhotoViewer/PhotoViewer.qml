/*
 * Copyright (C) 2011-2012 Canonical Ltd
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
 *
 * Authors:
 * Jim Nelson <jim@yorba.org>
 * Lucas Beeler <lucas@yorba.org>
 * Eric Gregory <eric@yorba.org>
 */

import QtQuick 2.0

// Displays a flickable photo stream.
//
// When implementing this, override onCurrentIndexChanged to load the 
// appropriate photo for the index.
Pager {
  id: photoViewer
  objectName: "photoViewer"
  
  signal clicked()
  
  // NOTE: These properties should be treated as read-only, as setting them
  // individually can lead to bogus results.  Use setCurrentIndex() to 
  // initialize the view.
  property alias index: photoViewer.currentIndex
  
  function setCurrentIndex(index) {
    photoViewer.pageTo(index);
  }

  // Keyboard focus while visible
  onVisibleChanged: {
    if (visible)
      forceActiveFocus();
  }
  
  Keys.onPressed: {
    if (event.key === Qt.Key_Left) {
      pageBack();
      event.accepted = true;
    } else if (event.key === Qt.Key_Right) {
      pageForward();
      event.accepted = true;
    }
  }
  
  // Background color fill.
  Rectangle {
    anchors.fill: parent
    
    z: -1000 //background
    color: "black"
  }
  
  MouseArea {
    id: photoViewerMouseArea
    
    anchors.fill: parent
    
    property bool isDragInProgress: false;
    property int dragStartX: -1;
    property int dragStartY: -1;
    
    onClicked: {
      var deltaX = mouse.x - dragStartX;
      var deltaY = mouse.y - dragStartY;
      var distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
      if (distance < 20) photoViewer.clicked();
    }
    
    onPressed: {
      dragStartX = mouse.x;
      dragStartY = mouse.y;

      if (photoViewer.currentItem.state == "unzoomed")
        return;
      
      isDragInProgress = true;
            
      photoViewer.currentItem.setZoomFocus(
        photoViewer.currentItem.getImageTranslation());
    }
    
    onPositionChanged: {
      if (isDragInProgress) {
        var deltaX = mouse.x - dragStartX;
        var deltaY = mouse.y - dragStartY;
        
        photoViewer.currentItem.pan(photoViewer.currentItem.zoomFocusX + deltaX,
          photoViewer.currentItem.zoomFocusY + deltaY);
      }
    }
    
    onReleased: {
      isDragInProgress = false;
    }
    
    onDoubleClicked: {
      photoViewer.currentItem.zoom(mouse.x, mouse.y);
    }
  }
}
