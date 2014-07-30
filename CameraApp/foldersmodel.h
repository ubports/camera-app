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

class FoldersModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY (QStringList folders READ folders WRITE setFolders NOTIFY foldersChanged)
    Q_PROPERTY (QStringList nameFilters READ nameFilters WRITE setNameFilters NOTIFY nameFiltersChanged)

public:
    enum Roles {
        FileNameRole = Qt::UserRole + 1,
        FilePathRole = Qt::UserRole + 2,
        FileUrlRole = Qt::UserRole + 3,
        FileTypeRole = Qt::UserRole + 4
    };

    explicit FoldersModel(QObject *parent = 0);

    QStringList folders() const;
    void setFolders(const QStringList& folders);
    QStringList nameFilters() const;
    void setNameFilters(const QStringList& nameFilters);

    void updateFileInfoList();
    void insertFileInfo(const QFileInfo& newFileInfo);

    QHash<int, QByteArray> roleNames() const;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
    int rowCount(const QModelIndex& parent = QModelIndex()) const;
    Q_INVOKABLE QVariant get(int row, QString role) const;

public Q_SLOTS:
    void directoryChanged(const QString &directoryPath);

Q_SIGNALS:
    void foldersChanged();
    void nameFiltersChanged();

private:
    QStringList m_folders;
    QStringList m_nameFilters;
    QFileInfoList m_fileInfoList;
    QFileSystemWatcher* m_watcher;
    QMimeDatabase m_mimeDatabase;
};

#endif // FOLDERSMODEL_H
