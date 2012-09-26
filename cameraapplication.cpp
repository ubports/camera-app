#include "cameraapplication.h"

#include <QtCore/QDir>
#include <QtCore/QUrl>
#include <QtCore/QDebug>
#include <QtCore/QStringList>
#include <QtGui/QGraphicsObject>
#include <QtDeclarative/QDeclarativeComponent>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeView>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusReply>
#include <QtDBus/QDBusConnectionInterface>
#include "config.h"

static void printUsage(const QStringList& arguments)
{
    qDebug() << "usage:"
             << arguments.at(0).toUtf8().constData();
}

CameraApplication::CameraApplication(int &argc, char **argv)
    : QApplication(argc, argv), m_view(0), m_applicationIsReady(false)
{
}

bool CameraApplication::setup()
{
    m_view = new QDeclarativeView();
    QObject::connect(m_view, SIGNAL(statusChanged(QDeclarativeView::Status)), this, SLOT(onViewStatusChanged(QDeclarativeView::Status)));
    m_view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    m_view->setWindowTitle("Camera");
    m_view->rootContext()->setContextProperty("application", this);
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

void CameraApplication::onViewStatusChanged(QDeclarativeView::Status status)
{
    if (status != QDeclarativeView::Ready) {
        return;
    }

    QGraphicsObject *camera = m_view->rootObject();
    if (camera) {
        QObject::connect(camera, SIGNAL(applicationReady()), this, SLOT(onApplicationReady()));
    }
}

void CameraApplication::onApplicationReady()
{
    QObject::disconnect(QObject::sender(), SIGNAL(applicationReady()), this, SLOT(onApplicationReady()));
    m_applicationIsReady = true;
}
