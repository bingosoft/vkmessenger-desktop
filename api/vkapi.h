#ifndef VKAPI_H
#define VKAPI_H

#include <QtCore>
#include <QtNetwork>

class VkApiResponse;

class VkApi : public QObject
{
    Q_OBJECT

	Q_PROPERTY(QString accessToken READ getAccessToken WRITE setAccessToken NOTIFY authorized)
	QNetworkAccessManager *client;
	QNetworkRequest request;
	QString accessToken;
	QString appId;
	QString privileges;
	QString longPollServer;
	QString longPollKey;
	QString ts;

    void rmTo(QString &str, const QString &substr) { str = str.remove(0, str.indexOf(substr) + substr.length()); }
    QString getBefore(const QString &str, const QString &substr) { return str.left(str.indexOf(substr)); }

	static VkApi *instance;
public:
    explicit VkApi(QObject *parent = 0);

	const QString& getAccessToken() const { return accessToken; }
	Q_INVOKABLE bool isAuthorized() const { return !accessToken.isEmpty(); }
	Q_INVOKABLE void disconnect() { disconnected(); }
    Q_INVOKABLE VkApiResponse* makeQuery(const QString &method, const QVariantMap &params = QVariantMap());
    Q_INVOKABLE VkApiResponse* connectToLongPollServer(const QString &server, const QString &key, const QString &ts);
    Q_INVOKABLE VkApiResponse* connectToLongPollServer(const QString &ts) { return connectToLongPollServer(longPollServer, longPollKey, ts); }
    Q_INVOKABLE VkApiResponse* connectToLongPollServer() { return connectToLongPollServer(longPollServer, longPollKey, ts); }
    Q_INVOKABLE void checkAuth();

	static VkApi* Get() { return instance; }

signals:
	void errorReceived(QString error);
    void authorized();
    void needAuthorization();
    void disconnected();

private slots:
	void sslErrors(QNetworkReply *reply, QList<QSslError>) { reply->ignoreSslErrors(); }

public slots:
	void setAccessToken(const QString &value)
    {
        accessToken = value;

        if (!value.isEmpty())
            authorized();
    }

	QString processResponse(QNetworkReply *reply);
};

class VkApiResponse : public QObject
{
    Q_OBJECT

    QNetworkReply *reply;
public:
    VkApiResponse() : reply(0) { }
    VkApiResponse(QNetworkReply *reply) : reply(reply)
    {
        connect(reply, SIGNAL(finished()), SLOT(onRequestCompleted()));
    }

    Q_INVOKABLE void destroy()
    {
        reply->abort();
        reply->deleteLater();
        this->deleteLater();
    }

signals:
    void completed(const QString &data);
    void error();

private slots:
    void onRequestCompleted()
    {
        try {
            completed(VkApi::Get()->processResponse(reply));
        }
        catch (const std::exception &) {
			error();
		}
        reply->deleteLater();
        this->deleteLater();
    }
};

#endif // VKAPI_H
