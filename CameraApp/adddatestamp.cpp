#include <QtCore/QFile>
#include <QImage>
#include <QPainter>
#include <QDate>
#include <QLocale>

#include "adddatestamp.h"

AddDateStamp::AddDateStamp(QString inPath, QString dateFormat, QColor  stampColor, float   opacity, int alignment) {
    this->path = inPath;
    this->dateFormat = dateFormat;
    this->stampColor = stampColor;
    this->opacity = opacity;
    this->alignment = alignment;
}

void AddDateStamp::run() {
  try {

      QImage image = QImage(path);
      QDateTime now = QDateTime::currentDateTime();
      QString currentDate = QString(now.toString(this->dateFormat));
      int imageHeight = std::max(image.width(),image.height());
      int imageWidth = std::min(image.width(),image.height());
      int textPixelSize = std::min( (int) ( imageHeight * MAXIMUM_TEXT_HEIGHT_PECENT_OF_IMAGE),
                                        std::max( (imageWidth / 3) / currentDate.length() ,
                                    (int) ( imageHeight * MINIMUM_TEXT_HEIGHT_PECENT_OF_IMAGE) )  );
      QFont font = QFont("Helvetica");
      font.setPixelSize(textPixelSize);
      QPainter* painter = new QPainter(&image);
      painter->setFont(font);
      painter->setOpacity(this->opacity);
      painter->setPen(this->stampColor);
      QRect imageRect = QRect(textPixelSize,textPixelSize,image.width()-textPixelSize*2,image.height()-textPixelSize*2);
      painter->drawText(imageRect,this->alignment,currentDate);

      //Save to a temporary location and preform a filename swap in order to keep the file fully rendered
      QString tmpPath = QString(path).replace(QRegExp("(\\.\\w+)$"),"_tmp\\1");
      QString backupFilePath = QString(path).replace(QRegExp("(\\.\\w+)$"),"_old\\1");
      image.save(tmpPath);
      bool success = QFile::rename(path,backupFilePath);
      success &= QFile::rename(tmpPath, path);
      if(success) {
          QFile::remove(backupFilePath);
      } else { //try and move the backup file back to it original name
          QFile::rename(backupFilePath, path);
      }
  } catch (...) {
      return ;
  }
}
