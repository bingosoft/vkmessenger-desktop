#ifndef CONTACTSMODEL_H
#define CONTACTSMODEL_H

#include <QtCore>
#include "src/usersmanager.h"

typedef QVector<int> UidsVector;

class ContactsModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        Id,
        Name,
        Status,
        Online,
        Avatar,
        Selected,
        LastSeen,
        AvatarLoaded,
        UnreadMessages
    };

    Q_ENUMS(Roles)

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

private:
    UidsVector items;

    int findContact(int uid) const;

public:
    explicit ContactsModel(QObject *parent = 0);

    int rowCount(const QModelIndex & = QModelIndex()) const { return items.size(); }
	QHash<int, QByteArray> roleNames() const;
    QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void load(const QVariantList &data);
    Q_INVOKABLE void clear() { beginResetModel(); items.clear(); endResetModel(); }
    Q_INVOKABLE UserItem* get(int i) const;
    Q_INVOKABLE void append(int uid);
    Q_INVOKABLE void remove(int i);
    Q_INVOKABLE void itemChanged(int i) { dataChanged(index(i), index(i)); }

signals:
    void countChanged();

private slots:
    void itemDataChanged();
};

#endif // CONTACTSMODEL_H
