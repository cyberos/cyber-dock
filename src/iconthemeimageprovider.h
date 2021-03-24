#ifndef ICONTHEMEIMAGEPROVIDER_H
#define ICONTHEMEIMAGEPROVIDER_H

#include <QtQuick/QQuickImageProvider>
#include <QFile>

#define PIXMAP_PATH "/usr/share/pixmaps/"

class IconThemeImageProvider : public QQuickImageProvider
{
public:
    IconThemeImageProvider();

    QPixmap requestPixmap(const QString &id, QSize *realSize, const QSize &requestedSize);
};

#endif // ICONTHEMEIMAGEPROVIDER_H
