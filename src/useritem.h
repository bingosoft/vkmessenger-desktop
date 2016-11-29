#ifndef USERITEM_H
#define USERITEM_H

#include <QtCore>

class UserItem;
typedef QSharedPointer<UserItem> UserItemPtr;
typedef QMap<int, UserItemPtr> UsersMap;

#define DECLARE_PROPERTY(T, name)\
private:\
    T name;\
public:\
    T get_##name() const { return name; }\
    void set_##name(const T& value) { name = value; dataChanged(); }\

class UserItem : public QObject
{
    Q_OBJECT

    friend class UsersManager;

    DECLARE_PROPERTY(int, uid)
    DECLARE_PROPERTY(QString, name)
    DECLARE_PROPERTY(QString, status)
    DECLARE_PROPERTY(bool, isFriend)
    DECLARE_PROPERTY(bool, online)
    DECLARE_PROPERTY(bool, loaded)
    DECLARE_PROPERTY(QString, avatar)
    DECLARE_PROPERTY(bool, selected)
    DECLARE_PROPERTY(bool, avatarLoaded)
    DECLARE_PROPERTY(int, unreadMessages)
    DECLARE_PROPERTY(QDateTime, lastSeen)

    Q_PROPERTY(int uid READ get_uid WRITE set_uid NOTIFY dataChanged)
    Q_PROPERTY(QString name READ get_name WRITE set_name NOTIFY dataChanged)
    Q_PROPERTY(QString status READ get_status WRITE set_status NOTIFY dataChanged)
    Q_PROPERTY(bool isFriend READ get_isFriend WRITE set_isFriend NOTIFY dataChanged)
    Q_PROPERTY(bool online READ get_online WRITE setOnline NOTIFY dataChanged)
    Q_PROPERTY(QString avatar READ get_avatar WRITE set_avatar NOTIFY dataChanged)
    Q_PROPERTY(bool loaded READ get_loaded)
    Q_PROPERTY(bool selected READ get_selected WRITE set_selected NOTIFY dataChanged)
    Q_PROPERTY(QDateTime lastSeen READ get_lastSeen WRITE set_lastSeen NOTIFY dataChanged)
    Q_PROPERTY(bool avatarLoaded READ get_avatarLoaded WRITE set_avatarLoaded NOTIFY dataChanged)
    Q_PROPERTY(int unreadMessages READ get_unreadMessages WRITE set_unreadMessages NOTIFY dataChanged)

    volatile bool isLoadingAvatar;

public:
	UserItem(int uid = 0) :
		uid(uid),
		online(),
        loaded(),
		selected(),
		avatarLoaded(),
		unreadMessages(),
        isLoadingAvatar()
	{

    }

private:
	void setOnline(bool value)
	{
		if (value == online)
			return;

		online = value;

		if (!online)
			lastSeen = QDateTime::currentDateTime();

		dataChanged();
	}

signals:
    Q_INVOKABLE void dataChanged();
};



#endif // USERITEM_H
