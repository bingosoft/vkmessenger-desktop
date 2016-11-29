import QtQuick 1.0 // to target S60 5th Edition or Maemo 5

Item {
	id: floatingTextItem;
	property alias text: innerText.text;
    property alias font: innerText.font;
    property alias horizontalAlignment: innerText.horizontalAlignment;
	property alias color: innerText.color;
	height: innerText.paintedHeight;
    property int skipTimes;
    property bool mouseDown;
	
	Text {
		id: innerText;	
		anchors.top: parent.top;
		
		onTextChanged: {
			width = paintedWidth > parent.width ? paintedWidth : parent.width;
			floatingTextItem.reset();
		}
	}
	
    NumberAnimation { 
		id: returnAnimation;
		target: innerText; 
		property: "x";
		to: 0;
		duration: 300; 
		easing.type: Easing.OutCirc;
	}
	
	Timer {
		id: floatingTimer;
		interval: 100;
		repeat: true;
		running: !floatingTextItem.mouseDown && innerText.width > parent.width;
		
		onTriggered: {
			if (skipTimes < 0) {
				skipTimes++;
			} else if (-innerText.x < innerText.width - parent.width) {
				innerText.x -= 1;
			} else if (skipTimes > 10) {
				returnAnimation.restart();
				skipTimes = -10;
			} else {
				skipTimes++;
			}
		}
	}
	
	MouseArea {
		anchors.fill: parent;
        property int prevX;
		
		onPressed: {
			prevX = mouse.x;
			if (innerText.x != 0)
				returnAnimation.restart();
			floatingTextItem.mouseDown = true;
		}
	
		onMouseXChanged: {
			innerText.x = Math.min(0, Math.max(innerText.x + mouseX - prevX, parent.width - innerText.width));
			prevX = mouseX;
		}
		
		onReleased: {
			floatingTextItem.skipTimes = -10;
			floatingTextItem.mouseDown = false;
		}
	}
	
	onWidthChanged: {
		innerText.width = innerText.paintedWidth > width ? innerText.paintedWidth : width;
	}

	function reset() {
		innerText.x = 0;
		floatingTextItem.skipTimes = 0;
	}
}
