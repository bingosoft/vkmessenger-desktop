import QtQuick 1.0

FocusScope {
	id: rectangle
	height: 30;
	property alias text: textInput.text;
	signal returnPressed;
	signal mousePressed;
	
	MouseArea {
		anchors.fill: parent;
		
		onPressed: {
			textInput.forceActiveFocus();
		}
	}
	
	Rectangle {
		anchors.fill: parent;
		radius: 8;
		color: "#033a65";
		border.color: "#3b87c0"
		border.width: 1;
		smooth: true;
	
		Image {
			id: image
			source: "images/search.png";
			anchors.left: parent.left;
			anchors.top: parent.top;
			anchors.bottom: parent.bottom;
			anchors.margins: 6;
			anchors.topMargin: 8
			anchors.leftMargin: 10
			smooth: true;
			fillMode: Image.PreserveAspectFit;
	
			Behavior on scale {
				NumberAnimation {
					duration: 300;
	
					onRunningChanged: {
						if (!running)
							image.scale = 1;
					}
				}
			}
		}
	
		TextInput {
			id: textInput;
			anchors.fill: parent;
			width: 71
			height: 26
			color: "#ffffff"
			selectedTextColor: "#ffffff"
			font.pixelSize: 17
			anchors.topMargin: 5
			cursorVisible: true
			anchors.leftMargin: 35;
			anchors.rightMargin: 10;
			focus: true;
			Keys.forwardTo: mainWindow;
	
			MouseArea {
				anchors.fill: parent;
				onPressed: {
					image.scale = 1.3;
					parent.focus = true;
					if (textInput.selectedText == text)  {
						textInput.select(0, 0);
						textInput.cursorPosition = text.length;
					} else {
						textInput.selectAll();
					}
					mousePressed();
				}
			}
	
			onAccepted: rectangle.returnPressed();
	
			Keys.onPressed: {
				if (event.modifiers & Qt.AltModifier || event.key == Qt.Key_Plus || event.key == Qt.Key_Minus) {
					event.accepted = true;
				}
			}
		}
	}
}
