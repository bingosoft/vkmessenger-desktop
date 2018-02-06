#include "usersmanager.h"

UsersManager::UsersManager(QObject *parent) :
    QObject(parent),
    manager(new QNetworkAccessManager),
    usersResponse(),
    chatsResponse(),
    userLoadTimerId(),
    activeThreads()
{
	updateNotFriendsTimerId = startTimer(10000);
}

UserItem* UsersManager::getUser(int user_id)
{
    if (user_id == 0) {
		qDebug() << "getting user id0";
        return 0;
    }
    QMutexLocker l(&m);
    UsersMap::ConstIterator it = users.find(user_id);

    if (it == users.end()) {
        users[user_id] = UserItemPtr(new UserItem(user_id));
		connect(users[user_id].data(), SIGNAL(dataChanged()), SLOT(onUserDataChanged()));
        if (userLoadTimerId == 0)
            userLoadTimerId = startTimer(50);
    }

    return users[user_id].data();
}

ChatItem* UsersManager::getChat(int chatId)
{
    QMutexLocker l(&m);
    ChatsMap::ConstIterator it = chats.find(chatId);

    if (it == chats.end()) {
        chats[chatId] = ChatItemPtr(new ChatItem(chatId));

        if (userLoadTimerId == 0)
            userLoadTimerId = startTimer(50);
    }

    return chats[chatId].data();
}

void UsersManager::timerEvent(QTimerEvent *timerEvent)
{
    if (timerEvent->timerId() == userLoadTimerId)
		loadUsers();
	else if (timerEvent->timerId() == updateNotFriendsTimerId)
		loadUsersNotInFriends();
}

void UsersManager::loadUsers()
{
	bool canKillTimer = false;

	if (!usersResponse) {
		QString user_ids;

		foreach(UserItemPtr user, users) {
			if (!user->loaded)
				user_ids += (user_ids.isEmpty() ? "" : ",") + QString().setNum(user->user_id);
		}

        if (!user_ids.isEmpty()) {
			QVariantMap params;
			params["user_ids"] = user_ids;
			params["fields"] = "photo_50,status,online,screen_name,last_seen";

			qDebug() << "getting users " << user_ids;
			usersResponse = VkApi::Get()->makeQuery("users.get", params);
			connect(usersResponse, SIGNAL(completed(QString)), SLOT(usersLoaded(QString)));
        } else {
			canKillTimer = true;
		}
	}
	if (!chatsResponse) {
		QString chatIds;

		foreach(ChatItemPtr chat, chats) {
			if (!chat->loaded)
				chatIds += (chatIds.isEmpty() ? "" : ",") + QString().setNum(chat->id - 2000000000);
		}

        if (!chatIds.isEmpty()) {
			canKillTimer = false;
			QVariantMap params;
			qDebug() << "chats " << chatIds;
			params["chat_ids"] = chatIds;
			params["fields"] = "photo_50";

			chatsResponse = VkApi::Get()->makeQuery("messages.getChat", params);
			connect(chatsResponse, SIGNAL(completed(QString)), SLOT(chatsLoaded(QString)));
        } else {
			canKillTimer &= true;
		}

	}

	if (canKillTimer) {
		killTimer(userLoadTimerId);
		userLoadTimerId = 0;
	}
}

void UsersManager::loadUsersNotInFriends()
{
	QString user_ids;

	foreach(UserItemPtr user, users) {
		if (!user->isFriend)
			user_ids += (user_ids.isEmpty() ? "" : ",") + QString().setNum(user->user_id);
	}

    if (!user_ids.isEmpty()) {
		QVariantMap params;
		params["user_ids"] = user_ids;
		params["fields"] = "online,last_seen";

		VkApiResponse *resp = VkApi::Get()->makeQuery("users.get", params);
		connect(resp, SIGNAL(completed(QString)), SLOT(usersNotInFriendsLoaded(QString)));
	}
}

void UsersManager::loadAvatars()
{
	if (activeThreads >= threadsCount)
        return;

	foreach(UserItemPtr user, users) {
		if (user->loaded && !user->avatarLoaded && !user->isLoadingAvatar) {
			QNetworkReply *reply = manager->get(QNetworkRequest(QUrl(user->avatar)));
			user->isLoadingAvatar = true;
			qDebug() << "loading avatar " << user->avatar << " for id" << user->user_id;
			reply->setProperty("user_id", user->user_id);
			connect(reply, SIGNAL(finished()), SLOT(avatarReceived()), Qt::QueuedConnection);
			activeThreads++;

			if (activeThreads >= threadsCount)
				return;
		}
	}

	foreach(ChatItemPtr chat, chats) {
		if (chat->loaded && !chat->avatarLoaded && !chat->isLoadingAvatar) {
			QNetworkReply *reply = manager->get(QNetworkRequest(QUrl(chat->avatar)));
			chat->isLoadingAvatar = true;
			qDebug() << "loading avatar " << chat->avatar << " for chatId" << chat->id;
			reply->setProperty("chatId", chat->id);
			connect(reply, SIGNAL(finished()), SLOT(avatarReceived()), Qt::QueuedConnection);
			activeThreads++;

			if (activeThreads >= threadsCount)
				return;
		}
	}
}

