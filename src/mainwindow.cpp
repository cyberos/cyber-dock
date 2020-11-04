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
{
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
    setScreen(qGuiApp->primaryScreen());
    setSource(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    resizeWindow();

    connect(this, &QQuickView::xChanged, this, &MainWindow::updatePosition);
    connect(this, &QQuickView::yChanged, this, &MainWindow::updatePosition);
    connect(m_appModel, &ApplicationModel::countChanged, this, &MainWindow::resizeWindow);
    connect(m_settings, &DockSettings::directionChanged, this, &MainWindow::resizeWindow);
    connect(m_settings, &DockSettings::iconSizeChanged, this, &MainWindow::resizeWindow);
    connect(m_resizeAnimation, &QVariantAnimation::valueChanged, this, &MainWindow::onResizeValueChanged);
    connect(m_resizeAnimation, &QVariantAnimation::finished, this, &MainWindow::updateViewStruts);
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

    const QRect screenGeometry = screen()->geometry();

    // Launcher and Trash
    int fixedItemCount = 2;

    int maxLength = (m_settings->direction() == DockSettings::Left) ? screenGeometry.height() - DockSettings::self()->statusBarHeight()
                                                                    : screenGeometry.width();
    int calcLength = m_settings->iconSize() * fixedItemCount;

    // Calculate the width to ensure that the window width
    // cannot be greater than the screen width.
    for (int i = 1; i <= m_appModel->rowCount(); ++i) {
        calcLength += m_settings->iconSize();

        // Has exceeded the screen width
        if (calcLength >= maxLength) {
            calcLength -= m_settings->iconSize();
            break;
        }
    }

    QSize newSize(0, 0);

    switch (m_settings->direction()) {
    case DockSettings::Left:
        newSize = QSize(m_settings->iconSize(), calcLength);
        break;
    case DockSettings::Bottom:
        newSize = QSize(calcLength, m_settings->iconSize());
        break;
    default:
        break;
    }

    setVisible(false);
    setMinimumSize(newSize);
    setMaximumSize(newSize);
    resize(newSize);
    setVisible(true);
    updatePosition();
    updateBlurRegion();
    updateViewStruts();

//    if (m_resizeAnimation->state() == QVariantAnimation::Running) {
//        m_resizeAnimation->stop();
//    }

//    // Set zoom in and zoom out the ease curve
//    if (newSize.width() > size().width()) {
//        m_resizeAnimation->setEasingCurve(QEasingCurve::InOutCubic);
//    } else {
//        m_resizeAnimation->setEasingCurve(QEasingCurve::InCubic);
//    }

//    // If the window size has not changed, there is no need to resize
//    if (this->size() != newSize) {
//        // Disable blur during resizing
//        XWindowInterface::instance()->enableBlurBehind(this, false);

//        // Start the resize animation
//        m_resizeAnimation->setDuration(250);
//        m_resizeAnimation->setStartValue(this->size());
//        m_resizeAnimation->setEndValue(newSize);
//        m_resizeAnimation->start();
//    }

    setVisible(true);
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
