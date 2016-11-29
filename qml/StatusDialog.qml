import QtQuick 1.0

Dialog {
    property alias text: text.text;
	height: text.paintedHeight + 50;
	width: text.paintedWidth + img.width + 40;

	AnimatedImage {
		id: img;
		source: "images/loading.gif";
		anchors.verticalCenter: parent.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: 15;
		width: sourceSize.width;
		height: sourceSize.height;
	}

	Text {
		id: text;
		anchors.left: img.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.margins: 10;
		wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
		horizontalAlignment: Text.AlignHCenter;
		verticalAlignment: Text.AlignVCenter;
		color: "#bbb";
		opacity: 1;
		font.pointSize: 13;
	}
	
	function show(message) {
		text.text = message;
		showDialog();
	}
}
