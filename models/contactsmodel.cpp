#include "contactsmodel.h"

ContactsModel::ContactsModel(QObject *parent) :
    QAbstractListModel(parent)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
	setRoleNames(roleNames());
#endif
}

QHash<int, QByteArray> ContactsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Id] = "uid";
    roles[Name] = "name";
    roles[Status] = "status";
    roles[Online] = "online";
    roles[Avatar] = "avatar";
    roles[AvatarLoaded] = "avatarLoaded";
    roles[Selected] = "selected";
    roles[LastSeen] = "lastSeen";
    roles[UnreadMessages] = "unreadMessages";
    return roles;
}

int ContactsModel::findContact(int uid) const
{
    UidsVector::ConstIterator it = qFind(items.begin(), items.end(), uid);

    if (it == items.end())
        return -1;

    return it - items.begin();
}

void ContactsModel::append(int uid)
{
    beginInsertRows(QModelIndex(), items.size(), items.size());
    items.append(uid);
	UserItem *user = UsersManager::Get()->getUser(uid);
	user->set_isFriend(true);
    connect(user, SIGNAL(dataChanged()), SLOT(itemDataChanged()));
    endInsertRows();
}

QVariant ContactsModel::data(const QModelIndex &index, int role) const
{
    int i = index.row();
    UserItem* user = UsersManager::Get()->getUser(items[i]);

    switch ((Roles)role) {
    case Id:
        return user->get_uid();
    case Name:
        return user->get_name();
    case Status:
        return user->get_status();
    case Online:
        return user->get_online();
    case Avatar:
        return user->get_avatar();
    case Selected:
        return user->get_selected();
    case AvatarLoaded:
        return user->get_avatarLoaded();
    case UnreadMessages:
        return user->get_unreadMessages();
    case LastSeen: {
        QDateTime lastSeen = user->get_lastSeen();
        if (lastSeen.toTime_t() == 0)
            return "";
        QString s = lastSeen.toString("hh:mm");
        QDateTime now = QDateTime::currentDateTime();

        if (lastSeen.daysTo(now) > 365)
            s += lastSeen.toString(", dd MMM yyyy");
        else if (lastSeen.daysTo(now) > 0)
            s += lastSeen.toString(", dd MMM");

        return s;
    }
    default:
        return QVariant();
    }
    return QVariant();
}

void ContactsModel::load(const QVariantList &data)
{
    QSet<int> currentContacts;

    for (int i = 0; i < items.size(); ++i)
        currentContacts << items[i];

    for (int i = 0; i < data.size(); ++i) {
        int uid = data[i].toInt();
        int ind = findContact(uid);

        if (ind == -1)
            append(uid);

        currentContacts.remove(uid);
    }

    foreach (int uid, currentContacts) {
        qDebug() << "user " << uid << " was deleted from friends";
		UserItem *user = UsersManager::Get()->getUser(uid);
		user->set_isFriend(false);
        int i = findContact(uid);
        if (i != -1) {
            beginRemoveRows(QModelIndex(), i, i);
            items.remove(i);
            countChanged();
            endRemoveRows();
        } else {
            qDebug() << "user not found";
        }
    }
}

void ContactsModel::remove(int i)
{
    if (i < items.size()) {
        beginRemoveRows(QModelIndex(), i, i);
        items.remove(i);
        countChanged();
        endRemoveRows();
    }
}

void ContactsModel::itemDataChanged()
{
    for (int i = 0; i < items.size(); ++i) {
        if (UsersManager::Get()->getUser(items[i]) == sender()) {
            dataChanged(index(i), index(i));
            return;
        }
    }
}

UserItem* ContactsModel::get(int i) const
{
    return UsersManager::Get()->getUser(items[i]);
}
