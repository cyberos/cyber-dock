#include "iconthemeimageprovider.h"
#include <QIcon>

IconThemeImageProvider::IconThemeImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap IconThemeImageProvider::requestPixmap(const QString &id, QSize *realSize,
                                              const QSize &requestedSize)
{
    // Sanitize requested size
    QSize size(requestedSize);
    if (size.width() < 1)
        size.setWidth(1);
    if (size.height() < 1)
        size.setHeight(1);

    // Return real size
    if (realSize)
        *realSize = size;

    // Is it a path?
    if (id.startsWith(QLatin1Char('/')))
        return QPixmap(id).scaled(size);

    // Return icon from theme or fallback to a generic icon
    QIcon icon = QIcon::fromTheme(id);
        if (icon.isNull()) {
        // Look for a fallback icon in /usr/share/pixmaps
        QStringList extensions = QStringList() << "png" << "svg" << "xpm";
        for (QString extension : extensions) {
            QFile file;
            QString path = QString(PIXMAP_PATH + id + "." + extension);
            file.setFileName(path);
            if (file.exists()) 
                return QPixmap(path).scaled(size);
        }
        // Use the default generic icon instead
        icon = QIcon::fromTheme(QLatin1String("application-x-desktop"));
    }

    return icon.pixmap(size);
}
