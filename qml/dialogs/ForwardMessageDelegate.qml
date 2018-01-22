import QtQuick 1.1
import "../controls"

Item {
    id: messageDelegateItem;
    height: Math.max(30, content.height + 24);

    property variant usr;
    property bool printsMessage;
    property string userName;

	SmoothImage {
		id: avatar;
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.margins: 5;
		source: usr.avatarLoaded && usr.avatar != "http://vk.com/images/camera_c.gif" ? ("image://round/" + usr.uid + "|" + usr.avatar) : "../images/unknown.png";
		width: 30;
		height: 30;
	}

	LinkLabel {
		id: sender;
		anchors.left: avatar.right;
		anchors.leftMargin: 5;
		anchors.topMargin: -3;
		anchors.top: avatar.top;
		text: usr.name;
		pointSize: 11;
		underLine: false;
		color: "#467F9A";
		hoveredColor: "#5492AF";

		onClicked: {
			if (model.message.out == 0)
				context.open("https://vk.com/id" + usr.uid);
		}
	}

	Text {
		id: dateText;
		property int time: model.message.date;
		anchors.left: sender.right;
		anchors.leftMargin: 5;
		anchors.top: sender.top;
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

		Text {
			id: contentText;
			font.pointSize: 10;
			anchors.left: parent.left;
			anchors.right: parent.right;
			wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
			color: "#666";
			textFormat: Text.RichText;
			onLinkActivated: Qt.openUrlExternally(link);
			text: model.message.body;
		}
	}

    Component.onCompleted: {
        usr = model.message.out == 1 ? usersManager.getUser(context.currentUser) : model.user;
    }
}
