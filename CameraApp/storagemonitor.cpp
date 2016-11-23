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

#include "storagemonitor.h"
#include "storagelocations.h"

StorageMonitor::StorageMonitor(QObject *parent) :
    QObject(parent), m_low(false), m_criticallyLow(false), m_writeable(true)
{
    m_timer.setInterval(POLL_INTERVAL);
    m_timer.setSingleShot(false);
    connect(&m_timer, SIGNAL(timeout()), SLOT(refresh()));
}

void StorageMonitor::refresh()
{
    m_storage.refresh();
    checkDiskSpace();
}

void StorageMonitor::checkDiskSpace() {
    bool currentLow;
    bool currentCriticallyLow;

    if (m_storage.isValid() && m_storage.isReady()) {
        qint64 freeSpace = m_storage.bytesAvailable();
        currentLow = (freeSpace <= LOW_SPACE_THRESHOLD);
        currentCriticallyLow = (freeSpace <= CRITICALLY_LOW_SPACE_THRESHOLD);
    } else {
        currentLow = false;
        currentCriticallyLow = false;
    }

    if (currentLow != m_low) {
        m_low = currentLow;
        Q_EMIT diskSpaceLowChanged();
    }

    if (currentCriticallyLow != m_criticallyLow) {
        m_criticallyLow = currentCriticallyLow;
        Q_EMIT diskSpaceCriticallyLowChanged();
    }
}

void StorageMonitor::checkWriteable()
{
    bool writeable = true;

    QString mediaRoot("/media/" + qgetenv("USER"));
    if (m_storage.rootPath().startsWith(mediaRoot)) {
        // check only for external media, assume internal media is always writeable
        if (m_storage.isReadOnly()) {
            writeable = false;
        } else {
            StorageLocations locations;
            QDir storageRoot(locations.removableStoragePicturesLocation());
            QFile testFile(storageRoot.absoluteFilePath(".write_test"));
            bool opened = testFile.open(QIODevice::WriteOnly | QIODevice::Unbuffered);
            if (!opened || testFile.write("x", 1) != 1) writeable = false;
            testFile.close();
            testFile.remove();
        }
    }

    if (m_writeable != writeable) {
        m_writeable = writeable;
        Q_EMIT isWriteableChanged();
    }
}

void StorageMonitor::setLocation(QString location)
{
    if (location != m_location) {
        m_timer.stop();
        m_location = location;

        m_storage.setPath(m_location);
        checkDiskSpace();
        checkWriteable();
        if (m_storage.isValid()) {
            m_timer.start();
        }

        Q_EMIT locationChanged();
    }
}

QString StorageMonitor::location() const
{
    return m_location;
}

bool StorageMonitor::diskSpaceLow() const
{
    return m_low;
}

bool StorageMonitor::diskSpaceCriticallyLow() const
{
    return m_criticallyLow;
}

bool StorageMonitor::isWriteable() const
{
    return m_writeable;
}
