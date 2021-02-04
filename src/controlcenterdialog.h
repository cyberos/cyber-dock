#ifndef CONTROLCENTERDIALOG_H
#define CONTROLCENTERDIALOG_H

#include <QQuickView>

class ControlCenterDialog : public QQuickView
{
    Q_OBJECT

public:
    ControlCenterDialog(QQuickView *view = nullptr);

protected:
    void showEvent(QShowEvent *event) override;
};

#endif // CONTROLCENTERDIALOG_H
