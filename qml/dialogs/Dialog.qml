import QtQuick 1.1 // to target S60 5th Edition or Maemo 5
import info.bingosoft.vkmessenger 1.0
import "../controls";
import "../js/forwardMessages.js" as ForwardMessages;
import "../js/smiles.js" as Smiles;

FocusScope {
	 id: dialogItem;
	 property int dialogId;
	 property bool printsMessage;
	 property variant user;
	 property int printsMessageUser;
	 property bool hasUnreadMessages: false;
	 property bool getHistory: true;
	 property int editingMessageId: -1;
	 focus: true;
	 clip: true;
	 signal smilesButtonPressed();

	 ListModel {
		id: messagesModel;
	 }

	 Flickable {
		id: listView;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.rightMargin: dialogId > 2000000000 ? chatUsers.width : 0;
		anchors.top: parent.top;
		anchors.bottom: inputArea.top;
		contentWidth: width;
		contentHeight: column.height;
		property int count: messagesModel.count;

		MouseArea {
			id: mouseArea;
			anchors.fill: parent;
			acceptedButtons: Qt.LeftButton | Qt.RightButton;

			onPressed: {
				 if (mouse.button == Qt.RightButton) {
					dialogs.showContextMenu(mouseX + 13, mouseY - listView.contentY + 85);
				 }
			}

			onDoubleClicked: {
				 selectCurrentMessage();
			}
		}

		Column {
			id: column;
			anchors.left: parent.left;
			anchors.right: parent.right;

			Repeater {
				id: repeater;
				model: messagesModel;
				delegate: MessageDelegate {
					printsMessage: dialogItem.printsMessage;
					width: listView.width;
				}
			}
		}

		onContentYChanged: {
				if (contentY == 0)
					 loadHistory();
		}

		function updateContentY() {
			var needScroll = (scrollAnimation.running ? scrollAnimation.to : listView.contentY) >= (listView.contentHeight - listView.height - 20);
			if (needScroll)
				 scrollSmoothToEnd();
		}
	}

	ListView {
		id: chatUsers;
		anchors.top: parent.top;
		anchors.bottom: inputArea.top;
		anchors.right: parent.right;
		visible: dialogId > 2000000000;
		width: 50;
		spacing: 5;

		model: ListModel {
			id: chatUsersModel;
		}

		delegate: SmoothImage {
			height: 50;
			width: 50;
			source: model.avatarLoaded && model.avatar != "http://vk.com/images/camera_c.gif" ? ("image://round/" + model.user_id + "|" + model.avatar) : "../images/unknown.png";
			opacity: model.online ? 1 : model.selected ? 0.8 : 0.6;

			Behavior on opacity {
				animation: NumberAnimation {
					duration: 300;
				}
			}
		}
	}

	ScrollBar {
		view: listView;
	}

	DialogEdit {
		id: inputArea;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		focus: true;

		Rectangle {
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.top: parent.top;
			height: 1;
			color: "#fff";
		}

		Rectangle {
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.top: parent.top;
			anchors.topMargin: 1;
			height: 1;
			color: "#ddd";
		}

		onSendMessage: {
			if (editingMessageId != -1) {
				dialogItem.editMessage(text);
				console.log("editing a message \"" + text + "\"");
			} else {
				dialogItem.sendMessage(text, forwardMessages);
				console.log("sending a message \"" + text + "\"");
			}
		}

		onClearForwardMessages: {
				ForwardMessages.clearSelectedMessages();
		}

		onSmilesButtonPressed: {
				dialogItem.smilesButtonPressed();
		}

		onEditMessageRequested: {
			var i = messagesModel.count - 1;

			while (i >= 0) {
				var msg = messagesModel.get(i);

				if (msg.message.out == 1) {
 				 	inputArea.setText(msg.message.body);
 				 	editingMessageId = msg.message.id;
 				 	break;
				}
				i--;
			}
		}

		onHeightChanged: listView.updateContentY();
	 }

	 Rectangle {
		anchors.bottom: inputArea.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		height: 15;
		opacity: listView.contentY >= (listView.contentHeight - listView.height - 10) ? 0 : 1;

		gradient: Gradient {
				GradientStop {
					 position: 1.00;
					 color: "#d0d0d0";
				}
				GradientStop {
					 position: 0.00;
					 color: "#00ffffff";
				}
		}

		Behavior on opacity {
				animation: NumberAnimation {
					 duration: 300;
				}
		}
	 }

	 Timer {
		id: printNotificationTimeout;
		interval: 10000;
	 }

	 Timer {
		id: userPrintsNotificationTimeout;
		interval: 5000;

		onTriggered: {
				userPrintsMessage(false);
		}
	 }

	 Timer {
		id: postScrollTimer;
		interval: 200;

		onTriggered: {
				dialogItem.scrollSmoothToEnd();
		}
	 }

	 NumberAnimation {
		id: scrollAnimation;
		target: listView;
		property: "contentY";
		duration: 400;
		easing.type: Easing.InOutCirc
	 }

	 Behavior on opacity {
		animation: NumberAnimation {
				duration: 300;
		}
	 }

	 Component.onCompleted: {
		if (getHistory)
				vkApi.makeQuery("messages.getHistory", {user_id: dialogId, count: 25}).completed.connect(function(data) { onHistoryReceived(data, true); });

		ForwardMessages.addObserver(inputArea, selectedMessagesCountChanged);
		usersManager.chatDataChanged.connect(updateChat);
		usersManager.userDataChanged.connect(updateUser);

		if (dialogId > 2000000000) {
			var chat = usersManager.getChat(dialogId)
			if (chat.loaded)
				updateChat(dialogId);
		}
	 }

	 Component.onDestruction: {
		ForwardMessages.removeObserver(inputArea, dialogId);
		usersManager.chatDataChanged.disconnect(updateChat);
		usersManager.userDataChanged.disconnect(updateUser);
	 }

	 function append(user, message, checkExisting) {
		if (checkExisting) {
			for (var i = 0; i < messagesModel.count; ++i)
				if (messagesModel.get(i).message.id == message.id) {
				messagesModel.setProperty(i, "message", message);
//				repeater.itemAt(i).updateMessage(message);
				print("update text of message " + message.id + " with " + message.body)
				return;
			}
		}
		insert(messagesModel.count, user, message);
	}

	function formatText(text) {
		var re = new RegExp("http([s]?):\\/\\/([=\\?\\%\\#\\;\\&\\w\\.\\/_-]+)", "g");
		text = text.replace(re, "<a href='http$1://$2'>http$1://$2</a>");
		text = Smiles.detectSmilies(text);
		return text;
	}

	 function insert(index, user, message) {
		for (var i = 0; i < messagesModel.count; ++i) {
			if (messagesModel.get(i).message.id == message.id) {
				return;
			}
		}

		printsMessage = false;
		var needScroll = (scrollAnimation.running ? scrollAnimation.to : listView.contentY) >= (listView.contentHeight - listView.height - 10);
		message.body = formatText(message.body);
		messagesModel.insert(index, {user: user, message: message, read: message.read_state, selected: false});
//		console.log(" === DUMPING MESSAGE === \n\n" + message.body + "\n\n");

		if (needScroll)
			postScrollTimer.restart();

		hasUnreadMessages = true;
	 }

	 function onHistoryReceived(data, scrollToEnd) {
		console.log(data);
		var resp = JSON.parse(data).response.items;
		if (!scrollToEnd) {
			var previousHeight = listView.contentHeight;
			var previousCountentY = listView.contentY;
		}

		console.log("received history " + resp.length + " messages");

		for (var i = 0; i < resp.length; ++i)
			insert(0, user, resp[i]);

		if (!scrollToEnd)
			listView.contentY = previousCountentY + listView.contentHeight - previousHeight;
	 }

	 function sendMessage(text, forwardMessages) {
		var date = new Date();
		var forwardedMessages = "";
		if (forwardMessages) {
				for (var i = 0; i < ForwardMessages.forwardMessages.length; ++i)
					 forwardedMessages += (forwardedMessages == "" ? "" : ",") + ForwardMessages.forwardMessages[i].id;
				ForwardMessages.clearSelectedMessages();
		}
		if (dialogId < 2000000000) {
			vkApi.makeQuery("messages.send", {user_id: dialogId, message: text, guser_id: date.getTime(), forward_messages: forwardedMessages});
		} else {
				console.log("sending message to a chat");
			vkApi.makeQuery("messages.send", {chat_id: dialogId - 2000000000, message: text, guser_id: date.getTime(), forward_messages: forwardedMessages});
		}
	 }

	 function editMessage(text) {
	 	print("edit a message " + editingMessageId + " with text " + text)
		vkApi.makeQuery("messages.edit", {peer_id: dialogId, message: text, message_id: editingMessageId, keep_forward_messages: 1, keep_snippets: 1});
		editingMessageId = -1;
	 }

	 function userPrintsMessage(isPrints) {
		if (isPrints)
				userPrintsNotificationTimeout.restart();

		printsMessage = isPrints;
	 }

	 function getMessageAtMouse() {
		var totalHeight = 0;

		for (var i = 0; i < messagesModel.count; ++i) {
				totalHeight += repeater.itemAt(i).height;
				if (totalHeight >= mouseArea.mouseY)
					 return i;
		}

		return -1;
	 }

	 function setMessageRead(id, read) {
		for (var i = messagesModel.count - 1; i >= 0; --i) {
			if (messagesModel.get(i).message.id == id) {
				 messagesModel.setProperty(i, "read", read);
				 break;
			}
		}
	 }

	 function scrollSmoothToEnd() {
		if ((listView.contentHeight - listView.height) <= 0)
				return;
		scrollAnimation.to = listView.contentHeight - listView.height;
		scrollAnimation.restart();
	 }

	 function selectCurrentMessage() {
		var i = getMessageAtMouse();
		var message = messagesModel.get(i);
		messagesModel.setProperty(i, "selected", !message.selected);
		ForwardMessages.toggleSelectedMessage(message.message.id, dialogId);
		console.log("selecting message " + message.message.id);
	 }

	 function convertToRu() {
		var ind = getMessageAtMouse();
		var message = messagesModel.get(ind);
		var s = "";
		var tr = {"from": "qwertyuiop[]asdfghjkl;'zxcvbnm,./QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>?",
					"to": "йцукенгшщзхъфывапролджэячсмитьбю.ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,"};
		for (var i = 0; i < message.message.body.length; ++i) {
			var pos = tr.from.indexOf(message.message.body[i]);

				if (pos === -1) {
					 s += message.message.body[i];
				} else {
				s += tr.to[pos];
				}
		}
		console.log(s);
		messagesModel.set(ind, {message: {body: s}});
	 }

	 function copyToClipboard() {
		var ind = getMessageAtMouse();
		var message = messagesModel.get(ind);
		context.copyToClipboard(message.message.body);
	 }

	 function selectedMessagesCountChanged(inputArea) {
		inputArea.forwardMessagesCount = ForwardMessages.forwardMessages.length;

		if (ForwardMessages.forwardMessages.length == 0) {
			for (var i = 0; i < messagesModel.count; ++i) {
				 var message = messagesModel.get(i);
				 messagesModel.setProperty(i, "selected", false);
			}
		}
	 }

	 function loadHistory() {
		console.log("loading hist");
		var messagesCount = 100;
		if (messagesModel.count > 0)
				vkApi.makeQuery("messages.getHistory", {user_id: dialogId, count: messagesCount, offset: -(messagesCount + 1), start_message_id: messagesModel.get(0).message.id}).completed.connect(function(data) { onHistoryReceived(data, false); });
	 }

	 function updateUser(user_id) {
		for (var i = 0; i < chatUsersModel.count; ++i) {
			var item = chatUsersModel.get(i);
			if (item.user_id === user_id) {
			console.log("updating a user in chat");
				 var user = usersManager.getUser(user_id);
				 chatUsersModel.set(i, user);
			}
		}
	 }

	 function updateChat(chatId) {
		if (dialogId == chatId) {
			console.log("updating a chat");
			var chat = usersManager.getChat(chatId);
			console.log("chat adminId " + chat.adminId);
			chatUsersModel.clear();
			chatUsersModel.append(usersManager.getUser(chat.adminId));

			for (var i = 1; i < chat.users.length; ++i) {
				console.log("adding " + chat.users[i]);
				chatUsersModel.append(usersManager.getUser(chat.users[i]));
			}
		}
	 }

	 function appendText(text) { inputArea.appendText(text); }
}
