#ifndef DialogsHeaderModel_H
#define DialogsHeaderModel_H

#include <QtCore>
#include "src/usersmanager.h"

typedef QVector<QObject*> ChatAndUsersVector;

class DialogsHeaderModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        Id,
        Name,
        Online,
        Avatar,
        AvatarLoaded,
        UnreadMessages,
        IsChat
    };

    Q_ENUMS(Roles)

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

private:
    ChatAndUsersVector items;

public:
    explicit DialogsHeaderModel(QObject *parent = 0);

    int rowCount(const QModelIndex & = QModelIndex()) const { return items.size(); }
	QHash<int, QByteArray> roleNames() const;
    QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void clear() { beginResetModel(); items.clear(); endResetModel(); }
    Q_INVOKABLE void appendChat(int chatId, const QString &topic);
    Q_INVOKABLE void appendUser(int user_id);
    Q_INVOKABLE void remove(int i);
    Q_INVOKABLE void itemChanged(int i) { dataChanged(index(i), index(i)); }
    Q_INVOKABLE int indexOf(int id);
    Q_INVOKABLE void setHasUnreadMessages(int i, bool hasUnread);
    Q_INVOKABLE bool updateUnreadMessages(int currentIndex);

signals:
    void countChanged();

private slots:
    void itemDataChanged();
};

#endif // DialogsHeaderModel_H
