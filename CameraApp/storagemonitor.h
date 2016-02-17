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

#ifndef STORAGEMONITOR_H
#define STORAGEMONITOR_H

#include <QObject>
#include <QTimer>

#include "qstorageinfo.h"

const int POLL_INTERVAL = 1000;
const qint64 MEGABYTE = 1024 * 1024;
const qint64 LOW_SPACE_THRESHOLD = 200 * MEGABYTE;
const qint64 CRITICALLY_LOW_SPACE_THRESHOLD = 50 * MEGABYTE;

class StorageMonitor : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString location READ location WRITE setLocation NOTIFY locationChanged)
    Q_PROPERTY(bool diskSpaceLow READ diskSpaceLow NOTIFY diskSpaceLowChanged)
    Q_PROPERTY(bool diskSpaceCriticallyLow READ diskSpaceCriticallyLow NOTIFY diskSpaceCriticallyLowChanged)
    Q_PROPERTY(bool isWriteable READ isWriteable NOTIFY isWriteableChanged)

public:
    explicit StorageMonitor(QObject *parent = 0);

    QString location() const;
    void setLocation(QString location);
    bool diskSpaceLow() const;
    bool diskSpaceCriticallyLow() const;
    bool isWriteable() const;

Q_SIGNALS:
    void locationChanged();
    void diskSpaceLowChanged();
    void diskSpaceCriticallyLowChanged();
    void isWriteableChanged();

private Q_SLOTS:
    void refresh();

private:
    void checkDiskSpace();
    void checkWriteable();

private:
    bool m_low;
    bool m_criticallyLow;
    bool m_writeable;
    QTimer m_timer;
    QString m_location;
    QStorageInfo m_storage;
};

#endif // STORAGEMONITOR_H
