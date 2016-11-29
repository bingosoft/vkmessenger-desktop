import QtQuick 1.0

Panel {
	id: dialog;
	width: 200;
	height: 80;
	visible: scale > 0.04;
	scale: 0;

	Behavior on scale {
		NumberAnimation {
			duration: 400;
			easing.type: Easing.OutCirc;
		}
	}

	Timer {
		id: hideTimer;

		onTriggered: {
			blackRect.opacity = 0;
			dialog.scale = 0;
		}
	}
	
	function showDialog() {
		dialog.scale = 1;
		blackRect.opacity = 0.3;
	}

	function hideDialog(seconds) {
		hideTimer.interval = seconds * 1000;
		hideTimer.restart();
	}

	function show() {
		showDialog();
	}
	
	function hide() {
		hideDialog(0);
	}
	
	function postHide(seconds) {
		hideDialog(seconds);
	}

	function isVisible() {
		return dialog.scale > 0.9;
	}
}