void UsersManager::avatarReceived()
{
    qDebug() << "avatar received";
    QNetworkReply *reply = dynamic_cast<QNetworkReply *>(sender());

    if (reply->error() == QNetworkReply::NoError) {
		int id = !reply->property("user_id").isNull() ? reply->property("user_id").toInt() : reply->property("chatId").toInt();

		QImage image = QImage::fromData(reply->readAll());
		QImage out(50, 50, QImage::Format_ARGB32);
		out.fill(Qt::transparent);

		QBrush brush(image.scaled(QSize(50, 50), Qt::KeepAspectRatio, Qt::SmoothTransformation));

		QPen pen;
		pen.setColor(Qt::transparent);
		pen.setJoinStyle(Qt::RoundJoin);

		QPainter painter(&out);
		painter.setRenderHint(QPainter::Antialiasing, true);
		painter.setBrush(brush);
		painter.setPen(pen);
		painter.drawRoundedRect(QRect(0, 0, 50, 50), 8, 8);
		QFile::remove(QString("%1/id%2_*").arg(RoundImageProvider::getCacheDir()).arg(id));

		if (!reply->property("user_id").isNull()) {
			UserItem *user = getUser(reply->property("user_id").toInt());
			out.save(RoundImageProvider::getFileName(user->user_id, user->avatar), "PNG");
			user->isLoadingAvatar = false;
			user->avatarLoaded = true;
			user->dataChanged();
			userDataChanged(user->user_id);
			qDebug() << "received avatar for " << user->user_id;
		}

		if (!reply->property("chatId").isNull()) {
			ChatItem *chat = getChat(reply->property("chatId").toInt());
			out.save(RoundImageProvider::getFileName(chat->id, chat->avatar), "PNG");
			chat->isLoadingAvatar = false;
			chat->avatarLoaded = true;
			chat->dataChanged();
			chatDataChanged(chat->id);
			qDebug() << "received avatar for chat " << chat->id;
		}
    }
    activeThreads--;
    reply->deleteLater();
    loadAvatars();
}

void UsersManager::usersLoaded(QString data)
{
    usersResponse = 0;
    data.remove(0, 12);
    data.remove(data.size() - 1, 1);
    QScriptEngine engine;
    QScriptValue sc = engine.evaluate(data);

    if (!sc.isValid()) {
        qDebug() << "script is not valid";
        return;
    }

    QScriptValueIterator it(sc);
    while (it.hasNext()) {
        it.next();
        QScriptValue v = it.value();
        int user_id = v.property("id").toInteger();

        if (user_id == 0)
            continue;

        UserItemPtr user = users[user_id];

        user->name = v.property("first_name").toString() + " " + v.property("last_name").toString();
        user->avatar = v.property("photo_50").toString();
        if (user->avatar.isEmpty())
            qDebug() << "EMPTY AVATAR FOR " << user->user_id;
        user->online = v.property("online").toBool();
        user->status = v.property("status").toString();
        user->lastSeen = QDateTime::fromTime_t(v.property("last_seen").property("time").toInteger());
        user->avatarLoaded = QFile(RoundImageProvider::getFileName(user->user_id, user->avatar)).exists();
        user->loaded = true;
        user->dataChanged();
    }

    loadAvatars();
}

void UsersManager::chatsLoaded(QString data)
{
    chatsResponse = 0;
    qDebug() << data;
    data.remove(0, 12);
    data.remove(data.size() - 1, 1);
    qDebug() << "chats received";
    QScriptEngine engine;

    QScriptValue sc = engine.evaluate(data);

    if (!sc.isValid()) {
        qDebug() << "script is not valid";
        return;
    }

    QScriptValueIterator it(sc);
    while (it.hasNext()) {
        it.next();
        QScriptValue v = it.value();
        int chatId = v.property("id").toInteger();

        if (chatId == 0)
            continue;

        chatId += 2000000000;

        ChatItemPtr chat = chats[chatId];
		chat->adminId = v.property("admin_id").toInteger();
        chat->title = v.property("title").toString();
        chat->avatar = v.property("photo_50").toString();
        chat->avatarLoaded = QFile(RoundImageProvider::getFileName(chat->id, chat->avatar)).exists();
        chat->loaded = true;
        chat->dataChanged();

        QVariantList users = v.property("users").toVariant().toList();

        foreach (QVariant v, users) {
			chat->users.append(v.toMap()["id"].toInt());
            qDebug() << "chat user user_id " << v.toMap()["id"].toInt();
		}

        chatDataChanged(chat->id);
    }

    loadAvatars();
}

void UsersManager::usersNotInFriendsLoaded(QString data)
{
//    qDebug() << "users not in friends received";
    data.remove(0, 12);
    data.remove(data.size() - 1, 1);
    QScriptEngine engine;
    QScriptValue sc = engine.evaluate(data);

    if (!sc.isValid()) {
        qDebug() << "script is not valid";
        return;
    }

    QScriptValueIterator it(sc);
    while (it.hasNext()) {
        it.next();
        QScriptValue v = it.value();
        int user_id = v.property("user_id").toInteger();

        if (user_id == 0)
            continue;

        UserItemPtr user = users[user_id];
        if (v.property("online").toBool() != user->online) {
			user->online = v.property("online").toBool();
			user->lastSeen = QDateTime::fromTime_t(v.property("last_seen").property("time").toInteger());
			user->dataChanged();
        }
    }
}

void UsersManager::onUserDataChanged()
{
	foreach(UserItemPtr user, users) {
        if (user.data() == sender()) {
            userDataChanged(user->user_id);
            return;
        }
	}
}
