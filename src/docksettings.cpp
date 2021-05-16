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

#include "docksettings.h"

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QDBusInterface>

#include <QFile>
#include <QDebug>

static DockSettings *SELF = nullptr;

DockSettings *DockSettings::self()
{
    if (SELF == nullptr)
        SELF = new DockSettings;

    return SELF;
}

DockSettings::DockSettings(QObject *parent)
    : QObject(parent)
    , m_iconSize(0)
    , m_edgeMargins(10)
    , m_statusBarHeight(30)
    , m_direction(Left)
    , m_dockTransparency(true)
    , m_settings(new QSettings(QSettings::UserScope, "cyberos", "dock"))
    , m_fileWatcher(new QFileSystemWatcher(this))
{
    if (!m_settings->contains("IconSize"))
        m_settings->setValue("IconSize", 64);
    if (!m_settings->contains("Direction"))
        m_settings->setValue("Direction", Bottom);
   	if (!m_settings->contains("DockTransparency"))
   		m_settings->setValue("DockTransparency", true);

    m_settings->sync();

    m_iconSize = m_settings->value("IconSize").toInt();
    m_direction = static_cast<Direction>(m_settings->value("Direction").toInt());
    m_dockTransparency = m_settings->value("DockTransparency").toBool();

    m_fileWatcher->addPath(m_settings->fileName());
    connect(m_fileWatcher, &QFileSystemWatcher::fileChanged, this, &DockSettings::onConfigFileChanged);
}

int DockSettings::iconSize() const
{
    return m_iconSize;
}

void DockSettings::setIconSize(int iconSize)
{
    m_iconSize = iconSize;
    emit iconSizeChanged();
}

DockSettings::Direction DockSettings::direction() const
{
    return m_direction;
}

void DockSettings::setDirection(const Direction &direction)
{
    m_direction = direction;
    emit directionChanged();
}

int DockSettings::edgeMargins() const
{
    return m_edgeMargins;
}

void DockSettings::setEdgeMargins(int edgeMargins)
{
    m_edgeMargins = edgeMargins;
}

int DockSettings::statusBarHeight() const
{
    return m_statusBarHeight;
}

void DockSettings::setStatusBarHeight(int statusBarHeight)
{
    m_statusBarHeight = statusBarHeight;
}

void DockSettings::onConfigFileChanged()
{
    if (!QFile(m_settings->fileName()).exists())
        return;

    m_settings->sync();

    int iconSize = m_settings->value("IconSize").toInt();
    Direction direction = static_cast<Direction>(m_settings->value("Direction").toInt());

    if (m_iconSize != iconSize)
        setIconSize(iconSize);

    if (m_direction != direction)
        setDirection(direction);

    m_fileWatcher->addPath(m_settings->fileName());
}

bool DockSettings::dockTransparency() const
{
	return m_dockTransparency;
}

void DockSettings::setDockTransparency(bool enabled)
{
	m_dockTransparency = enabled;
	emit dockTransparencyChanged();
}
