#include "storagemonitor.h"

#include <QDir>
#include <QDebug>

const int POLL_INTERVAL = 1000;
const qint64 LOW_SPACE_THRESHOLD = 1024 * 1024 * 100;
const qint64 CRITICALLY_LOW_SPACE_THRESHOLD = 1024 * 1024 * 13;

StorageMonitor::StorageMonitor(QObject *parent) :
    QObject(parent), m_low(false), m_criticallyLow(false)
{
    m_timer.setInterval(POLL_INTERVAL);
    m_timer.setSingleShot(false);
    connect(&m_timer, SIGNAL(timeout()), SLOT(refresh()));
}

void StorageMonitor::checkDiskSpace(bool force)
{
    m_storage.refresh();
    if (m_storage.isValid() && m_storage.isReady()) {
        qint64 freeSpace = m_storage.bytesFree();
        qDebug() << "checking disk space" << freeSpace;

        bool current = (freeSpace <= LOW_SPACE_THRESHOLD);
        if (force || current != m_low) {
            m_low = current;
            Q_EMIT(diskSpaceLowChanged());
        }

        current = (freeSpace <= CRITICALLY_LOW_SPACE_THRESHOLD);
        if (force || current != m_criticallyLow) {
            m_criticallyLow = current;
            Q_EMIT(diskSpaceCriticallyLowChanged());
        }
    } else {
        if (force || !m_low) {
            m_low = true;
            Q_EMIT(diskSpaceLowChanged());
        }
        if (force || !m_criticallyLow) {
            m_criticallyLow = true;
            Q_EMIT(diskSpaceCriticallyLowChanged());
        }
    }
}

void StorageMonitor::refresh()
{
    checkDiskSpace(false);
}

void StorageMonitor::setLocation(QString location)
{
    if (location != m_location) {
        QDir target(location);
        if (target.exists()) {
            m_timer.stop();

            m_location = location;
            m_storage.setPath(m_location);
            checkDiskSpace(true);

            m_timer.start();
        }
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
