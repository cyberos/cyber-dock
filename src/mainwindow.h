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

#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QQuickView>
#include <QVariantAnimation>
#include <QTimer>

#include "docksettings.h"
#include "applicationmodel.h"

class MainWindow : public QQuickView
{
    Q_OBJECT

public:
    explicit MainWindow(QQuickView *parent = nullptr);

private:
    QRect windowRect() const;

    void resizeWindow();
    void animationResizing();
    void positionAnimationResizing();
    void updateBlurRegion();
    void updateViewStruts();
    void onAnimationValueChanged(const QVariant &value);

    QRegion cornerMask(const QRect &rect, const int r);

private:
    DockSettings *m_settings;
    ApplicationModel *m_appModel;
    QVariantAnimation *m_resizeAnimation;
};

#endif // MAINWINDOW_H
