#include "vkapi.h"

VkApi* VkApi::instance;

VkApi::VkApi(QObject *parent) :
    QObject(parent),
	client(new QNetworkAccessManager),
	longPollServer(),
	longPollKey()
{
	instance = this;
	connect(client, SIGNAL(sslErrors(QNetworkReply*, QList<QSslError>)), SLOT(sslErrors(QNetworkReply*,QList<QSslError>)));
}

VkApiResponse* VkApi::makeQuery(const QString &method, const QVariantMap &params)
{
    qDebug() << "query " << method;
    QMapIterator<QString, QVariant> i(params);
    QString s;

    while (i.hasNext()) {
        i.next();
        QString encodedData = QString::fromLocal8Bit(QUrl::toPercentEncoding(i.value().toString()));
        s += QString("%1=%2&").arg(i.key()).arg(encodedData);
    }

	QUrl url(QString("https://api.vk.com/method/%1").arg(method));
	request.setUrl(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QByteArray data = s.append("access_token=").append(accessToken).toLocal8Bit();
//	qDebug() << data;
	QNetworkReply *reply = client->post(request, data);
    return new VkApiResponse(reply);
}

VkApiResponse* VkApi::connectToLongPollServer(const QString &server, const QString &key, const QString &ts)
{
    longPollServer = server;
    longPollKey = key;
	this->ts = ts;
	request.setUrl(QUrl(QString("https://%1?act=a_check&key=%2&ts=%3&wait=25&mode=2").arg(server).arg(key).arg(ts)));
	QNetworkReply *reply = client->get(request);
    return new VkApiResponse(reply);
}

QString VkApi::processResponse(QNetworkReply *reply)
{
	if (reply) {
		if (reply->error() != QNetworkReply::NoError) {
			emit errorReceived("Connection error: " + reply->errorString());
			throw std::exception();
		} else {
			QString data = QString().fromUtf8(reply->readAll());
//			qDebug() << "processResp " << data;

			if (getBefore(data, "\"") == "{\"error") {
				rmTo(data, "error_msg\":\"");
				errorReceived(getBefore(data, "\""));
			} else {
				int p = data.indexOf(",\"execute_errors\"");
				if (p > -1)
					data.remove(p, INT_MAX);
//				reply->deleteLater();
				return data;
			}
		}
	}

    return QString();
}

void VkApi::checkAuth()
{
	if (accessToken.isEmpty())
        needAuthorization();
}
