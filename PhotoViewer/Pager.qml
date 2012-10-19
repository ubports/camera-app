/*
 * Copyright (C) 2011 Canonical Ltd
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
 * Charles Lindsay <chaz@yorba.org>
 */

import QtQuick 2.0

// A Pager is a ListView of screen-sized items whose currentIndex tracks which
// page the user is currently on.
ListView {
  id: pager
  objectName: "pager"
  
  property int pageCacheSize: 4
  
  function pageForward() {
    incrementCurrentIndex();
  }

  function pageBack() {
    decrementCurrentIndex();
  }

  function pageTo(pageIndex) {
    currentIndex = pageIndex;
    positionViewAtIndex(currentIndex, ListView.Beginning);
  }

  orientation: ListView.Horizontal
  snapMode: ListView.SnapOneItem
  highlightRangeMode: ListView.StrictlyEnforceRange
  highlightFollowsCurrentItem: true
  cacheBuffer: width * pageCacheSize
  flickDeceleration: 50
  highlightMoveDuration: 200
  boundsBehavior: Flickable.DragOverBounds
}
