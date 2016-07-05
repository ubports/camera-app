/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#ifndef STORAGELOCATIONS_H
#define STORAGELOCATIONS_H

#include <QObject>

class StorageLocations : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString picturesLocation READ picturesLocation CONSTANT)
    Q_PROPERTY(QString videosLocation READ videosLocation CONSTANT)
    Q_PROPERTY(QString temporaryLocation READ temporaryLocation CONSTANT)
    Q_PROPERTY(QString removableStorageLocation READ removableStorageLocation CONSTANT)
    Q_PROPERTY(QString removableStoragePicturesLocation READ removableStoragePicturesLocation CONSTANT)
    Q_PROPERTY(QString removableStorageVideosLocation READ removableStorageVideosLocation CONSTANT)
    Q_PROPERTY(bool removableStoragePresent READ removableStoragePresent NOTIFY removableStoragePresentChanged)

public:
    explicit StorageLocations(QObject *parent = 0);

    QString picturesLocation() const;
    QString videosLocation() const;
    QString temporaryLocation() const;
    QString removableStorageLocation() const;
    QString removableStoragePicturesLocation() const;
    QString removableStorageVideosLocation() const;

    bool removableStoragePresent() const;
    Q_INVOKABLE void updateRemovableStorageInfo();

Q_SIGNALS:
    void removableStoragePresentChanged();

private:
    QString m_removableStorageLocation;
};

#endif // STORAGELOCATIONS_H
