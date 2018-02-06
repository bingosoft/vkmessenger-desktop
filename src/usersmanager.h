#ifndef USERSMANAGER_H
#define USERSMANAGER_H

#include <QtCore>
#include <QtGui>
#include <QtScript>
#include "api/vkapi.h"
#include "roundimageprovider.h"
#include "useritem.h"
#include "chatitem.h"

class UserItem;

class UsersManager : public QObject
{
    Q_OBJECT

    QNetworkAccessManager *manager;
    UsersMap users;
    ChatsMap chats;
    VkApiResponse *usersResponse;
    VkApiResponse *chatsResponse;

    int userLoadTimerId;
    int updateNotFriendsTimerId;
    QMutex m;

    static const int threadsCount = 10;
    volatile int activeThreads;

public:
    explicit UsersManager(QObject *parent = 0);

    static UsersManager* Get() { static UsersManager instance; return &instance; }
    Q_INVOKABLE UserItem* getUser(int user_id);
    Q_INVOKABLE ChatItem* getChat(int chatId);

private:
	void loadAvatars();
	void loadUsers();
	void loadUsersNotInFriends();

signals:
    void userDataChanged(int user_id);
    void chatDataChanged(int chatId);

private slots:
    void usersLoaded(QString data);
	void chatsLoaded(QString data);
    void usersNotInFriendsLoaded(QString data);
    void avatarReceived();
    void onUserDataChanged();

private:
    void timerEvent(QTimerEvent *);
};

#endif // USERSMANAGER_H
