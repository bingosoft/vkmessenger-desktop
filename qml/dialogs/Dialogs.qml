import QtQuick 1.0
import info.bingosoft.vkmessenger 1.0
import "."
import "../controls/"

FocusScope {
	id: dialogsItem;
	focus: true;

	property variant longPollResponse;

	//Dialog { } // used to debug Dialog.qml issues

	DialogsHeader {
		id: header;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: parent.top;
		z: 1;

		onClose: {
			closeDialog(index);
		}
	}

	PageStack {
		id: pageStack;
		anchors.top: header.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		currentIndex: header.currentIndex;
		focus: true;
	}

	SmilesPanel {
		id: smilesPanel;
		anchors.left: parent.left;
		anchors.leftMargin: 10;
		anchors.bottom: parent.bottom;
		anchors.bottomMargin: 50;
		scale: active ? 1 : 1.2;

		onAddSmile: {
			var dialog = pageStack.getItem(pageStack.currentIndex);
			dialog.appendText(code);
		}
	}

	Keys.onPressed: {
		if (event.modifiers & Qt.AltModifier)
			switchBetweenTabs(event);
	}

	Timer {
		id: postInitTimer;
		interval: 100;

		onTriggered: {
			init();
		}
	}

	Component.onCompleted: {
		postInitTimer.restart();
	}

	function init() {
		dialogs.doOpenDialog.connect(doOpenDialog);
		dialogs.isActiveChanged.connect(onIsActiveChanged);
		dialogs.selectMessage.connect(selectMessage);
		dialogs.convertToRu.connect(convertToRu);
		dialogs.copyToClipboard.connect(copyToClipboard);
		vkApi.authorized.connect(onAuthorized);
		vkApi.disconnected.connect(onDisconnected);
		if (vkApi.isAuthorized())
			onAuthorized();
//		processLongPollEvents('{"ts":1847252554,"updates":[[4,378841,561,170037136,1428000327," ... ","",{"attach1_type":"photo","attach1":"170037136_361146410","attach2_type":"photo","attach2":"170037136_361146434","attach3_type":"photo","attach3":"170037136_361146499"}]]}');
	}

	function switchBetweenTabs(event) {
		if (event.key > Qt.Key_0 && event.key <= Qt.Key_9) {
			var num = event.key - Qt.Key_1;
			if (num < header.count)
				header.currentIndex = num;
			event.accepted = true;
		}
	}


	function doOpenDialog(user) {
		console.log("do open dialog " + user.user_id);
		if (!header.hasDialog(user.user_id))
			createDialog(user.user_id, true);
		header.openDialog(user.user_id);
	}

	function onAuthorized() {
		vkApi.makeQuery("messages.getLongPollServer", {use_ssl: 1}).completed.connect(onLongPollServerReceived);
		vkApi.makeQuery("messages.getDialogs", {count: 200, preview_length: 0, unread: 1}).completed.connect(onDialogsReceived);
	}

	function onDisconnected() {
		console.log("disconnected");
		if (longPollResponse)
			longPollResponse.destroy();
	}

	function createDialog(userId, getHistory) {
		var component = Qt.createComponent("Dialog.qml");
		var dialog = component.createObject(pageStack, {dialogId: userId, getHistory: getHistory, opacity: 0, printsMessageUser: userId});
		dialog.smilesButtonPressed.connect(onSmilesButtonPressed);
		pageStack.addItem(dialog);
		console.log("adding a user " + userId);
		header.addUser(userId);
	}

	function createChat(chatId, topic, getHistory) {
		console.log("adding a chat " + chatId + ", topic " + topic);
		var component = Qt.createComponent("Dialog.qml");
		var dialog = component.createObject(pageStack, {dialogId:chatId, getHistory:getHistory, opacity: 0});
		dialog.smilesButtonPressed.connect(onSmilesButtonPressed);
		pageStack.addItem(dialog);
		header.addChat(chatId, topic);
	}

	function findDialog(id) {
		for (var i = 0; i < pageStack.count; ++i) {
			var dialog = pageStack.getItem(i);
			if (dialog.dialogId == id)
				return dialog;
		}
		return undefined;
	}

	function processMessage(message, checkExisting) {
		var isChatMessage = message.hasOwnProperty("chat_id") && message.chat_id > -1;

		if (isChatMessage && message.chat_id < 2000000000)
			message.chat_id += 2000000000;

		if (isChatMessage) {
			if (!header.hasDialog(message.chat_id)) {
				createChat(message.chat_id, message.title, false);
			}
		} else {
			if (!header.hasDialog(message.user_id)) {
				createDialog(message.user_id, false);
			}
		}

		var user = message.out ? usersManager.getUser(context.currentUser) : usersManager.getUser(message.user_id);
		var dialogId = isChatMessage ? message.chat_id : message.user_id;
		var dialog = findDialog(dialogId);

		if (dialog)
			dialog.append(user, message, checkExisting);
		else
			console.log("dialog was not found");

		var index = header.indexOf(dialogId);

		if (!dialogs.isActiveWindow() || index != header.currentIndex) {
			context.setHasNewMessages(true);
			header.setHasUnreadMessages(index, true);
		}
	}

	function onLongPollServerReceived(data) {
		var res = JSON.parse(data).response;
		console.log("long poll server " + data);

		longPollResponse = vkApi.connectToLongPollServer(res.server, res.key, res.ts);
		longPollResponse.completed.connect(processLongPollEvents);
		longPollResponse.error.connect(longPollError);
	}

	function onDialogsReceived(data) {
		print("unread messages received " + data)
		var items = JSON.parse(data).response.items;

		if (items.length > 0)
			dialogs.showDialog();

		for (var i = 0; i < items.length; i++) {
			var dialog = items[i];
			vkApi.makeQuery("messages.getHistory", {user_id: dialog.message.user_id, count: dialog.unread}).completed.connect(onMessagesReceived);
		}
	}

	function onMessagesReceived(data) {
		var items = JSON.parse(data).response.items;

		for (var i = items.length - 1; i >= 0; i--) {
			processMessage(items[i], true);
		}
	}

	function onIsActiveChanged(isActive) {
		if (isActive)
			header.updateUnreadMessages();
	}

	function closeDialog(index) {
		if (index == undefined)
			var index = pageStack.currentIndex;
		header.removeButton(index);
		pageStack.removeItem(index);

		if (pageStack.count == 0)
			dialogs.closeDialog();
	}

	function onSmilesButtonPressed() {
		if (!smilesPanel.active)
			smilesPanel.show();
		else
			smilesPanel.hide();
	}

	function convertToRu() {
		console.log("convert to ru");
		var dialog = pageStack.getItem(pageStack.currentIndex);

		if (dialog)
			dialog.convertToRu();
	}

	function copyToClipboard() {
		console.log("copy to clipboard");
		var dialog = pageStack.getItem(pageStack.currentIndex);

		if (dialog)
			dialog.copyToClipboard();
	}

	function selectMessage() {
		var dialog = pageStack.getItem(pageStack.currentIndex);

		if (dialog)
			dialog.selectCurrentMessage();
	}

	function processLongPollEvents(data) {
		console.log("events from longPoll " + data);
		var res = JSON.parse(data);

		if (res["failed"]) {
			console.log("longpoll server is deprecated");

			getLongPollServerTimer.restart();
			return;
		}

		var FLAG = {
			Unread: 1,
			Outbox: 2,
			Replied: 4,
			Important: 8,
			Chat:		16,
			Friends:	32,
			Media:		512
		};

		var EVENT = {
			NewMessage: 4,
			EditMessage: 5,
			PrintsMessage: 61,
			PrintsMessageInDialog: 62,
			ResetFlags: 3,
			UserOnline: 8,
			UserOffline: 9
		};

		//events from longPoll {"ts":1701605341,"updates":[[5,652198,34,71420741,1531843037,"","чет геморрой(",{}]]}

		try {
			for (var i = 0; i < res.updates.length; ++i) {
				var event = res.updates[i];

				var isChatMessage = event[3] > 2000000000; // magic chat id

				if (event[0] == EVENT.NewMessage || event[0] == EVENT.EditMessage) {
					var message = {
						id: event[1],
						user_id: isChatMessage ? event[7].from : event[3],
						date: event[4],
						read_state: !(event[2] & FLAG.Unread),
						chat_id: isChatMessage ? event[3] : -1,
						out: event[2] & FLAG.Outbox ? 1 : 0,
						title: event[5],
						body: event[6],
						attachments: event.length > 7 && (event[7].attach1_type || event[7].fwd)? true : undefined
					};
					if (isChatMessage) {
						message.attachments = undefined;

						for (var key in event[7]) {
							console.log("key " + key);
							if (key.indexOf("attach") > -1 || key.indexOf("fwd") > -1) {
								message.attachments	= true;
								console.log("attachment found");
								break;
							}
						}
					}
					processMessage(message, true);
					dialogs.showDialog();
				} else if (event[0] == EVENT.PrintsMessage) {
					var dialog = findDialog(event[1]);

					if (dialog) {
						dialog.printsMessageUser = event[1];
						dialog.userPrintsMessage(true);
					} else {
						createDialog(event[1], true);
						console.log("user prints message, but dialog doen't exists, https://vk.com/id" + event[1]);
					}
				} else if (event[0] == EVENT.PrintsMessageInDialog) {
					var dialogId = 2000000000 + event[2];
					var dialog = findDialog(dialogId);

					if (!dialog) {
						createChat(dialogId);
						console.log("user prints message in dialog, but dialog doen't exists, https://vk.com/id" + event[1]);
						dialog = findDialog(dialogId);
					}
					dialog.printsMessageUser = event[1];
					dialog.userPrintsMessage(true);
				} else if (event[0] == EVENT.ResetFlags) {
					var dialog = findDialog(event[3]);

					if (dialog) {
						var flag = event[2];
						if (flag & FLAG.Unread)
							dialog.setMessageRead(event[1], flag & FLAG.Unread);
					}
				} else if (event[0] == EVENT.UserOnline) {
					var user = usersManager.getUser(Math.abs(event[1]));
					user.online = true;
				} else if (event[0] == EVENT.UserOffline) {
					var user = usersManager.getUser(Math.abs(event[1]));
					user.online = false;
				}
			}
		}
		catch (e) {
			console.log("Exception: " + e.toString());
		}
//		console.log("reconnecting");
		longPollResponse = vkApi.connectToLongPollServer(res.ts);
		longPollResponse.completed.connect(processLongPollEvents);
		longPollResponse.error.connect(longPollError);
	}

	Timer {
		id: postReconnectTimer;
		interval: 1000;

		onTriggered: {
			longPollResponse = vkApi.connectToLongPollServer();
			longPollResponse.completed.connect(processLongPollEvents);
			longPollResponse.error.connect(longPollError);
		}
	}

	Timer {
		id: getLongPollServerTimer;
		interval: 500;

		onTriggered: {
			vkApi.makeQuery("messages.getLongPollServer", {use_ssl: 1}).completed.connect(onLongPollServerReceived);
		}
	}

	function longPollError() {
		console.log("longPoll error, reconnecting again");
		postReconnectTimer.restart();
	}
}
