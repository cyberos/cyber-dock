#include "ghostwindow.h"
#include "docksettings.h"

#include <QApplication>
#include <QScreen>

GhostWindow::GhostWindow(QQuickView *parent)
    : QQuickView(parent)
    , m_delayedContainsMouse(false)
    , m_containsMouse(false)
{
    m_delayedMouseTimer.setSingleShot(true);
    m_delayedMouseTimer.setInterval(50);

    connect(&m_delayedMouseTimer, &QTimer::timeout, this, [this]() {
        if (m_delayedContainsMouse) {
            setContainsMouse(true);
        } else {
            setContainsMouse(false);
        }
    });

    setColor(Qt::red);
    // setColor(Qt::transparent);
    setDefaultAlphaBuffer(true);
    setFlags(Qt::FramelessWindowHint |
             Qt::WindowStaysOnTopHint |
             Qt::NoDropShadowWindowHint |
             Qt::WindowDoesNotAcceptFocus);
    setScreen(qApp->primaryScreen());
    updateGeometry();
    show();

    connect(DockSettings::self(), &DockSettings::directionChanged, this, &GhostWindow::updateGeometry);
}

bool GhostWindow::containsMouse() const
{
    return m_containsMouse;
}

void GhostWindow::updateGeometry()
{
    int length = 10;
    const QRect screenGeometry = qApp->primaryScreen()->geometry();
    QRect newGeometry;

    if (DockSettings::self()->direction() == DockSettings::Left) {
        newGeometry = QRect(screenGeometry.x() - (length * 2),
                            (screenGeometry.height() + length) / 2,
                            length, screenGeometry.height());
    } else {
        newGeometry = QRect(screenGeometry.x(),
                         screenGeometry.y() + screenGeometry.height() - length,
                         screenGeometry.width(), length);
    }

    setGeometry(newGeometry);
}

bool GhostWindow::event(QEvent *e)
{
    if (e->type() == QEvent::Enter) {
        m_delayedContainsMouse = true;
        if (!m_delayedMouseTimer.isActive()) {
            m_delayedMouseTimer.start();
        }
    } else if (e->type() == QEvent::DragEnter || e->type() == QEvent::DragMove) {
        if (!m_containsMouse) {
            m_delayedContainsMouse = false;
            m_delayedMouseTimer.stop();
            setContainsMouse(true);
            emit dragEntered();
        }
    } else if (e->type() == QEvent::Leave || e->type() == QEvent::DragLeave) {
        m_delayedContainsMouse = false;
        if (!m_delayedMouseTimer.isActive()) {
            m_delayedMouseTimer.start();
        }
    }

    return QQuickView::event(e);
}

void GhostWindow::setContainsMouse(bool contains)
{
    if (m_containsMouse == contains) {
        return;
    }

    qDebug() << "setContainsMouse: " << contains;

    m_containsMouse = contains;
    emit containsMouseChanged(contains);
}
