import QtQuick 1.0

Dialog {
	id: inputDialog;
    property alias text: text.text; 
	width: 330;
	signal accepted(string message);
	signal refused();

	Text {
		id: text;
		anchors.top: parent.top;
		anchors.horizontalCenter: parent.horizontalCenter;
		anchors.margins: 20;
		anchors.topMargin: 10;
		wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
		color: "#ccc";
		font.pointSize: 12;
	}

	Rectangle {
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.margins: 10;
		anchors.leftMargin: 20;
		anchors.rightMargin: 20;
		height: 30;
		smooth: true;
		color: "#333";
		radius: 8;
		border.width: 1;
		border.color: "#777";

		TextInput {
			id: textInput;
			anchors.fill: parent;
			anchors.margins: 3;
			font.pointSize: 14;
			color: "#fff";
			focus: true;

			Keys.onReturnPressed: {
				inputDialog.accepted(textInput.text);
				hide();
			}

			Keys.onEscapePressed: {
				hide();
				refused();
			}
		}
	}

	Button {
		width: height;
		height: 19;
		anchors.right: parent.right;
		anchors.top: parent.top;
		anchors.margins: 10;
		img: "images/close.png";
		hint: qsTr("Close");
		
		onPressed: {
			inputDialog.hide();
		}
	}

	function show(message) {
		text.text = message;
		textInput.text = "";
		showDialog();
		textInput.forceActiveFocus();
	}
	
	function hide() {
		blackRect.opacity = 0;
		inputDialog.scale = 0;
		text = "";
	}
}
