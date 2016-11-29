import QtQuick 1.0
import "../controls/"

Rectangle {
	color: button.hover ?  "#111" : "#00000000";
	property string smileCode;
	signal smilePressed(string smile);

	Behavior on color {	animation: ColorAnimation { duration: 200; } }

	ScaleButton {
		id: button;
		img: "../images/emoji/" + smileCode + ".png";
		inactiveOpacity: 0.9;
		anchors.centerIn: parent;

		onPressed: {
			var smile = String.fromCharCode(parseInt(smileCode.substr(0, 4), 16));

			if (smileCode.length == 8)
				smile += String.fromCharCode(parseInt(smileCode.substr(4, 4), 16));

			smilePressed(smile);
		}
	}
}

