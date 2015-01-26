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

#include <QtTest/QtTest>
#include <QString>
#include <QSignalSpy>

#include "storagemonitor.h"
#include "storageinfocontrol.h"

class tst_StorageMonitor : public QObject
{
  Q_OBJECT

private slots:
    void init();
    void cleanup();

    void testThresholds();
    void testValid();
    void testReady();

private:
    StorageMonitor *m_storage;
    StorageInfoControl *m_control;
};

void tst_StorageMonitor::init()
{
    m_storage = new StorageMonitor();
    m_control = StorageInfoControl::instance();
}

void tst_StorageMonitor::cleanup()
{
    delete m_storage;
}

void tst_StorageMonitor::testThresholds()
{
    QSignalSpy spyLow(m_storage, SIGNAL(diskSpaceLowChanged()));
    QSignalSpy spyCritical(m_storage, SIGNAL(diskSpaceCriticallyLowChanged()));
    QString path = "/tmp/ok";

    // before setting a path, we should get no disk space warnings
    QCOMPARE(m_storage->diskSpaceLow(), false);
    QCOMPARE(m_storage->diskSpaceCriticallyLow(), false);

    m_control->freeSpaceMap.insert(path, LOW_SPACE_THRESHOLD + 1);
    m_storage->setLocation(path);
    QCOMPARE(m_storage->diskSpaceLow(), false);
    QCOMPARE(m_storage->diskSpaceCriticallyLow(), false);

    // drop below first threshold
    m_control->freeSpaceMap.insert(path, LOW_SPACE_THRESHOLD - 1);
    spyLow.wait(POLL_INTERVAL * 1.5);
    spyCritical.wait(POLL_INTERVAL * 1.5);
    QCOMPARE(spyLow.count(), 1);
    QCOMPARE(spyCritical.count(), 0);
    QCOMPARE(m_storage->diskSpaceLow(), true);
    QCOMPARE(m_storage->diskSpaceCriticallyLow(), false);

    // drop below first threshold
    m_control->freeSpaceMap.insert(path, CRITICALLY_LOW_SPACE_THRESHOLD - 1);
    spyLow.wait(POLL_INTERVAL);
    spyCritical.wait(POLL_INTERVAL);
    QCOMPARE(spyLow.count(), 1);
    QCOMPARE(spyCritical.count(), 1);
    QCOMPARE(m_storage->diskSpaceLow(), true);
    QCOMPARE(m_storage->diskSpaceCriticallyLow(), true);

    // pull up to full free space again
    m_control->freeSpaceMap.insert(path, LOW_SPACE_THRESHOLD + MEGABYTE);
    spyLow.wait(POLL_INTERVAL);
    spyCritical.wait(POLL_INTERVAL);
    QCOMPARE(spyLow.count(), 2);
    QCOMPARE(spyCritical.count(), 2);
    QCOMPARE(m_storage->diskSpaceLow(), false);
    QCOMPARE(m_storage->diskSpaceCriticallyLow(), false);
}

void tst_StorageMonitor::testValid()
{
    QSignalSpy spyLow(m_storage, SIGNAL(diskSpaceLowChanged()));
    QSignalSpy spyCritical(m_storage, SIGNAL(diskSpaceCriticallyLowChanged()));
    QString path = "/tmp/invalid";

    // before setting a path, we should get no disk space warnings
    QCOMPARE(m_storage->diskSpaceLow(), false);
    QCOMPARE(m_storage->diskSpaceCriticallyLow(), false);

    m_control->freeSpaceMap.insert(path, LOW_SPACE_THRESHOLD + 1);
    m_storage->setLocation(path);
    QCOMPARE(m_storage->diskSpaceLow(), false);
    QCOMPARE(m_storage->diskSpaceCriticallyLow(), false);

    // make the disk ready and change the space, and verify that no changes are
    // emitted (the disk is still invalid)
    m_control->readyMap.insert(path, true);
    m_control->freeSpaceMap.insert(path, LOW_SPACE_THRESHOLD - 1);
    spyLow.wait(POLL_INTERVAL);
    spyCritical.wait(POLL_INTERVAL);
    QCOMPARE(spyLow.count(), 0);
    QCOMPARE(spyCritical.count(), 0);
}

void tst_StorageMonitor::testReady()
{
    QSignalSpy spyLow(m_storage, SIGNAL(diskSpaceLowChanged()));
    QSignalSpy spyCritical(m_storage, SIGNAL(diskSpaceCriticallyLowChanged()));
    QString path = "/tmp/unmounted";

    // before setting a path, we should get no disk space warnings
    QCOMPARE(m_storage->diskSpaceLow(), false);
    QCOMPARE(m_storage->diskSpaceCriticallyLow(), false);

    m_control->freeSpaceMap.insert(path, LOW_SPACE_THRESHOLD + 1);
    m_storage->setLocation(path);
    QCOMPARE(m_storage->diskSpaceLow(), false);
    QCOMPARE(m_storage->diskSpaceCriticallyLow(), false);

    // change the free space, and verify that no changes are
    // emitted (the disk is still not ready)
    m_control->freeSpaceMap.insert(path, LOW_SPACE_THRESHOLD - 1);
    spyLow.wait(POLL_INTERVAL);
    spyCritical.wait(POLL_INTERVAL);
    QCOMPARE(spyLow.count(), 0);
    QCOMPARE(spyCritical.count(), 0);

    // now make the disk ready and verify that we actually get a warning
    m_control->readyMap.insert(path, true);
    spyLow.wait(POLL_INTERVAL);
    QCOMPARE(spyLow.count(), 1);
}

QTEST_MAIN(tst_StorageMonitor);

#include "tst_storagemonitor.moc"
