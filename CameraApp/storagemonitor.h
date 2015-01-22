#ifndef STORAGEMONITOR_H
#define STORAGEMONITOR_H

#include <QObject>
#include <QTimer>

#include "qstorageinfo.h"

class StorageMonitor : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString location READ location WRITE setLocation NOTIFY locationChanged)
    Q_PROPERTY(bool diskSpaceLow READ diskSpaceLow NOTIFY diskSpaceLowChanged)
    Q_PROPERTY(bool diskSpaceCriticallyLow READ diskSpaceCriticallyLow NOTIFY diskSpaceCriticallyLowChanged)

public:
    explicit StorageMonitor(QObject *parent = 0);

    QString location() const;
    void setLocation(QString location);
    bool diskSpaceLow() const;
    bool diskSpaceCriticallyLow() const;

Q_SIGNALS:
    void locationChanged();
    void diskSpaceLowChanged();
    void diskSpaceCriticallyLowChanged();

private Q_SLOTS:
    void refresh();

private:
    void checkDiskSpace(bool force);

    bool m_low;
    bool m_criticallyLow;
    QTimer m_timer;
    QString m_location;
    QStorageInfo m_storage;
};

#endif // STORAGEMONITOR_H
