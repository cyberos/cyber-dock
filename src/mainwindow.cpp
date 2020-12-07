#include "mainwindow.h"
#include "iconthemeimageprovider.h"
#include "processprovider.h"

#include <QGuiApplication>
#include <QScreen>
#include <QAction>
#include <QPainter>
#include <QImage>
#include <QRegion>

#include <QQmlContext>
#include <QQmlProperty>
#include <QQuickItem>
#include <QMetaEnum>

#include <NETWM>
#include <KWindowSystem>

MainWindow::MainWindow(QQuickView *parent)
    : QQuickView(parent)
    , m_settings(DockSettings::self())
    , m_appModel(new ApplicationModel)
    , m_resizeAnimation(new QVariantAnimation(this))
    , m_ghostWindow(new GhostWindow)
{
    m_resizeAnimation->setDuration(250);
    m_resizeAnimation->setEasingCurve(QEasingCurve::InOutQuad);

    setDefaultAlphaBuffer(true);
    setColor(Qt::transparent);

    setFlags(Qt::FramelessWindowHint | Qt::WindowDoesNotAcceptFocus);
    KWindowSystem::setState(winId(), NET::SkipTaskbar | NET::SkipPager);
    KWindowSystem::setOnDesktop(winId(), NET::OnAllDesktops);
    KWindowSystem::setType(winId(), NET::Dock);

    qmlRegisterType<DockSettings>("org.cyber.Dock", 1, 0, "DockSettings");
    engine()->rootContext()->setContextProperty("appModel", m_appModel);
    engine()->rootContext()->setContextProperty("process", new ProcessProvider);
    engine()->rootContext()->setContextProperty("Settings", m_settings);

    setResizeMode(QQuickView::SizeRootObjectToView);
    setClearBeforeRendering(true);
    setScreen(qApp->primaryScreen());
    setSource(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    resizeWindow();

    connect(qApp->primaryScreen(), &QScreen::geometryChanged, this, &MainWindow::resizeWindow);

    connect(this, &QQuickView::xChanged, this, &MainWindow::updatePosition);
    connect(this, &QQuickView::yChanged, this, &MainWindow::updatePosition);
    connect(m_appModel, &ApplicationModel::countChanged, this, &MainWindow::resizeWindow);
    connect(m_settings, &DockSettings::directionChanged, this, &MainWindow::resizeWindow);
    connect(m_settings, &DockSettings::iconSizeChanged, this, &MainWindow::resizeWindow);
    connect(m_resizeAnimation, &QVariantAnimation::valueChanged, this, &MainWindow::onResizeValueChanged);
    connect(m_resizeAnimation, &QVariantAnimation::finished, this, &MainWindow::updateViewStruts);

    m_hideWindowTimer.setInterval(2000);
    m_hideWindowTimer.setSingleShot(true);
    connect(&m_hideWindowTimer, &QTimer::timeout, this, [=] { setVisible(false); });

    connect(m_ghostWindow, &GhostWindow::containsMouseChanged, this, [=] (bool containsMouse) {
        if (containsMouse) {
            setVisible(true);
        }
    });
}

bool MainWindow::event(QEvent *e)
{
    if (e->type() == QEvent::Leave && m_settings->visibility() == DockSettings::AutoHide) {
        m_hideWindowTimer.start();
    }

    return QQuickView::event(e);
}

void MainWindow::updatePosition()
{
    const QRect screenGeometry = screen()->geometry();
    QPoint position = {0, 0};

    switch (m_settings->direction()) {
    case DockSettings::Left: {
        position = { screenGeometry.x() + DockSettings::self()->edgeMargins() / 2, screenGeometry.y() };
        position.setY((screenGeometry.height() + DockSettings::self()->statusBarHeight() - geometry().height()) / 2);
        break;
    }
    case DockSettings::Bottom: {
        position = { screenGeometry.x(), screenGeometry.y() +
                                         screenGeometry.height() -
                                         height() - DockSettings::self()->edgeMargins() / 2 };
        position.setX((screenGeometry.width() - geometry().width()) / 2);
        break;
    }
    default:
        break;
    }

    setX(position.x());
    setY(position.y());
}

void MainWindow::resizeWindow()
{
    // Change the window size means that the number of dock items changes
    // Need to hide popup tips.
    // m_popupTips->hide();

    const QRect screenGeometry = qApp->primaryScreen()->geometry();

    // Launcher and Trash
    const int fixedItemCount = 2;

    const int maxLength = (m_settings->direction() == DockSettings::Left) ?
                           screenGeometry.height() - DockSettings::self()->statusBarHeight() - m_settings->edgeMargins() :
                           screenGeometry.width() - m_settings->edgeMargins();
    int calcIconSize = m_settings->iconSize();
    int allCount = m_appModel->rowCount() + fixedItemCount;
    int calcLength = allCount * calcIconSize;

    // Cannot be greater than the screen length.
    while (1) {
        if (calcLength < maxLength)
            break;

        calcIconSize -= 1;
        calcLength = allCount * calcIconSize;
    }

    QSize newSize(0, 0);

    switch (m_settings->direction()) {
    case DockSettings::Left:
        newSize = QSize(calcIconSize, calcLength);
        break;
    case DockSettings::Bottom:
        newSize = QSize(calcLength, calcIconSize);
        break;
    default:
        break;
    }

    // Start the resize animation
    m_resizeAnimation->setStartValue(this->size());
    m_resizeAnimation->setEndValue(newSize);
    m_resizeAnimation->start();

    if (m_settings->visibility() == DockSettings::AutoHide) {
        setVisible(false);
    } else {
        setVisible(true);
    }

}

void MainWindow::updateBlurRegion()
{
    const QRect rect { 0, 0, size().width(), size().height() };
    int radius = m_settings->direction() == DockSettings::Left ? rect.width() * 0.3
                                                               : rect.height() * 0.3;
    XWindowInterface::instance()->enableBlurBehind(this, true, cornerMask(rect, radius));
}

void MainWindow::updateViewStruts()
{
    if (m_settings->visibility() == DockSettings::AutoHide) {
        return;
    }

    XWindowInterface::instance()->setViewStruts(this, m_settings->direction(), geometry());
}

void MainWindow::onResizeValueChanged(const QVariant &value)
{
    const QSize &s = value.toSize();
    setMinimumSize(s);
    setMaximumSize(s);
    resize(s);
    updatePosition();
    updateBlurRegion();
}

QRegion MainWindow::cornerMask(const QRect &rect, const int r)
{
    QRegion region;
    // middle and borders
    region += rect.adjusted(r, 0, -r, 0);
    region += rect.adjusted(0, r, 0, -r);

    // top left
    QRect corner(rect.topLeft(), QSize(r * 2, r * 2));
    region += QRegion(corner, QRegion::Ellipse);

    // top right
    corner.moveTopRight(rect.topRight());
    region += QRegion(corner, QRegion::Ellipse);

    // bottom left
    corner.moveBottomLeft(rect.bottomLeft());
    region += QRegion(corner, QRegion::Ellipse);

    // bottom right
    corner.moveBottomRight(rect.bottomRight());
    region += QRegion(corner, QRegion::Ellipse);

    return region;
}
