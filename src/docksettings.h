#ifndef DOCKSETTINGS_H
#define DOCKSETTINGS_H

#include <QObject>
#include <QSettings>
#include <QFileSystemWatcher>

class DockSettings : public QObject
{
    Q_OBJECT

public:
    enum Direction {
        Left = 0,
        Right,
        Bottom
    };

    static DockSettings *self();
    explicit DockSettings(QObject *parent = nullptr);

    void setDirection(Direction direction);

Q_SIGNALS:
    void directionChanged();

private:
    Direction m_direction;
    QSettings *m_settings;
    QFileSystemWatcher *m_fileWatcher;
};

#endif // DOCKSETTINGS_H
