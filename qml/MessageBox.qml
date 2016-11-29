import QtQuick 1.0

Dialog {
	id: messageBox;
    property alias text: text.text;
    property alias icon: img.source;
	width: text.width + img.paintedWidth + 40;
	height: Math.max(text.paintedHeight, 40) + 30;

	Image {
		id: img;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: 15;
		width: sourceSize.width;
		height: sourceSize.height;
	}

	Text {
		id: text;
		anchors.left: img.right;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.margins: 10;
		width: Math.min(mainWindow.width - 200, 300);
		wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
		horizontalAlignment: Text.AlignHCenter;
		color: "#bbb";
		opacity: 1;
		font.pointSize: 13;
	}

	function show(title, img)
	{
		text.text = title;
		icon = img;
		showDialog();
	}
}
