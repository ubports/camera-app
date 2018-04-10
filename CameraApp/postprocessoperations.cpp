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
#include <QLocale>

PostProcessOperations::PostProcessOperations(QObject *parent) :
    QObject(parent)
{
}

bool PostProcessOperations::addDateStamp(const QString & path, QString dateFormat, QColor  stampColor,float   opacity, int alignment)
{
    class AddDateStamp : public QThread {

        QString path;
        QString dateFormat;
        QColor  stampColor;
        float   opacity;
        int alignment;

        public:
          AddDateStamp(QString inPath, QString dateFormat, QColor  stampColor, float   opacity, int alignment) {
              this->path = inPath;
              this->dateFormat = dateFormat;
              this->stampColor = stampColor;
              this->opacity = opacity;
              this->alignment = alignment;
          }

          void run() {
              try {
                  QImage image = QImage(path);
                  QDateTime now = QDateTime::currentDateTime();
                  QString currentDate = QString(now.toString(this->dateFormat));
                  int textPixelSize = ((std::min(image.width(),image.height()) / 3) / currentDate.length());
                  QFont font = QFont("Helvetica");
                  font.setPixelSize(textPixelSize);
                  QPainter* painter = new QPainter(&image);
                  painter->setFont(font);
                  painter->setOpacity(this->opacity);
                  painter->setPen(this->stampColor);
                  QRect imageRect = QRect(textPixelSize,textPixelSize,image.width()-textPixelSize*2,image.height()-textPixelSize*2);
                  painter->drawText(imageRect,this->alignment,currentDate);
                  image.save(path);
              } catch (...) {
                  return ;
              }
          }
    };

    this->workingThread = new AddDateStamp(path, dateFormat, stampColor, opacity, alignment);
    connect(this->workingThread, &AddDateStamp::finished, this->workingThread, &QObject::deleteLater);
    this->workingThread->start();
}
