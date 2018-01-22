import QtQuick 1.1

Item {
	property real ratio: 1.0 * sourceWidth / sourceHeight;
	property string source;
	property string bigSource;
	property int sourceWidth;
	property int sourceHeight;
    property real rowHeight;
    property int borderWidth;
    height: rowHeight > 0 ? rowHeight : 150;
    width: ratio * height;

	Image {
		id: image;
		anchors.fill: parent;
		smooth: true;
		fillMode: Image.PreserveAspectCrop;
		clip: true;
		opacity: status == Image.Ready ? 1 : 0.01;
        source: parent.width > 604 ? parent.bigSource : parent.source;

		Behavior on opacity {
			animation: NumberAnimation {
				duration: 300;
			}
		}
	}

	Rectangle {
		anchors.fill: parent;
        color: image.status == Image.Ready ? "#00999999" : "#999";
		border.width: parent.borderWidth;
        border.color: image.status == Image.Ready ? "#66666666" : "#666";

		Behavior on color {
			animation: ColorAnimation {
				duration: 300;
			}
		}
	}
}
