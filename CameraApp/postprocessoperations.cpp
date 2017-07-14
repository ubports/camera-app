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

bool PostProcessOperations::addDateStamp(const QString & path)
{
    const int TEXT_POINT_SIZE=24;
    //TODO run async
    class AddDateStamp : public QThread {

        QString path;

        public:
          AddDateStamp(QString inPath) {
              this->path = inPath;
          }

          void run() {
              try {
                  QImage image = QImage(path);
                  QPainter* painter = new QPainter(&image);
                  painter->setFont(QFont("Helvetica",TEXT_POINT_SIZE));
                  painter->setPen(QColor("yellow"));
                  QDate now = QDate::currentDate();
                  painter->drawText(image.width()-TEXT_POINT_SIZE*25,image.height()-TEXT_POINT_SIZE*2.5,now.toString(Qt::LocaleDate));
                  image.save(path);
              } catch (...) {
                  return ;
              }
          }
    } ;

    this->workingThread = new AddDateStamp(path);
    connect(this->workingThread, &AddDateStamp::finished, this->workingThread, &QObject::deleteLater);
    this->workingThread->start();
}
