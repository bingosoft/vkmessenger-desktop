#ifndef ROUNDIMAGEPROVIDER_H
#define ROUNDIMAGEPROVIDER_H

#include <QtDeclarative/QtDeclarative>
#include <QtCore>
#include <QtNetwork>
#include <QtGui>

class RoundImageProvider : public QDeclarativeImageProvider
{
    static QString cacheDir;
public:
    explicit RoundImageProvider();

    static QString getCacheDir() { return cacheDir; }
    ImageType imageType() const { return QDeclarativeImageProvider::Image; }
    static QString getFileName(int uid, QString url)
    {
        return QString("%1/id%2_%3").arg(cacheDir).arg(uid).arg(url.replace("http://", "").replace("/", "_").replace(".jpg", ".png").replace(".gif", ".png"));
    }

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // ROUNDIMAGEPROVIDER_H
