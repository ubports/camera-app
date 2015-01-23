/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#ifndef STORAGEMONITOR_P_H
#define STORAGEMONITOR_P_H

const int POLL_INTERVAL = 1000;
const qint64 MEGABYTE = 1024 * 1024;
const qint64 LOW_SPACE_THRESHOLD = 100 * MEGABYTE;
const qint64 CRITICALLY_LOW_SPACE_THRESHOLD = 13 * MEGABYTE;

#endif // STORAGEMONITOR_P_H
