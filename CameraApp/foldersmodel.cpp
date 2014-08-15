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
    QAbstractListModel(parent),
    m_singleSelectionOnly(true)
{
    m_watcher = new QFileSystemWatcher(this);
    connect(m_watcher, SIGNAL(directoryChanged(QString)), this, SLOT(directoryChanged(QString)));
    connect(m_watcher, SIGNAL(fileChanged(QString)), this, SLOT(fileChanged(QString)));
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

QStringList FoldersModel::typeFilters() const
{
    return m_typeFilters;
}

void FoldersModel::setTypeFilters(const QStringList& typeFilters)
{
    m_typeFilters = typeFilters;
    updateFileInfoList();
    Q_EMIT typeFiltersChanged();
}

QList<int> FoldersModel::selectedFiles() const
{
    return m_selectedFiles.values();
}

bool FoldersModel::singleSelectionOnly() const
{
    return m_singleSelectionOnly;
}

void FoldersModel::setSingleSelectionOnly(bool singleSelectionOnly)
{
    if (singleSelectionOnly != m_singleSelectionOnly) {
        if (singleSelectionOnly && m_selectedFiles.count() > 1) {
            clearSelection();
        }
        m_singleSelectionOnly = singleSelectionOnly;
        Q_EMIT singleSelectionOnlyChanged();
    }
}


void FoldersModel::updateFileInfoList()
{
    m_fileInfoList.clear();
    Q_FOREACH (QString folder, m_folders) {
        QDir currentDir(folder);
        QFileInfoList fileInfoList = currentDir.entryInfoList(QDir::Files | QDir::Readable,
                                                              QDir::Time | QDir::Reversed);
        Q_FOREACH (QFileInfo fileInfo, fileInfoList) {
            m_watcher->addPath(fileInfo.absoluteFilePath());
            QString type = m_mimeDatabase.mimeTypeForFile(fileInfo).name();
            Q_FOREACH (QString filterType, m_typeFilters) {
                if (type.startsWith(filterType)) {
                    insertFileInfo(fileInfo);
                    break;
                }
            }
        }
    }
    endResetModel();
    m_selectedFiles.clear();
    Q_EMIT selectedFilesChanged();
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
    roles[FileTypeRole] = "fileType";
    roles[SelectedRole] = "selected";
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

    QFileInfo item = m_fileInfoList.at(index.row());
    switch (role)
    {
        case FileNameRole:
            return item.fileName();
            break;
        case FilePathRole:
            return item.filePath();
            break;
        case FileUrlRole:
            return QUrl::fromLocalFile(item.filePath());
            break;
        case FileTypeRole:
            return m_mimeDatabase.mimeTypeForFile(item).name();
            break;
        case SelectedRole:
            return m_selectedFiles.contains(index.row());
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

QVariant FoldersModel::get(int row, QString role) const
{
    return data(index(row), roleNames().key(role.toUtf8()));
}

void FoldersModel::directoryChanged(const QString &directoryPath)
{
    updateFileInfoList();
}

void FoldersModel::fileChanged(const QString &filePath)
{
    updateFileInfoList();
}

void FoldersModel::toggleSelected(int row)
{
    if (m_selectedFiles.contains(row)) {
        m_selectedFiles.remove(row);
    } else {
        if (m_singleSelectionOnly) {
            int previouslySelected = m_selectedFiles.isEmpty() ? -1 : m_selectedFiles.values().first();
            if (previouslySelected != -1) {
                m_selectedFiles.remove(previouslySelected);
                Q_EMIT dataChanged(index(previouslySelected), index(previouslySelected));
            }
        }
        m_selectedFiles.insert(row);
    }

    Q_EMIT dataChanged(index(row), index(row));
    Q_EMIT selectedFilesChanged();
}

void FoldersModel::clearSelection()
{
    Q_FOREACH (int selectedFile, m_selectedFiles) {
        m_selectedFiles.remove(selectedFile);
        Q_EMIT dataChanged(index(selectedFile), index(selectedFile));
    }
    Q_EMIT selectedFilesChanged();
}
