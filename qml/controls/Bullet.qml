import QtQuick 1.1

Rectangle {
	id: onlineRect;
	radius: width / 2;
	height: width;
	width: 8;
	color: "#6faec4"
	smooth: true;
	border.width: 1;
	border.color: Qt.lighter(color, 1.4);
	
	Behavior on scale {
		animation: NumberAnimation {
			duration: 500;
			easing.type: Easing.OutBack;
		}
	}
    
	Behavior on color {
		animation: ColorAnimation {
			duration: 500;
		}
	}
}
