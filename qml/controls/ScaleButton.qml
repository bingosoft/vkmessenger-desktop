import QtQuick 1.0

Item {
	id: button;
	property alias img: image.source;
	property bool hover: false;
	property string hint;
	height: image.sourceSize.height;
	width: image.sourceSize.width;
    property real inactiveOpacity: 0.7;
	signal pressed;

	Image {
		id: image;
		fillMode: Image.PreserveAspectFit;
		anchors.centerIn: parent;
		opacity: hover ? 1 : inactiveOpacity;
		scale: hover ? 1.15 : 1;
		smooth: true;

		Behavior on opacity {
			NumberAnimation {
				duration: 200;
			}
		}

		Behavior on scale {
			NumberAnimation {
				duration: 100;
			}
		}
	}

	Image {
		id: scaleImage;
		anchors.fill: parent;
		fillMode: Image.PreserveAspectFit;
		opacity: 0;
		smooth: true;
		scale: 1;
		source: image.source;

		Behavior on scale {
			NumberAnimation {
				duration: 400;

				onRunningChanged: {
					if (!running)
						scaleImage.scale = 1;
				}
			}
		}
	}

	NumberAnimation {
		id: opacityAnimation;
		target: scaleImage;
		properties: "opacity"
		to: 0;
		duration: 500;
	}

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: true;
		property bool showHint: true;
		onEntered: {
			hover = true;
//			if (showHint && hint.length > 0) {
//				hintItem.show(button);
//			}
		}

		onExited: {
			showHint = true;
			hover = false;
//			hintItem.hide();
		}

		onPressed: {
			showHint = false;
//			hintItem.hide();
			showPressEffect();
			button.pressed();
		}
	}

	function showPressEffect() {
		scaleImage.opacity = 0.7;
		opacityAnimation.restart();
		scaleImage.scale = 2;
	}
}
