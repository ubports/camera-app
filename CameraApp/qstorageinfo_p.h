/****************************************************************************
**
** Copyright (C) 2014 Ivan Komissarov <ABBAPOH@gmail.com>
** Contact: http://www.qt-project.org/legal
**
**
** This file is part of the QtCore module of the Qt Toolkit.
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; version 3.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
**
****************************************************************************/

#ifndef QSTORAGEINFO_P_H
#define QSTORAGEINFO_P_H

//
//  W A R N I N G
//  -------------
//
// This file is not part of the Qt API.  It exists purely as an
// implementation detail.  This header file may change from version to
// version without notice, or even be removed.
//
// We mean it.
//

#include "qstorageinfo.h"

QT_BEGIN_NAMESPACE

class QStorageInfoPrivate : public QSharedData
{
public:
    inline QStorageInfoPrivate() : QSharedData(),
        bytesTotal(0), bytesFree(0), bytesAvailable(0),
        readOnly(false), ready(false), valid(false)
    {}

    void initRootPath();
    void doStat();

    static QList<QStorageInfo> mountedVolumes();
    static QStorageInfo root();

protected:
#if defined(Q_OS_WIN) && !defined(Q_OS_WINCE) && !defined(Q_OS_WINRT)
    void retreiveVolumeInfo();
    void retreiveDiskFreeSpace();
#elif defined(Q_OS_MAC)
    void retrievePosixInfo();
    void retrieveUrlProperties(bool initRootPath = false);
    void retrieveLabel();
#elif defined(Q_OS_UNIX)
    void retreiveVolumeInfo();
#endif

public:
    QString rootPath;
    QByteArray device;
    QByteArray fileSystemType;
    QString name;

    qint64 bytesTotal;
    qint64 bytesFree;
    qint64 bytesAvailable;

    bool readOnly;
    bool ready;
    bool valid;
};

QT_END_NAMESPACE

#endif // QSTORAGEINFO_P_H
