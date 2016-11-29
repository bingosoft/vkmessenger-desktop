#include "roundimageprovider.h"

#ifdef Q_OS_LINUX
    QString RoundImageProvider::cacheDir = "/tmp/vkmessenger";
#else
    cacheDir = "";
#endif

RoundImageProvider::RoundImageProvider() : 
    QDeclarativeImageProvider(QDeclarativeImageProvider::Image)
{
    if (!QDir(cacheDir).exists())
        QDir().mkpath(cacheDir);
}


QImage RoundImageProvider::requestImage(const QString &id, QSize *size, const QSize &)
{
    QStringList components = QUrl().fromPercentEncoding(id.toLatin1()).split("|");
    QString uid = components[0];
    QString url = components[1];
    QString fileName = getFileName(uid.toInt(), url);
    *size = QSize(50, 50);
    
    if (QFile(fileName).exists()) {
        return QImage(fileName);
    } else {
        return QImage(":/qml/images/deleted.png");
    }
}
