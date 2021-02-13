#ifndef CONTROLCENTERDIALOG_H
#define CONTROLCENTERDIALOG_H

#include <QQuickView>
#include <QTimer>

class ControlCenterDialog : public QQuickView
{
    Q_OBJECT

public:
    ControlCenterDialog(QQuickView *view = nullptr);

    Q_INVOKABLE void updateBlur();

protected:
    void showEvent(QShowEvent *event) override;
    void hideEvent(QHideEvent *event) override;
};

#endif // CONTROLCENTERDIALOG_H
