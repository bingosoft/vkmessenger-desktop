import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import "../controls";

MouseArea {
    id: contactsDelegate;
    height: 50;
    anchors.left: parent.left;
    anchors.right: parent.right;
	acceptedButtons: Qt.RightButton | Qt.LeftButton;
	hoverEnabled: true;

	signal clicked;
	signal contextMenuRequested(int x, int y);

	Rectangle {
        anchors.fill: parent;
//	    color: !model.online ? "#eeeeee" : model.index % 2 == 0 ? "#fff" : "#f8f8fc";
	    color: model.index % 2 == 0 ? "#fff" : "#f8f8fc";
    }

    Rectangle {
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        height: 1;
        color: "#ddd";
    }

    Rectangle {
        anchors.fill: parent;
        anchors.topMargin: 0;
        anchors.bottomMargin: 1;
        anchors.margins: -2;
        border.width: 1;
        opacity: model.selected ? 1 : 0;
        border.color: "#90C4E5";
        gradient: Gradient {
GradientStop {
    position: 0.00;
    color: "#cfecf3";
}
GradientStop {
    position: 1.00;
    color: "#b9def1";
}
}

        Behavior on opacity {
            animation: NumberAnimation {
                duration: 200;
            }
        }
    }

    SmoothImage {
        id: avatar
        anchors.left: parent.left;
        anchors.leftMargin: 5;
        anchors.top: parent.top;
        anchors.bottom: parent.bottom;
        anchors.margins: 5;
        height: 40;
        width: 40;
        source: model.avatarLoaded ? ("image://round/" + model.user_id + "|" + model.avatar) : "../images/unknown.png";
        opacity: model.online ? 1 : 0.6;
    }

    Bullet {
        id: onlineRect;
        anchors.left: avatar.right;
        anchors.leftMargin: 5;
        anchors.verticalCenter: userName.verticalCenter;
        color: "#6faec4"
        scale: model.online ? 1 : 0;
    }

    Text {
        id: userName;
        anchors.left: avatar.right;
        anchors.top: parent.top;
        anchors.topMargin: 5;
        anchors.leftMargin: model.online ? 18 : 5;
        color: model.online ? "#333" : "#808080";
        text: model.name != "" ? model.name : "id" + model.user_id;
        font.pointSize: 13;

        Behavior on color {
            animation: ColorAnimation {
                duration: 300;
            }
        }

        Behavior on anchors.leftMargin {
            animation: NumberAnimation {
                duration: 500;
                easing.type: Easing.OutBack;
            }
        }
    }

    Text {
        id: status;
        anchors.left: avatar.right;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 5;
        anchors.leftMargin: 5;
        font.pointSize: 10;
        color: model.online ? "#45638c" : "#999";
        text:   model.name == "" ?
                    "Loading user..." :
                model.online ?
                    model.status == "" ?
                        "Online" :
                        oneLine(model.status) :
                    model.lastSeen == "" ?
                        "<font color=#800>Account deleted</a>" :
                        ("Offline since " + model.lastSeen);

        Behavior on color {
            animation: ColorAnimation {
                duration: 300;
            }
        }
    }

    Rectangle {
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        height: 1;
        color: "#ddd";
    }

    onPressed: {
        contactsDelegate.clicked();

        if (mouse.button == Qt.RightButton)
            contactsDelegate.contextMenuRequested(mouseX, mouseY);
    }

	function oneLine(s) {
		var p = s.indexOf('\n');
		if (p > -1)
			return s.substr(0, p - 1);

		return s;
	}
}
