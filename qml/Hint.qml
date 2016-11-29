import QtQuick 1.0

Rectangle {
	id: hint;
	radius: 5;
	height: hintText.paintedHeight + 10;
	color: "black";
	opacity: 0;
	border.width: 1;
	border.color: "#555";

	Text {
		id: hintText;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: parent.top;
		anchors.margins: 5;
		wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
		color: "white";
		font.pointSize: 9;
	}

	Timer {
		id: hintDelayTimer;
		interval: 1000;

		onTriggered: {
			opacityAnimation.to = 0.8;
			opacityAnimation.restart();
		}
	}

	NumberAnimation {
		id: opacityAnimation;
		target: hint;
		property: "opacity";
		duration: 500
	}


	function show(obj) {
		opacityAnimation.stop();
		opacity = 0;
		var x = 0;
		var y = 0;
		var tmp = obj;

		do {
			x += obj.x;
			y += obj.y;
			obj = obj.parent;
		} while (obj.parent);

		obj = tmp;
		hint.width = 2222; // magic const
		hintText.text = obj.hint;
		hint.width = Math.min(300, hintText.paintedWidth + 10);
		hint.x = Math.max(Math.min(x + (obj.width - hint.width) / 2, mainWindow.width - hint.width - 2), 5);
		hint.y = Math.min(y + obj.height + 10, mainWindow.height - hint.height - 5);
		hintDelayTimer.restart();
	}

	function hide() {
		hintDelayTimer.stop();
		opacityAnimation.to = 0;
		opacityAnimation.restart();
	}
}
