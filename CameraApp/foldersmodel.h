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
#include <QtCore/QFutureWatcher>
#include <QtQml/QQmlParserStatus>

class FoldersModel : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY (QStringList folders READ folders WRITE setFolders NOTIFY foldersChanged)
    Q_PROPERTY (QStringList typeFilters READ typeFilters WRITE setTypeFilters NOTIFY typeFiltersChanged)
    Q_PROPERTY (QList<int> selectedFiles READ selectedFiles NOTIFY selectedFilesChanged)
    Q_PROPERTY (bool singleSelectionOnly READ singleSelectionOnly WRITE setSingleSelectionOnly NOTIFY singleSelectionOnlyChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

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
    int count() const;
    bool loading() const;

    void updateFileInfoList();
    QPair<QFileInfoList, QStringList> computeFileInfoList(QStringList folders);
    bool fileMatchesTypeFilters(const QFileInfo& newFileInfo);
    void insertFileInfo(const QFileInfo& newFileInfo);
    void setFileInfoList(QFileInfoList fileInfoList, const QStringList& filesToWatch);

    QHash<int, QByteArray> roleNames() const;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
    int rowCount(const QModelIndex& parent = QModelIndex()) const;
    Q_INVOKABLE QVariant get(int row, QString role) const;
    Q_INVOKABLE void toggleSelected(int row);
    Q_INVOKABLE void clearSelection();
    Q_INVOKABLE void selectAll();
    Q_INVOKABLE void prependFile(QString filePath);
    Q_INVOKABLE void deleteSelectedFiles();

    // inherited from QQmlParserStatus
    void classBegin();
    void componentComplete();

public Q_SLOTS:
    void fileChanged(const QString &directoryPath);
    void updateFileInfoListFinished();

Q_SIGNALS:
    void foldersChanged();
    void typeFiltersChanged();
    void selectedFilesChanged();
    void singleSelectionOnlyChanged();
    void countChanged();
    void loadingChanged();

private:
    QStringList m_folders;
    QStringList m_typeFilters;
    QFileInfoList m_fileInfoList;
    QFileSystemWatcher* m_watcher;
    QMimeDatabase m_mimeDatabase;
    QSet<int> m_selectedFiles;
    bool m_singleSelectionOnly;
    QFutureWatcher<QPair<QFileInfoList, QStringList> > m_updateFutureWatcher;
    bool m_completed;
    bool m_loading;
};

#endif // FOLDERSMODEL_H
