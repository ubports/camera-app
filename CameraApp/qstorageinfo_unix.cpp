/****************************************************************************
**
** Copyright (C) 2014 Ivan Komissarov <ABBAPOH@gmail.com>
** Contact: http://www.qt-project.org/legal
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

#include "qstorageinfo_p.h"

#include <QtCore/qdiriterator.h>
#include <QtCore/qfileinfo.h>
#include <QtCore/qtextstream.h>

// Copy this definition directly instead of importing the whole file which
// would pull in more dependencies we don't need.
//#include <QtCore/private/qcore_unix_p.h>
#define EINTR_LOOP(var, cmd)                    \
    do {                                        \
        var = cmd;                              \
    } while (var == -1 && errno == EINTR)

#include <errno.h>
#include <sys/stat.h>

#if defined(Q_OS_BSD4)
#  include <sys/mount.h>
#  include <sys/statvfs.h>
#elif defined(Q_OS_ANDROID)
#  include <sys/mount.h>
#  include <sys/vfs.h>
#  include <mntent.h>
#elif defined(Q_OS_LINUX)
#  include <mntent.h>
#  include <sys/statvfs.h>
#elif defined(Q_OS_SOLARIS)
#  include <sys/mnttab.h>
#else
#  include <sys/statvfs.h>
#endif

#if defined(Q_OS_BSD4)
#  define QT_STATFSBUF struct statvfs
#  define QT_STATFS    ::statvfs
#elif defined(Q_OS_ANDROID)
#  define QT_STATFS    ::statfs
#  define QT_STATFSBUF struct statfs
#  if !defined(ST_RDONLY)
#    define ST_RDONLY 1 // hack for missing define on Android
#  endif
#else
#  if defined(QT_LARGEFILE_SUPPORT)
#    define QT_STATFSBUF struct statvfs64
#    define QT_STATFS    ::statvfs64
#  else
#    define QT_STATFSBUF struct statvfs
#    define QT_STATFS    ::statvfs
#  endif // QT_LARGEFILE_SUPPORT
#endif // Q_OS_BSD4

QT_BEGIN_NAMESPACE

static bool isPseudoFs(const QString &mountDir, const QByteArray &type)
{
    if (mountDir.startsWith(QLatin1String("/dev"))
        || mountDir.startsWith(QLatin1String("/proc"))
        || mountDir.startsWith(QLatin1String("/sys"))
        || mountDir.startsWith(QLatin1String("/var/run"))
        || mountDir.startsWith(QLatin1String("/var/lock"))) {
        return true;
    }
    if (type == "tmpfs")
        return true;
#if defined(Q_OS_LINUX)
    if (type == "rootfs" || type == "rpc_pipefs")
        return true;
#endif

    return false;
}

class QStorageIterator
{
public:
    QStorageIterator();
    ~QStorageIterator();

    inline bool isValid() const;
    inline bool next();
    inline QString rootPath() const;
    inline QByteArray fileSystemType() const;
    inline QByteArray device() const;
private:
#if defined(Q_OS_BSD4)
    struct statfs *stat_buf;
    int entryCount;
    int currentIndex;
#elif defined(Q_OS_SOLARIS)
    FILE *fp;
    mnttab mnt;
#elif defined(Q_OS_ANDROID)
    QFile file;
    QByteArray m_rootPath;
    QByteArray m_fileSystemType;
    QByteArray m_device;
#elif defined(Q_OS_LINUX)
    FILE *fp;
    mntent mnt;
    QByteArray buffer;
#endif
};

#if defined(Q_OS_BSD4)

inline QStorageIterator::QStorageIterator()
    : entryCount(::getmntinfo(&stat_buf, 0)),
      currentIndex(-1)
{
}

inline QStorageIterator::~QStorageIterator()
{
}

inline bool QStorageIterator::isValid() const
{
    return entryCount != -1;
}

inline bool QStorageIterator::next()
{
    return ++currentIndex < entryCount;
}

inline QString QStorageIterator::rootPath() const
{
    return QFile::decodeName(stat_buf[currentIndex].f_mntonname);
}

inline QByteArray QStorageIterator::fileSystemType() const
{
    return QByteArray(stat_buf[currentIndex].f_fstypename);
}

inline QByteArray QStorageIterator::device() const
{
    return QByteArray(stat_buf[currentIndex].f_mntfromname);
}

#elif defined(Q_OS_SOLARIS)

static const char pathMounted[] = "/etc/mnttab";

inline QStorageIterator::QStorageIterator()
{
    const int fd = qt_safe_open(pathMounted, O_RDONLY);
    fp = ::fdopen(fd, "r");
}

inline QStorageIterator::~QStorageIterator()
{
    if (fp)
        ::fclose(fp);
}

inline bool QStorageIterator::isValid() const
{
    return fp != Q_NULLPTR;
}

inline bool QStorageIterator::next()
{
    return ::getmntent(fp, &mnt) == Q_NULLPTR;
}

inline QString QStorageIterator::rootPath() const
{
    return QFile::decodeName(mnt->mnt_mountp);
}

inline QByteArray QStorageIterator::fileSystemType() const
{
    return QByteArray(mnt->mnt_fstype);
}

inline QByteArray QStorageIterator::device() const
{
    return QByteArray(mnt->mnt_mntopts);
}

#elif defined(Q_OS_ANDROID)

static const char pathMounted[] = "/proc/mounts";

inline QStorageIterator::QStorageIterator()
{
    file.setFileName(pathMounted);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
}

inline QStorageIterator::~QStorageIterator()
{
}

inline bool QStorageIterator::isValid() const
{
    return file.isOpen();
}

inline bool QStorageIterator::next()
{
    QList<QByteArray> data;
    do {
        const QByteArray line = file.readLine();
        data = line.split(' ');
    } while (data.count() < 3 && !file.atEnd());

    if (file.atEnd())
        return false;
    m_device = data.at(0);
    m_rootPath = data.at(1);
    m_fileSystemType = data.at(2);

    return true;
}

inline QString QStorageIterator::rootPath() const
{
    return QFile::decodeName(m_rootPath);
}

inline QByteArray QStorageIterator::fileSystemType() const
{
    return m_fileSystemType;
}

inline QByteArray QStorageIterator::device() const
{
    return m_device;
}

#elif defined(Q_OS_LINUX)

static const char pathMounted[] = "/etc/mtab";
static const int bufferSize = 3*PATH_MAX; // 2 paths (mount point+device) and metainfo

inline QStorageIterator::QStorageIterator() :
    buffer(QByteArray(bufferSize, 0))
{
    fp = ::setmntent(pathMounted, "r");
}

inline QStorageIterator::~QStorageIterator()
{
    if (fp)
        ::endmntent(fp);
}

inline bool QStorageIterator::isValid() const
{
    return fp != Q_NULLPTR;
}

inline bool QStorageIterator::next()
{
    return ::getmntent_r(fp, &mnt, buffer.data(), buffer.size()) != Q_NULLPTR;
}

inline QString QStorageIterator::rootPath() const
{
    return QFile::decodeName(mnt.mnt_dir);
}

inline QByteArray QStorageIterator::fileSystemType() const
{
    return QByteArray(mnt.mnt_type);
}

inline QByteArray QStorageIterator::device() const
{
    return QByteArray(mnt.mnt_fsname);
}

#else

inline QStorageIterator::QStorageIterator()
{
}

inline QStorageIterator::~QStorageIterator()
{
}

inline bool QStorageIterator::isValid() const
{
    return false;
}

inline bool QStorageIterator::next()
{
    return false;
}

inline QString QStorageIterator::rootPath() const
{
    return QString();
}

inline QByteArray QStorageIterator::fileSystemType() const
{
    return QByteArray();
}

inline QByteArray QStorageIterator::device() const
{
    return QByteArray();
}

#endif

void QStorageInfoPrivate::initRootPath()
{
    rootPath = QFileInfo(rootPath).canonicalFilePath();

    if (rootPath.isEmpty())
        return;

    QStorageIterator it;
    if (!it.isValid()) {
        rootPath = QStringLiteral("/");
        return;
    }

    int maxLength = 0;
    const QString oldRootPath = rootPath;
    rootPath.clear();

    while (it.next()) {
        const QString mountDir = it.rootPath();
        const QByteArray fsName = it.fileSystemType();
        if (isPseudoFs(mountDir, fsName))
            continue;
        // we try to find most suitable entry
        if (oldRootPath.startsWith(mountDir) && maxLength < mountDir.length()) {
            maxLength = mountDir.length();
            rootPath = mountDir;
            device = it.device();
            fileSystemType = fsName;
        }
    }
}

static inline QString retrieveLabel(const QByteArray &device)
{
#ifdef Q_OS_LINUX
    static const char pathDiskByLabel[] = "/dev/disk/by-label";

    QDirIterator it(QLatin1String(pathDiskByLabel), QDir::NoDotAndDotDot);
    while (it.hasNext()) {
        it.next();
        QFileInfo fileInfo(it.fileInfo());
        if (fileInfo.isSymLink() && fileInfo.symLinkTarget().toLocal8Bit() == device)
            return fileInfo.fileName();
    }
#else
    Q_UNUSED(device);
#endif

    return QString();
}

void QStorageInfoPrivate::doStat()
{
    initRootPath();
    if (rootPath.isEmpty())
        return;

    retreiveVolumeInfo();
    name = retrieveLabel(device);
}

void QStorageInfoPrivate::retreiveVolumeInfo()
{
    QT_STATFSBUF statfs_buf;
    int result;
    EINTR_LOOP(result, QT_STATFS(QFile::encodeName(rootPath).constData(), &statfs_buf));
    if (result == 0) {
        valid = true;
        ready = true;

        bytesTotal = statfs_buf.f_blocks * statfs_buf.f_bsize;
        bytesFree = statfs_buf.f_bfree * statfs_buf.f_bsize;
        bytesAvailable = statfs_buf.f_bavail * statfs_buf.f_bsize;
#if defined(Q_OS_ANDROID)
#if defined(_STATFS_F_FLAGS)
        readOnly = (statfs_buf.f_flags & ST_RDONLY) != 0;
#endif
#else
        readOnly = (statfs_buf.f_flag & ST_RDONLY) != 0;
#endif
    }
}

QList<QStorageInfo> QStorageInfoPrivate::mountedVolumes()
{
    QStorageIterator it;
    if (!it.isValid())
        return QList<QStorageInfo>() << root();

    QList<QStorageInfo> volumes;

    while (it.next()) {
        const QString mountDir = it.rootPath();
        const QByteArray fsName = it.fileSystemType();
        if (isPseudoFs(mountDir, fsName))
            continue;

        volumes.append(QStorageInfo(mountDir));
    }

    return volumes;
}

QStorageInfo QStorageInfoPrivate::root()
{
    return QStorageInfo(QStringLiteral("/"));
}

QT_END_NAMESPACE
