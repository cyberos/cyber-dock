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

public:
    enum Direction {
        Left = 0,
        Bottom
    };
    Q_ENUMS(Direction)

    enum Visibility {
        AlwaysVisible = 0,
        AutoHide
    };
    Q_ENUMS(Visibility)

    static DockSettings *self();
    explicit DockSettings(QObject *parent = nullptr);

    int iconSize() const;
    void setIconSize(int iconSize);

    Direction direction() const;
    void setDirection(const Direction &direction);

    Visibility visibility() const;
    void setVisibility(const Visibility &visibility);

    int edgeMargins() const;
    void setEdgeMargins(int edgeMargins);

    int statusBarHeight() const;
    void setStatusBarHeight(int statusBarHeight);

private slots:
    void onConfigFileChanged();

signals:
    void iconSizeChanged();
    void directionChanged();
    void visibilityChanged();

private:
    int m_iconSize;
    int m_edgeMargins;
    int m_statusBarHeight;

    Direction m_direction;
    Visibility m_visibility;
    QSettings *m_settings;
    QFileSystemWatcher *m_fileWatcher;
};

#endif // DOCKSETTINGS_H
