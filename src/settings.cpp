#include "settings.h"

Settings::Settings(QObject *parent) : QObject(parent)
{
    settings = new QSettings(QSettings::IniFormat, QSettings::UserScope, "Bingo's Soft", "VkMessenger");
}

Settings* Settings::shared()
{
	static Settings instance;
	return &instance;
}

QVariant Settings::value(const QString &key, const QVariant &defaultValue) const
{
	return settings->value(key, defaultValue);
}

void Settings::setValue(const QString &key, const QVariant &value)
{
	settings->setValue(key, value);
}
