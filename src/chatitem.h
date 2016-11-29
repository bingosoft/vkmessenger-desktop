#ifndef CHATITEM_H
#define CHATITEM_H

#include <QtCore>

class ChatItem;
typedef QSharedPointer<ChatItem> ChatItemPtr;
typedef QMap<int, ChatItemPtr> ChatsMap;

#define DECLARE_PROPERTY(T, name)\
private:\
    T name;\
public:\
    T get_##name() const { return name; }\
    void set_##name(const T& value) { name = value; dataChanged(); }\

class ChatItem : public QObject
{
    Q_OBJECT

    friend class UsersManager;

    DECLARE_PROPERTY(int, id)
    DECLARE_PROPERTY(int, adminId)
    DECLARE_PROPERTY(QVariantList, users)
    DECLARE_PROPERTY(QString, title)
    DECLARE_PROPERTY(QString, avatar)
    DECLARE_PROPERTY(bool, selected)
    DECLARE_PROPERTY(bool, loaded)
    DECLARE_PROPERTY(bool, avatarLoaded)
    DECLARE_PROPERTY(int, unreadMessages)

    Q_PROPERTY(int id READ get_id)
    Q_PROPERTY(int adminId READ get_adminId)
    Q_PROPERTY(QVariantList users READ get_users)
    Q_PROPERTY(QString title READ get_title WRITE set_title NOTIFY dataChanged)
    Q_PROPERTY(QString avatar READ get_avatar WRITE set_avatar NOTIFY dataChanged)
    Q_PROPERTY(bool selected READ get_selected WRITE set_selected NOTIFY dataChanged)
    Q_PROPERTY(bool loaded READ get_loaded)
    Q_PROPERTY(bool avatarLoaded READ get_avatarLoaded WRITE set_avatarLoaded NOTIFY dataChanged)
    Q_PROPERTY(int unreadMessages READ get_unreadMessages WRITE set_unreadMessages NOTIFY dataChanged)

    volatile bool isLoadingAvatar;

public:
	ChatItem(int id = 0) :
		id(id),
		selected(),
        loaded(),
		avatarLoaded(),
		unreadMessages(),
        isLoadingAvatar()
	{

    }

signals:
    Q_INVOKABLE void dataChanged();
};

#endif // CHATITEM_H
