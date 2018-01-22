import QtQuick 1.0

MouseArea {
    id: toolButton
    property Flickable listView;
	property bool isHover;
	property string icon;
	property alias text: text.text;
    clip: true;
    property int itemsCount;
    property bool selected;
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton;

	hoverEnabled: true;
	onEntered: isHover = true;
	onExited: isHover = false;

	signal close;
	signal openInBrowser;

    property int widthCorrection;
	width: text.width + avatar.width + avatar.anchors.leftMargin + text.anchors.leftMargin + 20 - widthCorrection;

	Rectangle {
	    color: selected ? "#000" : "#35a";
	    opacity: 0.3;
	    radius: 8;
	    anchors.fill: parent;
	    anchors.leftMargin: 2;
	    anchors.rightMargin: 2;
	    border.color: selected ? "#ddd" : "#bbb";
	    border.width: 1;
	    smooth: true;

	    Behavior on color {
	        animation: ColorAnimation {
	            duration: 300;
            }
        }

	    Behavior on border.color {
	        animation: ColorAnimation {
	            duration: 300;
            }
        }
    }

    SmoothImage {
        id: avatar;
        anchors.left: parent.left;
        anchors.verticalCenter: parent.verticalCenter;
        anchors.leftMargin: 6;
        height: 30;
        width: 30;
        source: toolButton.icon;
        opacity: model.online ? 1 : model.selected ? 0.8 : 0.6;

        Behavior on opacity {
            animation: NumberAnimation {
                duration: 300;
            }
        }
    }

    Rectangle {
        id: onlineRect;
        anchors.left: avatar.right;
        anchors.leftMargin: 4;
        anchors.verticalCenter: parent.verticalCenter;
//        anchors.leftMargin: -5;
//        anchors.top: avatar.top;
//        anchors.topMargin: -5;
        radius: width / 2;
        height: width;
        width: 8;
        color: "#51e029"
        smooth: true;
        border.width: 1;
        border.color: "#87fb6f"
        visible: model.online;
        opacity: selected ? 1 : 0.6;

        Behavior on opacity {
            animation: NumberAnimation {
                duration: 300;
            }
        }
    }

    Text {
        id: text;
        anchors.left: avatar.right;
        anchors.leftMargin: model.online ? 17 : 5;
        anchors.verticalCenter: parent.verticalCenter;
//        color: selected ? "#bdf181" : "white";
        color: selected ? model.online ? "#a3ea56" : "#ddd" : model.online ? "#a6cf95" : "#ccc";
        style: model.online ? Text.Raised : Text.Normal;
        font.pointSize: 12;
        font.bold: model.unreadMessages > 0;

        Behavior on color {
            animation: ColorAnimation {
                duration: 300;
            }
        }
        styleColor: "#555";
//        styleColor: "#a3ea56"
    }

    ScaleButton {
        img: "../images/close.png";
        anchors.right: parent.right;
        anchors.rightMargin: 4;
        width: 16;
        height: 16;
        anchors.verticalCenter: parent.verticalCenter;

        onPressed: {
            close();
        }
    }

    onReleased: {
        if (mouse.button == Qt.MidButton)
            close();
    }

    onDoubleClicked: {
		openInBrowser();
    }
}
