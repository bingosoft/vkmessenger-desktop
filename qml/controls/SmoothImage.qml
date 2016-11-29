import QtQuick 1.1

Item {
	id: smoothImageItem;
	property string source;
	property string previousSource;
	property bool inversed;
	property int duration: 500;
	// don't forget to set known width & height

	Image {
		id: firstImage;
		anchors.fill: parent;
		opacity: smoothImageItem.inversed ? 1 : 0;
        fillMode: Image.PreserveAspectFit;
        asynchronous: true;
        smooth: true;

		Behavior on opacity {
			animation: NumberAnimation {
				duration: smoothImageItem.duration;
			}
		}
	}

	Image {
		id: secondImage;
		anchors.fill: parent;
		opacity: 1 - firstImage.opacity;
        fillMode: Image.PreserveAspectFit;
        smooth: true;
	}

	onSourceChanged: {
        updateSource();
	}
    
    function updateSource() {
		if (previousSource == source)
			return;

		previousSource = source;
		inversed = !inversed;

		if (inversed)
			firstImage.source = source;
		else
			secondImage.source = source;
    }

	Component.onCompleted: {
        updateSource();
	}
}
