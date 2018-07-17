import QtQuick 1.1
import "../controls"
import "."

Item {
	id: messageDelegateItem;
	height: Math.max(60, content.height + 40);

	property variant usr;
	property variant message: model.message;
	property bool printsMessage;

	Rectangle {
		anchors.fill: parent;
		color: model.selected ? "#BAD3E7" : model.read == 0 ? "#d9e5ee" : model.message.out == 1 ? "#f4f5fd" : "#f9f9f9";

		Behavior on color {
			animation: ColorAnimation {
				duration: 300;
			}
		}
	}

	Item {
		id: opacityItem;
		anchors.left: parent.left;
		anchors.right: parent.right;
		height: Math.max(60, content.height + 40);
		opacity: 0.1;

		SmoothImage {
			id: avatar;
			anchors.left: parent.left;
			anchors.top: parent.top;
			anchors.margins: 7;
			source: usr.avatarLoaded && usr.avatar != "http://vk.com/images/camera_c.gif" ? ("image://round/" + usr.user_id + "|" + usr.avatar) : "../images/unknown.png";
			width: 40;
			height: 40;

			MouseArea {
				anchors.fill: parent;

				onDoubleClicked: {
					context.open("https://vk.com/id" + usr.user_id);
				}
			}
		}

		LinkLabel {
			id: sender;
			anchors.left: avatar.right;
			anchors.leftMargin: 5;
			anchors.top: avatar.top;
			text: usr.name;
			pointSize: 13;
			underLine: false;
			color: model.message.out == 1 ? "#111" : "#467F9A";
			hoveredColor: model.message.out == 1 ? "#000" : "#5492AF";

//			onClicked: {
//				if (model.message.out == 0)
//					context.open("https://vk.com/id" + usr.user_id);
//			}
		}

		Text {
			id: dateText;
			property int time: model.message.date;
			anchors.right: parent.right;
			anchors.rightMargin: 15;
			anchors.top: avatar.top;
			font.pointSize: 10;
			color: "#999";

			onTimeChanged: {
				var date = new Date(time * 1000);
				var now = new Date();
				var months = ["янв", "фев", "мар", "апр", "май", "июн", "июл", "авг", "сен", "окт", "ноя", "дек"];
				var s = date.getHours() + ":" + (date.getMinutes() < 10 ? "0" : "") + date.getMinutes() + ":" + (date.getSeconds() < 10 ? "0" : "") + date.getSeconds();

				if (date.getMonth() != now.getMonth() || date.getDate() != now.getDate())
					s += ", " + date.getDate() + " " + months[date.getMonth()];

				if (date.getFullYear() != now.getFullYear())
					s += " " + date.getFullYear();

				dateText.text = s;
			}
		}

		Column {
			id: content;
			anchors.left: sender.left;
			anchors.leftMargin: 2;
			anchors.top: sender.bottom;
			anchors.topMargin: 0;
			anchors.right: dateText.right;
//			height: contentText.height + (fwdModel.count > 0 ? fwdColumn.height + photos.height + 5 : 0);
			property bool hasFwd;
			property bool hasPhotos;

			Text {
				id: contentText;
				font.pointSize: 10;
				anchors.left: parent.left;
				anchors.right: parent.right;
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
				color: "#666";
				textFormat: Text.RichText;
				onLinkActivated: Qt.openUrlExternally(link);
				text: (message.body == "" && fwdModel.count > 0) ? qsTr("<font color=#467F9A><b>Forwarded messages:</b></font>") : message.body;

				Keys.onPressed: {
					if (event.key != Qt.Key_Left
						&& event.key != Qt.Key_Right
						&& event.key != Qt.Key_Up
						&& event.key != Qt.Key_Down
						&& event.key != Qt.Key_Home
						&& event.key != Qt.Key_End
						&& !(event.modifiers & Qt.ControlModifier)
						)
						event.accepted = true;

					if (event.modifiers & Qt.AltModifier)
						dialogsItem.switchBetweenTabs(event);
				}
			}

			Item {
				id: fwdMessagesItem;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.leftMargin: 1;
				height: fwdColumn.height;

				Column {
					id: fwdColumn;
					anchors.left: parent.left;
					anchors.leftMargin: 4;
					anchors.right: parent.right;

					Repeater {
						model: fwdModel;
						delegate: ForwardMessageDelegate {
							width: fwdColumn.width;
						}
					}
				}

				Rectangle {
					anchors.left: parent.left;
					anchors.top: fwdColumn.top;
					anchors.bottom: fwdColumn.bottom;
					width: 3;
					radius: 1.5;
					smooth: true;
					color: "#A7C6DE";
					visible: fwdModel.count > 0;
				}
			}

			Flow {
				id: photos;
				anchors.left: parent.left;
				anchors.leftMargin: 5;
				anchors.right: parent.right;
				spacing: 5;
				visible: photosModel.count > 0;

				Repeater {
					model: photosModel;
					delegate: PhotoAttachment {
						borderWidth: model.needBorder ? 1 : 0;
						source: model.source;
						sourceWidth: model.width;
						sourceHeight: model.height;
						rowHeight: model.rowHeight;
					}
				}
			}
		}

		Text {
			id: printsMessageText;
			font.pointSize: 9;
			anchors.top: content.bottom;
			anchors.left: sender.left;
			anchors.right: parent.right;
			color: "#999";
			text: userPrintsMessage && printsMessageUser > 0 ? (usersManager.getUser(printsMessageUser).name + " prints a message...") : "";
			opacity: printsMessage ? 1 : 0;
			visible: model.index == listView.count - 1;

			Behavior on opacity {
				animation: NumberAnimation {
					duration: 300;
				}
			}
		}

		Behavior on opacity {
			animation: NumberAnimation {
				duration: 300;
			}
		}
	}

	Rectangle {
		anchors.left: parent.left;
		anchors.right: parent.right;
		height: 1;
		color: "#dfdfdf";
	}

	Behavior on opacity {
		animation: NumberAnimation {
			duration: 300;
		}
	}

	ListModel {
		id: fwdModel;
	}

	ListModel {
		id: photosModel;
	}

	function onMessageReceived(data) {
		console.log("message by id received\n" + data);
		updateMessage(JSON.parse(data).response.items[0]);
	}

	function updateMessage(msg) {
		msg.body = formatText(msg.body);
		message = msg;
		processAttachments();
	}

	function processAttachments() {
		if (message.fwd_messages && message.fwd_messages.length) {
			console.log("fwd messages received");
			for (var i = 0; i < message.fwd_messages.length; ++i)
				fwdModel.append({message: message.fwd_messages[i], user: usersManager.getUser(message.fwd_messages[i].user_id)});
		} else if (message.attachments && message.attachments.length) {
			console.log("process attachments");
			for (var i = 0; i < message.attachments.length; ++i) {
				var attachment = message.attachments[i];
				console.log("attachment type " + attachment.type);

				if (attachment.type == "photo") {
					var p = attachment.photo;
					var url = p.photo_2560 != undefined ? p.photo_2560 : p.photo_1280 != undefined ? p.photo_1280 : p.photo_807 != undefined ? p.photo_807 : p.photo_604;
					url = url.replace("https://", "http://");
					console.log("photo url - ", url)
					photosModel.append({source: url, width: p.width, height: p.height, rowHeight: 0, needBorder: 1});
				}

				if (attachment.type == "sticker") {
					var p = attachment.sticker;
					photosModel.append({source: p.photo_512, width: 256, height: 256, rowHeight: 0, needBorder: 0});
				}
			}

			if (photosModel.count > 0)
				layoutPhotos();
		}
	}

	function layoutPhotos() {
		var needScroll = (scrollAnimation.running ? scrollAnimation.to : listView.contentY) >= (listView.contentHeight - listView.height - 20);
		var minHeight = 200;
		var start = 0;
		var end = 0;
		var aspects = 0;

		for (var i = 0; i < photosModel.count; ++i) {
			var p = photosModel.get(i);
			var ratio = 1.0 * p.width / p.height;
			var H = (photos.width - photos.spacing * (i - start)) / (aspects + ratio);
			if (H < minHeight) {
				for (var j = start; j <= end; ++j)
					photosModel.setProperty(j, "rowHeight", H);

				start = i + 1;
				end = start;
				aspects = 0;
			} else {
				end++;
				aspects += ratio;
			}
		}

		for (var j = start; j < photosModel.count; ++j)
			photosModel.setProperty(j, "rowHeight", H);

		if (needScroll)
			scrollSmoothToEnd();
	}

	Timer {
		id: postResizeTimer;
		interval: 200;

		onTriggered: {
			layoutPhotos();
		}
	}

	onWidthChanged: {
		postResizeTimer.restart();
	}

	Component.onCompleted: {
		usr = message.out == 1 ? usersManager.getUser(context.currentUser) : usersManager.getUser(message.user_id);
		opacityItem.opacity = 1;

		//console.log(JSON.stringify(message));

		if (typeof message.attachments == "boolean" && message.attachments) {
			vkApi.makeQuery("messages.getById", {message_ids: model.message.id}).completed.connect(onMessageReceived);
		} else if (message.attachments || message.fwd_messages) {
			processAttachments();
		}
	}
}
