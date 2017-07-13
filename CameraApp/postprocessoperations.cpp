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
#include <QtCore/QFile>
#include <QImage>
#include <QPainter>
#include <QDate>

PostProcessOperations::PostProcessOperations(QObject *parent) :
    QObject(parent)
{
}

bool PostProcessOperations::addDateStamp(const QString & path) const
{
    //TODO run async
    try {      
        const int TEXT_POINT_SIZE=24;
        QImage image = QImage(path);
        QPainter* painter = new QPainter(&image);
        painter->setFont(QFont("Helvetica",TEXT_POINT_SIZE));
        painter->setPen(QColor("yellow"));
        QDate now = QDate::currentDate();
        painter->drawText(image.width()-TEXT_POINT_SIZE*25,image.height()-TEXT_POINT_SIZE*2.5,now.toString(Qt::LocaleDate));
        image.save(path);
        return true;
    } catch (...) {
        return false;
    }
}
