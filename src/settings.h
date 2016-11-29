#ifndef SETTINGS_H
#define SETTINGS_H

#include <QtCore/QtCore>

class Settings : public QObject
{
    Q_OBJECT

    QSettings *settings;
public:
    explicit Settings(QObject *parent = 0);

    static Settings* shared();
	Q_INVOKABLE void sync() const { settings->sync(); }
	Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;
	Q_INVOKABLE void setValue(const QString &key, const QVariant &value);

signals:

public slots:
};

#endif // SETTINGS_H