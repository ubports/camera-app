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
#include <QtCore/QFuture>
#include <QtCore/QFutureWatcher>
#include <QtCore/QtAlgorithms>
#include <QtConcurrent/QtConcurrentRun>

bool newerThan(const QFileInfo& fileInfo1, const QFileInfo& fileInfo2)
{
    return fileInfo1.lastModified() > fileInfo2.lastModified();
}


FoldersModel::FoldersModel(QObject *parent) :
    QAbstractListModel(parent),
    m_singleSelectionOnly(true),
    m_completed(false),
    m_loading(false)
{
    m_watcher = new QFileSystemWatcher(this);
    connect(m_watcher, SIGNAL(fileChanged(QString)), this, SLOT(fileChanged(QString)));
    connect(&m_updateFutureWatcher, SIGNAL(finished()), this, SLOT(updateFileInfoListFinished()));
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

int FoldersModel::count() const
{
    return m_fileInfoList.count();
}

bool FoldersModel::loading() const
{
    return m_loading;
}

void FoldersModel::updateFileInfoList()
{
    if (!m_completed) {
        return;
    }

    m_loading = true;
    Q_EMIT loadingChanged();

    beginResetModel();
    m_fileInfoList.clear();
    endResetModel();
    m_selectedFiles.clear();
    Q_EMIT selectedFilesChanged();
    Q_EMIT countChanged();

    m_updateFutureWatcher.cancel();
    QFuture<QPair<QFileInfoList, QStringList> > future = QtConcurrent::run(this, &FoldersModel::computeFileInfoList, m_folders);
    m_updateFutureWatcher.setFuture(future);
}

QPair<QFileInfoList, QStringList> FoldersModel::computeFileInfoList(QStringList folders)
{
    QFileInfoList filteredFileInfoList;
    QStringList filesToWatch;

    Q_FOREACH (QString folder, folders) {
        if (folder.isEmpty()) continue;

        QDir currentDir(folder);
        QFileInfoList fileInfoList = currentDir.entryInfoList(QDir::Files | QDir::Readable,
                                                              QDir::Time | QDir::Reversed);
        Q_FOREACH (QFileInfo fileInfo, fileInfoList) {
            filesToWatch.append(fileInfo.absoluteFilePath());
            if (fileMatchesTypeFilters(fileInfo)) {
                filteredFileInfoList.append(fileInfo);
            }
        }
    }
    qSort(filteredFileInfoList.begin(), filteredFileInfoList.end(), newerThan);
    return QPair<QFileInfoList, QStringList>(filteredFileInfoList, filesToWatch);
}

void FoldersModel::updateFileInfoListFinished()
{
    QPair<QFileInfoList, QStringList> result = m_updateFutureWatcher.result();
    setFileInfoList(result.first, result.second);
}

void FoldersModel::setFileInfoList(QFileInfoList fileInfoList, const QStringList& filesToWatch)
{
    // prepend files that have been added while the list was computed
    Q_FOREACH (QFileInfo fileInfo, m_fileInfoList) {
        if(!fileInfoList.contains(fileInfo)) {
            fileInfoList.prepend(fileInfo);
        }
    }

    beginResetModel();
    m_fileInfoList = fileInfoList;
    endResetModel();

    // Start monitoring files for modifications in a separate thread as it is very time consuming
    QtConcurrent::run(m_watcher, &QFileSystemWatcher::addPaths, filesToWatch);

    m_loading = false;
    Q_EMIT loadingChanged();
    Q_EMIT countChanged();
}

bool FoldersModel::fileMatchesTypeFilters(const QFileInfo& newFileInfo)
{
    QString type = m_mimeDatabase.mimeTypeForFile(newFileInfo).name();
    Q_FOREACH (QString filterType, m_typeFilters) {
        if (type.startsWith(filterType)) {
            return true;
        }
    }
    return false;
}

// inserts newFileInfo into m_fileInfoList while keeping m_fileInfoList sorted by
// file modification time with the files most recently modified first
void FoldersModel::insertFileInfo(const QFileInfo& newFileInfo)
{
    QFileInfoList::iterator i;
    for (i = m_fileInfoList.begin(); i != m_fileInfoList.end(); ++i) {
        QFileInfo fileInfo = *i;
        if (newerThan(newFileInfo, fileInfo)) {
            int index = m_fileInfoList.indexOf(*i);
            beginInsertRows(QModelIndex(), index, index);
            m_fileInfoList.insert(i, newFileInfo);
            endInsertRows();
            return;
        }
    }

    int index = m_fileInfoList.size();
    beginInsertRows(QModelIndex(), index, index);
    m_fileInfoList.append(newFileInfo);
    endInsertRows();
    Q_EMIT countChanged();
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

void FoldersModel::fileChanged(const QString &filePath)
{
    /* Act appropriately upon file change or removal */
    bool exists = QFileInfo::exists(filePath);
    int fileIndex = m_fileInfoList.indexOf(QFileInfo(filePath));

    if (exists) {
        // file's content has changed
        QFileInfo fileInfo = QFileInfo(filePath);
        if (fileIndex == -1) {
            // file's type might have changed and file might have to be included
            if (fileMatchesTypeFilters(fileInfo)) {
                insertFileInfo(fileInfo);
            }
        } else {
            // update file information
            QModelIndex modelIndex = this->index(fileIndex);
            m_fileInfoList[fileIndex] = fileInfo;
            Q_EMIT dataChanged(modelIndex, modelIndex);
        }

        // As the documentation states, in some cases the watch is removed on a
        // fileChanged signal, so we will need to add it back again.
        // addPath() will safely do nothing if the file is still being watched.
        m_watcher->addPath(filePath);
    } else {
        // file has either been removed or renamed
        if (fileIndex != -1) {
            // FIXME: handle the renamed case
            beginRemoveRows(QModelIndex(), fileIndex, fileIndex);
            m_fileInfoList.removeAt(fileIndex);
            endRemoveRows();
            Q_EMIT countChanged();
        }
    }
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

void FoldersModel::prependFile(QString filePath)
{
    if (!m_watcher->files().contains(filePath)) {
        QFileInfo fileInfo(filePath);
        m_watcher->addPath(filePath);
        if (fileMatchesTypeFilters(fileInfo)) {
           insertFileInfo(fileInfo);
        }
    }
}

void FoldersModel::selectAll()
{
    for (int row = 0; row < m_fileInfoList.size(); ++row) {
        if (!m_selectedFiles.contains(row)) {
            m_selectedFiles.insert(row);
        }
        Q_EMIT dataChanged(index(row), index(row));
    }
    Q_EMIT selectedFilesChanged();
}

void FoldersModel::deleteSelectedFiles()
{
    Q_FOREACH (int selectedFile, m_selectedFiles) {
        QString filePath = m_fileInfoList.at(selectedFile).filePath();
        QFile::remove(filePath);
    }
    m_selectedFiles.clear();
    Q_EMIT selectedFilesChanged();
}

void FoldersModel::classBegin()
{
}

void FoldersModel::componentComplete()
{
    m_completed = true;
    updateFileInfoList();
}
