#ifndef GHOSTWINDOW_H
#define GHOSTWINDOW_H

#include <QObject>
#include <QQuickView>
#include <QTimer>

class GhostWindow : public QQuickView
{
    Q_OBJECT

public:
    explicit GhostWindow(QQuickView *parent = nullptr);

    bool containsMouse() const;

    void updateGeometry();

signals:
    void containsMouseChanged(bool contains);
    void dragEntered();

protected:
    bool event(QEvent *e) override;

private:
    void setContainsMouse(bool contains);

private:
    bool m_delayedContainsMouse;
    bool m_containsMouse;

    QTimer m_delayedMouseTimer;
};

#endif // GHOSTWINDOW_H
