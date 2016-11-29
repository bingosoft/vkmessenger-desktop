import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import info.bingosoft.vkmessenger 1.0
import "."
import "../controls/"

Rectangle {
    id: dialogsHeader;
    height: 52;
    property alias currentIndex: listView.currentIndex;
    property alias count: listView.count;
    property bool showTopDimmer: true;

    signal close(int index);

    gradient: Gradient {
        GradientStop {
            position: 0.00;
            color: "#7d9dc4";
        }
        GradientStop {
            position: 0.29;
            color: "#6d8cb8";
        }
        GradientStop {
            position: 1.00;
            color: "#44588b";
        }
    }

	DialogsHeaderModel {
		id: headerModel;
	}

    Rectangle {
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 1;
        height: 2;
        color: "#87abd7"
    }

    ListView {
        id: listView;
        anchors.fill: parent;
        model: headerModel;
        orientation: ListView.Horizontal;
        anchors.margins: 5;
        anchors.bottomMargin: 8;

        delegate:
            ToolButton {
                id: delegate;
                height: 40;
                text: model.name;
                icon: model.avatarLoaded && model.avatar != "http://vk.com/images/camera_c.gif" ? ("image://round/" + model.id + "|" + model.avatar) : "../images/unknown.png";
                selected: currentIndex == model.index;

                onReleased: {
                    if (mouse.button == Qt.LeftButton)
                        dialogsHeader.currentIndex = model.index;
                }

				onOpenInBrowser: {
					if (model.isChat)
						context.open("https://vk.com/im?sel=c" + (model.id - 2000000000));
					else
						context.open("https://vk.com/id" + model.id);
				}

                onClose: {
                    dialogsHeader.close(model.index);
                }

                ListView.onRemove:
                    SequentialAnimation {
                        PropertyAction { target: delegate; property: "ListView.delayRemove"; value: true }
                        ParallelAnimation {
                            NumberAnimation { target: delegate; property: "width"; to: 0; duration: 300; easing.type: Easing.InCirc; }
                            NumberAnimation { target: delegate; property: "opacity"; to: 0; duration: 600; easing.type: Easing.OutCirc; }
                        }
                        PropertyAction { target: delegate; property: "ListView.delayRemove"; value: false }
                    }
            }

		onCurrentIndexChanged: {
			var prevPos = listView.contentX;
			listView.positionViewAtIndex(currentIndex, ListView.Contain);
			var currentPos = listView.contentX;
			listView.contentX = prevPos;
			currentIndexNavigation.to = currentPos;
			currentIndexNavigation.restart();
			updateUnreadMessages();
		}
	}

    NumberAnimation {
		id: currentIndexNavigation
		target: listView;
		property: "contentX";
		duration: 400;
		easing.type: Easing.InOutCirc;
	}

    Rectangle {
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        height: 1;
        color: "#fff";
    }

    Rectangle {
        anchors.top: parent.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        height: 15;
        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#d0d0d0";
            }
            GradientStop {
                position: 1.00;
                color: "#00ffffff";
            }
        }

        opacity: showTopDimmer ? 1 : 0;
        Behavior on opacity {
            animation: NumberAnimation {
                duration: 300;
            }
        }
    }

	function indexOf(id) {
		return headerModel.indexOf(id);
	}

	function hasDialog(id) {
        return headerModel.indexOf(id) != -1;
	}

	function getUser(id) {
        var i = headerModel.indexOf(id);
        return i != -1 ? headerModel.get(i) : undefined;
	}

	function addUser(uid) {
        console.log("adding a user " + uid);
        headerModel.appendUser(uid);
		if (listView.currentIndex == -1)
			listView.currentIndex = 0;
	}

    function addChat(chatId, topic) {
        console.log("adding a chat " + chatId + ", topic " + topic)
        headerModel.appendChat(chatId, topic == undefined ? "" : topic);
		if (listView.currentIndex == -1)
			listView.currentIndex = 0;
    }

	function openDialog(id) {
        console.log("opening dialog for id" + id);
        var ind = headerModel.indexOf(id);
        console.log("index " + ind)
        if (ind != -1)
			currentIndex = ind;
	}

	function removeButton(index) {
	    if (currentIndex == headerModel.count - 1)
	        currentIndex = headerModel.count - 2;
		headerModel.remove(index);
	}

    function setHasUnreadMessages(tabIndex, hasUnread) {
		headerModel.setHasUnreadMessages(tabIndex, hasUnread);
    }

    function updateUnreadMessages() {
		console.log("update unread messages");
        var hasUnreadMessages = headerModel.updateUnreadMessages(listView.currentIndex);
        if (!hasUnreadMessages)
            context.setHasNewMessages(false);
    }
}
