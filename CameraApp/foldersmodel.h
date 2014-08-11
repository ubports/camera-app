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

#ifndef FOLDERSMODEL_H
#define FOLDERSMODEL_H

#include <QtCore/QObject>
#include <QtCore/QAbstractListModel>
#include <QtCore/QFileInfo>
#include <QtCore/QFileSystemWatcher>
#include <QtCore/QMimeDatabase>
#include <QtCore/QSet>

class FoldersModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY (QStringList folders READ folders WRITE setFolders NOTIFY foldersChanged)
    Q_PROPERTY (QStringList typeFilters READ typeFilters WRITE setTypeFilters NOTIFY typeFiltersChanged)
    Q_PROPERTY (QList<int> selectedFiles READ selectedFiles NOTIFY selectedFilesChanged)
    Q_PROPERTY (bool singleSelectionOnly READ singleSelectionOnly WRITE setSingleSelectionOnly NOTIFY singleSelectionOnlyChanged)

public:
    enum Roles {
        FileNameRole = Qt::UserRole + 1,
        FilePathRole = Qt::UserRole + 2,
        FileUrlRole = Qt::UserRole + 3,
        FileTypeRole = Qt::UserRole + 4,
        SelectedRole = Qt::UserRole + 5
    };

    explicit FoldersModel(QObject *parent = 0);

    QStringList folders() const;
    void setFolders(const QStringList& folders);
    QStringList typeFilters() const;
    void setTypeFilters(const QStringList& typeFilters);
    QList<int> selectedFiles() const;
    bool singleSelectionOnly() const;
    void setSingleSelectionOnly(bool singleSelectionOnly);

    void updateFileInfoList();
    void insertFileInfo(const QFileInfo& newFileInfo);

    QHash<int, QByteArray> roleNames() const;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
    int rowCount(const QModelIndex& parent = QModelIndex()) const;
    Q_INVOKABLE QVariant get(int row, QString role) const;
    Q_INVOKABLE void toggleSelected(int row);
    Q_INVOKABLE void clearSelection();

public Q_SLOTS:
    void directoryChanged(const QString &directoryPath);
    void fileChanged(const QString &directoryPath);

Q_SIGNALS:
    void foldersChanged();
    void typeFiltersChanged();
    void selectedFilesChanged();
    void singleSelectionOnlyChanged();

private:
    QStringList m_folders;
    QStringList m_typeFilters;
    QFileInfoList m_fileInfoList;
    QFileSystemWatcher* m_watcher;
    QMimeDatabase m_mimeDatabase;
    QSet<int> m_selectedFiles;
    bool m_singleSelectionOnly;
};

#endif // FOLDERSMODEL_H
