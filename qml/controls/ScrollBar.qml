import QtQuick 1.0

Item {
    property Flickable view;
	anchors.right: view.right;
	anchors.top: view.top;
	anchors.bottom: view.bottom;
	anchors.rightMargin: 1;
	width: 8;
	
    property bool hovered;
	property int minHeight: 40;
    property int contentHeight: view.contentHeight;
	
	Rectangle {
		id: scrollRect;
		anchors.right: parent.right;
		anchors.left: parent.left;
		color: "#000";
		radius: 4;
		height: Math.max(view.height / contentHeight * view.height, minHeight);
		opacity: contentHeight > view.height ? mouseArea.pressed || parent.hovered ? 0.5 : 0.3 : 0;
		border.width: 1;
		border.color: "#888";
		smooth: true;
		
		onYChanged: {
			if (mouseArea.pressed)
				view.contentY = (contentHeight - view.height) * y / (parent.height - height);
		}
		
		Behavior on opacity {
			animation: NumberAnimation {
				duration: 300;
			}
		}
        
		Behavior on height {
			animation: NumberAnimation {
				duration: 300;
			}
		}
	}
	
	MouseArea {
		id: mouseArea;
		anchors.fill: scrollRect;
        drag.target: scrollRect;
        drag.axis: Drag.YAxis
        drag.minimumY: 0
        drag.maximumY: parent.height - scrollRect.height;
        hoverEnabled: true;
        
        onEntered: parent.hovered = true;
        onExited: parent.hovered = false;
	}
	
	function moveScrollbar() {
		if (!mouseArea.pressed)
			scrollRect.y = view.contentY / (contentHeight - view.height) * (view.height - scrollRect.height);
	}
	
	Component.onCompleted: {
		view.contentYChanged.connect(moveScrollbar);
	}
}
