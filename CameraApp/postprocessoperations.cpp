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


#include "postprocessoperations.h"
#include "adddatestamp.h"

PostProcessOperations::PostProcessOperations(QObject *parent) :
    QObject(parent)
{
}

bool PostProcessOperations::addDateStamp(const QString & path, QString dateFormat, QColor  stampColor,float   opacity, int alignment)
{

    this->workingThread = new AddDateStamp(path, dateFormat, stampColor, opacity, alignment);
    connect(this->workingThread, &AddDateStamp::finished, this->workingThread, &QObject::deleteLater);
    this->workingThread->start();
}
