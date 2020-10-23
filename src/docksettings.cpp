#include "docksettings.h"

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QDBusInterface>

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
    , m_direction(Bottom)
    , m_settings(new QSettings(QSettings::UserScope, "cyberos", "dock"))
    , m_fileWatcher(new QFileSystemWatcher(this))
{
}

void DockSettings::setDirection(Direction direction)
{
    if (m_direction != direction) {
        m_direction = direction;
        emit directionChanged();
    }
}
