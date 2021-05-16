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

#ifndef DOCKSETTINGS_H
#define DOCKSETTINGS_H

#include <QObject>
#include <QSettings>
#include <QFileSystemWatcher>

class DockSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Direction direction READ direction WRITE setDirection NOTIFY directionChanged)
    Q_PROPERTY(int iconSize READ iconSize WRITE setIconSize NOTIFY iconSizeChanged)
    Q_PROPERTY(int edgeMargins READ edgeMargins WRITE setEdgeMargins)
    Q_PROPERTY(bool dockTransparency READ dockTransparency WRITE setDockTransparency NOTIFY dockTransparencyChanged)

public:
    enum Direction {
        Left = 0,
        Bottom
    };
    Q_ENUMS(Direction)

    static DockSettings *self();
    explicit DockSettings(QObject *parent = nullptr);

    int iconSize() const;
    void setIconSize(int iconSize);

    Direction direction() const;
    void setDirection(const Direction &direction);

    int edgeMargins() const;
    void setEdgeMargins(int edgeMargins);

    int statusBarHeight() const;
    void setStatusBarHeight(int statusBarHeight);
    
    bool dockTransparency() const;
    void setDockTransparency(bool enabled);

private slots:
    void onConfigFileChanged();

signals:
    void iconSizeChanged();
    void directionChanged();
    void dockTransparencyChanged();

private:
    int m_iconSize;
    int m_edgeMargins;
    int m_statusBarHeight;
    Direction m_direction;
    bool m_dockTransparency;
    QSettings *m_settings;
    QFileSystemWatcher *m_fileWatcher;
};

#endif // DOCKSETTINGS_H
