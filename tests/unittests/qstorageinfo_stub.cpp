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

#include <QStorageInfo>
#include "storageinfocontrol.h"

#include <QDebug>

QString location;

class QStorageInfoPrivateRef {
public:
    bool deref() { return false; }
};

class QStorageInfoPrivate {
public:
    QStorageInfoPrivateRef ref;
};

QStorageInfo::QStorageInfo()
{
}

QStorageInfo::QStorageInfo(const QString &path)
{
}

QStorageInfo::QStorageInfo(const QDir &dir)
{
}

QStorageInfo::QStorageInfo(const QStorageInfo &other)
{
}

QStorageInfo::~QStorageInfo()
{
}

void QStorageInfo::setPath(const QString &path)
{
    location = path;
}

qint64 QStorageInfo::bytesAvailable() const
{
    return StorageInfoControl::instance()->freeSpaceMap[location];
}

bool QStorageInfo::isReady() const
{
    return StorageInfoControl::instance()->readyMap[location];
}

bool QStorageInfo::isValid() const
{
    return StorageInfoControl::instance()->validMap[location];
}

void QStorageInfo::refresh()
{
}
