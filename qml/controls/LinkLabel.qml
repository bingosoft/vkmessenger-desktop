import QtQuick 1.0

MouseArea {
	id: linkLabel;
    hoverEnabled: true;
	width: linkImage.width + linkText.width + 5;
	height: Math.max(linkImage.height, linkText.height);
	property alias source: linkImage.source;
	property alias text: linkText.text;
	property string hint;
    property color color;
    property color hoveredColor;
    property int pointSize: 9;
    property bool underLine: true;
    property bool hovered;

	signal clicked;

	Image {
		id: linkImage;
		opacity: 0.6;

		Behavior on opacity {
			NumberAnimation {
				duration: 300;
			}
		}
	}

	Text {
		id: linkText;
		anchors.left: linkImage.right;
		anchors.leftMargin: 2;
		font.pointSize: linkLabel.pointSize;
		anchors.verticalCenter: parent.verticalCenter;
		color: linkLabel.color;

		Behavior on color {
			ColorAnimation {
				duration: 300;
			}
		}
	}

	onEntered: {
		linkText.color = linkLabel.hoveredColor;
		linkImage.opacity = 1;
		linkText.font.underline = underLine;
        hovered = true;
	}

	onExited: {
		linkText.color = linkLabel.color;
		linkImage.opacity = 0.6;
		linkText.font.underline = false;
        hovered = false;
	}

	onPressed: {
		linkLabel.clicked();
	}
}

