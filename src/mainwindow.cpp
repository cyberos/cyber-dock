/*
 * Copyright (C) 2020 ~ 2021 CyberOS Team.
 *
 * Author:     rekols <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "mainwindow.h"
#include "iconthemeimageprovider.h"
#include "processprovider.h"
#include "volumemanager.h"
#include "battery.h"
#include "brightness.h"
#include "controlcenterdialog.h"
#include "statusnotifier/statusnotifiermodel.h"

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
    m_resizeAnimation->setDuration(250);
    m_resizeAnimation->setEasingCurve(QEasingCurve::InOutQuad);

    setDefaultAlphaBuffer(true);
    setColor(Qt::transparent);

    setFlags(Qt::FramelessWindowHint | Qt::WindowDoesNotAcceptFocus);
    KWindowSystem::setState(winId(), NET::SkipTaskbar | NET::SkipPager);
    KWindowSystem::setOnDesktop(winId(), NET::OnAllDesktops);
    KWindowSystem::setType(winId(), NET::Dock);

    qmlRegisterType<DockSettings>("org.cyber.Dock", 1, 0, "DockSettings");
    qmlRegisterType<VolumeManager>("org.cyber.Dock", 1, 0, "Volume");
    qmlRegisterType<Battery>("org.cyber.Dock", 1, 0, "Battery");
    qmlRegisterType<Brightness>("org.cyber.Dock", 1, 0, "Brightness");
    qmlRegisterType<ControlCenterDialog>("org.cyber.Dock", 1, 0, "ControlCenterDialog");
    qmlRegisterType<StatusNotifierModel>("org.cyber.Dock", 1, 0, "StatusNotifierModel");

    engine()->rootContext()->setContextProperty("appModel", m_appModel);
    engine()->rootContext()->setContextProperty("process", new ProcessProvider);
    engine()->rootContext()->setContextProperty("Settings", m_settings);
    engine()->rootContext()->setContextProperty("rootWindow", this);

    setResizeMode(QQuickView::SizeRootObjectToView);
    setClearBeforeRendering(true);
    setScreen(qApp->primaryScreen());
    setSource(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    resizeWindow();

    connect(qApp->primaryScreen(), &QScreen::virtualGeometryChanged, this, &MainWindow::resizeWindow, Qt::QueuedConnection);
    connect(qApp->primaryScreen(), &QScreen::geometryChanged, this, &MainWindow::resizeWindow, Qt::QueuedConnection);

    connect(m_appModel, &ApplicationModel::countChanged, this, &MainWindow::animationResizing);
    connect(m_settings, &DockSettings::directionChanged, this, &MainWindow::positionAnimationResizing);
    connect(m_settings, &DockSettings::iconSizeChanged, this, &MainWindow::animationResizing);

    connect(m_resizeAnimation, &QVariantAnimation::valueChanged, this, &MainWindow::onAnimationValueChanged);
    connect(m_resizeAnimation, &QVariantAnimation::finished, this, &MainWindow::updateViewStruts);
}

QRect MainWindow::windowRect() const
{
    const QRect screenGeometry = qApp->primaryScreen()->geometry();

    QSize newSize(0, 0);
    QPoint position(0, 0);

    switch (m_settings->direction()) {
    case DockSettings::Left:
        newSize = QSize(m_settings->iconSize(), screenGeometry.height() - m_settings->edgeMargins() * 2);
        position = { screenGeometry.x() + DockSettings::self()->edgeMargins() / 2,
                     (screenGeometry.height() - newSize.height()) / 2
                   };
        break;
    case DockSettings::Bottom:
        newSize = QSize(screenGeometry.width() - DockSettings::self()->edgeMargins() * 2, m_settings->iconSize());
        position = { (screenGeometry.width() - newSize.width()) / 2,
                     screenGeometry.y() + screenGeometry.height() - newSize.height()
                     - DockSettings::self()->edgeMargins() / 2
                   };
        break;
    default:
        break;
    }

    return QRect(position, newSize);
}

void MainWindow::resizeWindow()
{
    setGeometry(windowRect());
    updateBlurRegion();
    updateViewStruts();
    setVisible(true);
}

void MainWindow::animationResizing()
{
    m_resizeAnimation->setStartValue(this->geometry());
    m_resizeAnimation->setEndValue(windowRect());
    m_resizeAnimation->setDuration(250);
    m_resizeAnimation->start();
}

void MainWindow::positionAnimationResizing()
{
    const QRect screenGeometry = qApp->primaryScreen()->geometry();
    QRect rect = windowRect();

    switch (m_settings->direction()) {
    case DockSettings::Left:
        setGeometry(QRect(screenGeometry.x() - rect.width(), rect.y(), rect.width(), rect.height()));
        m_resizeAnimation->setStartValue(QRect(screenGeometry.x() - rect.width(), rect.y(), rect.width(), rect.height()));
        break;
    case DockSettings::Bottom:
        setGeometry(QRect(rect.x(), screenGeometry.height() + rect.height(), rect.width(), rect.height()));
        m_resizeAnimation->setStartValue(QRect(rect.x(), screenGeometry.height() + rect.height(), rect.width(), rect.height()));
        break;
    default:
        break;
    }

    m_resizeAnimation->setEndValue(windowRect());
    m_resizeAnimation->setDuration(300);
    m_resizeAnimation->start();
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
    QObject *mainObject = rootObject();
    if (mainObject)
        QMetaObject::invokeMethod(mainObject, "calcIconSize");

    XWindowInterface::instance()->setViewStruts(this, m_settings->direction(), geometry());
}

void MainWindow::onAnimationValueChanged(const QVariant &value)
{
    QRect geometry = value.toRect();
    setGeometry(geometry);
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
