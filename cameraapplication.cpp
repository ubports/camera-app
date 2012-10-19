#include "cameraapplication.h"

#include <QtCore/QDir>
#include <QtCore/QUrl>
#include <QtCore/QDebug>
#include <QtCore/QStringList>
#include <QQmlContext>
#include <QtQuick/QQuickItem>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusReply>
#include <QtDBus/QDBusConnectionInterface>
#include <QStandardPaths>
#include "config.h"

static void printUsage(const QStringList& arguments)
{
    qDebug() << "usage:"
             << arguments.at(0).toUtf8().constData();
}

CameraApplication::CameraApplication(int &argc, char **argv)
    : QGuiApplication(argc, argv), m_view(0)
{
}

bool CameraApplication::setup()
{
    m_view = new QQuickView();
    QObject::connect(m_view, SIGNAL(statusChanged(QDeclarativeView::Status)), this, SLOT(onViewStatusChanged(QDeclarativeView::Status)));
    m_view->setResizeMode(QQuickView::SizeRootObjectToView);
    m_view->setWindowTitle("Camera");
    m_view->rootContext()->setContextProperty("application", this);
    m_view->rootContext()->setContextProperty("picturesDirectory", QStandardPaths::writableLocation(QStandardPaths::PicturesLocation));
    QUrl source(cameraAppDirectory() + "/camera-app.qml");
    m_view->setSource(source);
    m_view->show();

    return true;
}

CameraApplication::~CameraApplication()
{
    if (m_view) {
        delete m_view;
    }
}
