import QtQuick 1.0
import info.bingosoft.vkmessenger 1.0

import "../controls/"

Item {
    ContactsModel {
        id: contactsModel;
    }

    ListView {
        id: listView;
        property int lastSelectedItem;
        cacheBuffer: 1000;
        delegate:
            ContactsDelegate
            {
                id: delegate;

                onClicked: {
                    listView.currentIndex = model.index;
                    listView.model.get(listView.lastSelectedItem).selected = false;
                    listView.model.itemChanged(listView.lastSelectedItem);
                    listView.model.get(model.index).selected = true;
                    listView.model.itemChanged(model.index);
                    listView.lastSelectedItem = model.index;
                }

                onContextMenuRequested: {
                    context.showContextMenu(x + 12, y + 102 + model.index * 50 - listView.contentY);
                }

                onDoubleClicked: {
                    startConversation();
                }

                ListView.onRemove:
                    SequentialAnimation {
                        PropertyAction { target: delegate; property: "ListView.delayRemove"; value: true }
                        ParallelAnimation {
                            NumberAnimation { target: delegate; property: "height"; to: 0; duration: 500; easing.type: Easing.InCirc; }
                            NumberAnimation { target: delegate; property: "opacity"; to: 0; duration: 600; easing.type: Easing.OutCirc; }
                        }
                        PropertyAction { target: delegate; property: "ListView.delayRemove"; value: false }
                    }
            }
        model: contactsModel;
        anchors.fill: parent;
        clip: true;
    }

    Rectangle {
        anchors.bottom: parent.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        height: 20;
        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#00d0d0d0";
            }
            GradientStop {
                position: 1.00;
                color: "#d0d0d0";
            }
        }
    }

    ScrollBar {
        view: listView;
    }

    function load(data) {
        contactsModel.load(data);
    }

    function startConversation() {
        console.log("startConversation");
        dialogs.openDialog(listView.model.get(listView.currentIndex));
    }

    function removeFromFriends() {
        var user = contactsModel.get(listView.currentIndex);

        if (user) {
            vkApi.makeQuery("friends.delete", {user_id: user.user_id});
            contactsModel.remove(listView.currentIndex);
        }
    }

    function openUserPage() {
        var user = contactsModel.get(listView.currentIndex);

        if (user)
            context.open("http://vk.com/id" + user.user_id);
    }
}
