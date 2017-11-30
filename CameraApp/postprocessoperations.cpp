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
                  QDate now = QDate::currentDate();
                  QString currentDate = QString(now.toString(Qt::LocaleDate));
                  int textPixelSize = ((image.width() / 3) / currentDate.length());
                  QFont font = QFont("Helvetica");
                  font.setPixelSize(textPixelSize);
                  QPainter* painter = new QPainter(&image);
                  painter->setFont(font);
                  painter->setPen(QColor("yellow"));
                  QRect imageRect = QRect(0,0,image.width()-textPixelSize,image.height()-textPixelSize);
                  painter->drawText(imageRect,Qt::AlignRight | Qt::AlignBottom,currentDate);
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
