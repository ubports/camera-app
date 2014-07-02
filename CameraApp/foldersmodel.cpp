/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "foldersmodel.h"
#include <QtCore/QDir>
#include <QtCore/QUrl>
#include <QtCore/QDateTime>

FoldersModel::FoldersModel(QObject *parent) :
    QAbstractListModel(parent)
{
    m_watcher = new QFileSystemWatcher(this);
    connect(m_watcher, SIGNAL(directoryChanged(QString)), this, SLOT(directoryChanged(QString)));
}

QStringList FoldersModel::folders() const
{
    return m_folders;
}

void FoldersModel::setFolders(const QStringList& folders)
{
    m_watcher->removePaths(m_folders);
    m_folders = folders;
    m_watcher->addPaths(m_folders);
    updateFileInfoList();
    Q_EMIT foldersChanged();
}

QStringList FoldersModel::nameFilters() const
{
    return m_nameFilters;
}

void FoldersModel::setNameFilters(const QStringList& nameFilters)
{
    m_nameFilters = nameFilters;
    updateFileInfoList();
    Q_EMIT nameFiltersChanged();
}

void FoldersModel::updateFileInfoList()
{
    m_fileInfoList.clear();
    Q_FOREACH (QString folder, m_folders) {
        QDir currentDir(folder);
        QFileInfoList fileInfoList = currentDir.entryInfoList(m_nameFilters,
                                                              QDir::Files | QDir::Readable,
                                                              QDir::Time | QDir::Reversed);
        Q_FOREACH (QFileInfo fileInfo, fileInfoList) {
            insertFileInfo(fileInfo);
        }
    }
    endResetModel();
}

bool moreRecentThan(const QFileInfo& fileInfo1, const QFileInfo& fileInfo2)
{
    return fileInfo1.lastModified() < fileInfo2.lastModified();
}

// inserts newFileInfo into m_fileInfoList while keeping m_fileInfoList sorted by
// file modification time with the files most recently modified first
void FoldersModel::insertFileInfo(const QFileInfo& newFileInfo)
{
    QFileInfoList::iterator i;
    for (i = m_fileInfoList.begin(); i != m_fileInfoList.end(); ++i) {
        QFileInfo fileInfo = *i;
        if (!moreRecentThan(newFileInfo, fileInfo)) {
            m_fileInfoList.insert(i, newFileInfo);
            return;
        }
    }
    m_fileInfoList.append(newFileInfo);
}

QHash<int, QByteArray> FoldersModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[FileNameRole] = "fileName";
    roles[FilePathRole] = "filePath";
    roles[FileUrlRole] = "fileURL";
    return roles;
}

QVariant FoldersModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    if (index.row() < 0 || index.row() >= m_fileInfoList.count()) {
        return QVariant();
    }

    switch (role)
    {
        case FileNameRole:
            return m_fileInfoList.at(index.row()).fileName();
            break;
        case FilePathRole:
            return m_fileInfoList.at(index.row()).filePath();
            break;
        case FileUrlRole:
            return QUrl::fromLocalFile(m_fileInfoList.at(index.row()).filePath());
            break;
        default:
            break;
    }

    return QVariant();
}

int FoldersModel::rowCount(const QModelIndex& parent) const
{
    return m_fileInfoList.count();
}

QVariant FoldersModel::get(int index, QString role) const
{
    Q_UNUSED(role)

    if (index < 0 || index >= m_fileInfoList.count()) {
        return QVariant();
    }

    return QVariant::fromValue(m_fileInfoList.at(index).absoluteFilePath());
}

void FoldersModel::directoryChanged(const QString &directoryPath)
{
    updateFileInfoList();
}
