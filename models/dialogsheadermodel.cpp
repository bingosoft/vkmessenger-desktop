#include "dialogsheadermodel.h"

DialogsHeaderModel::DialogsHeaderModel(QObject *parent) :
    QAbstractListModel(parent)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
	setRoleNames(roleNames());
#endif
}

QHash<int, QByteArray> DialogsHeaderModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Id] = "id";
    roles[Name] = "name";
    roles[Online] = "online";
    roles[Avatar] = "avatar";
    roles[AvatarLoaded] = "avatarLoaded";
    roles[UnreadMessages] = "unreadMessages";
    roles[IsChat] = "isChat";
    return roles;
}

void DialogsHeaderModel::appendUser(int user_id)
{
    beginInsertRows(QModelIndex(), items.size(), items.size());
	UserItem *user = UsersManager::Get()->getUser(user_id);
	qDebug() << "appendUser " << user_id << " name " << user->get_name();
    items.append(user);
    connect(user, SIGNAL(dataChanged()), SLOT(itemDataChanged()));
    endInsertRows();
}

void DialogsHeaderModel::appendChat(int chatId, const QString &topic)
{
	qDebug() << "appendChat " << chatId << ", topic " << topic;
    beginInsertRows(QModelIndex(), items.size(), items.size());
	ChatItem *chat = UsersManager::Get()->getChat(chatId);
	if (!topic.isEmpty())
		chat->set_title(topic);
    items.append(chat);
    connect(chat, SIGNAL(dataChanged()), SLOT(itemDataChanged()));
    endInsertRows();
}


QVariant DialogsHeaderModel::data(const QModelIndex &index, int role) const
{
    int i = index.row();
    ChatItem *chat = dynamic_cast<ChatItem*>(items[i]);
    UserItem *user = dynamic_cast<UserItem*>(items[i]);

    if (chat) {
		switch ((Roles)role) {
		case Id:
			return chat->get_id();
		case Name:
			return chat->get_title();
		case Online:
			return false;
		case Avatar:
			return chat->get_avatar();
		case AvatarLoaded:
			return chat->get_avatarLoaded();
		case UnreadMessages:
			return chat->get_unreadMessages();
		case IsChat:
            return true;
		default:
			return QVariant();
		}
    }

    if (user) {
		switch ((Roles)role) {
		case Id:
			return user->get_user_id();
		case Name:
			return user->get_name();
		case Online:
			return user->get_online();
		case Avatar:
			return user->get_avatar();
		case AvatarLoaded:
			return user->get_avatarLoaded();
		case UnreadMessages:
			return user->get_unreadMessages();
		case IsChat:
            return false;
		default:
			return QVariant();
		}
    }
    return QVariant();
}

void DialogsHeaderModel::remove(int i)
{
    if (i < items.size()) {
        beginRemoveRows(QModelIndex(), i, i);
        items.remove(i);
        countChanged();
        endRemoveRows();
    }
}

void DialogsHeaderModel::itemDataChanged()
{
    for (int i = 0; i < items.size(); ++i) {
        if (items[i] == sender()) {
            dataChanged(index(i), index(i));
            return;
        }
    }
}

int DialogsHeaderModel::indexOf(int id)
{
    for (int i = 0; i < items.count(); ++i) {
        UserItem *user = dynamic_cast<UserItem*>(items[i]);
        if (user && user->get_user_id() == id) {
			qDebug() << "found user at index " << i;
            return i;
		}
        else if (!user) {
			ChatItem *chat = dynamic_cast<ChatItem*>(items[i]);
			if (chat && chat->get_id() == id) {
				qDebug() << "found chat at index " << i;
				return i;
			}
        }
    }

    return -1;
}

void DialogsHeaderModel::setHasUnreadMessages(int i, bool hasUnread)
{
	UserItem *user = dynamic_cast<UserItem*>(items[i]);
	if (user)
		user->set_unreadMessages(hasUnread ? (user->get_unreadMessages() + 1) : 0);
	ChatItem *chat = dynamic_cast<ChatItem*>(items[i]);
	if (chat)
		chat->set_unreadMessages(hasUnread ? (chat->get_unreadMessages() + 1) : 0);

	dataChanged(index(i), index(i));
}

bool DialogsHeaderModel::updateUnreadMessages(int currentIndex)
{
	bool hasUnreadMessages = false;

	for (int i = 0; i < items.count(); ++i) {
		ChatItem *chat = dynamic_cast<ChatItem *>(items[i]);

		if (chat && chat->get_unreadMessages() > 0) {
			if (i == currentIndex) {
				chat->set_unreadMessages(0);
				dataChanged(index(i), index(i));
			} else
				hasUnreadMessages = true;
		}

		UserItem *user = dynamic_cast<UserItem *>(items[i]);

		if (user && user->get_unreadMessages() > 0) {
			if (i == currentIndex) {
				user->set_unreadMessages(0);
				dataChanged(index(i), index(i));
			} else
				hasUnreadMessages = true;
		}
	}

	return hasUnreadMessages;
}
