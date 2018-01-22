import QtQuick 1.0

FocusScope {
	width: 200;
	height: 80;
    
    MouseArea {
        anchors.fill: parent;
        hoverEnabled: true;
        
        onPressed: {
            mouse.accepted = true;
        }
    }

    BorderImage {
    	anchors.fill: parent;
    	anchors.topMargin: -16;
    	anchors.leftMargin: -16;
    	anchors.rightMargin: -17;
    	anchors.bottomMargin: -17;
        source: "../images/shadow.png"
        border.left: 18; 
        border.top: 18;
        border.right: 18;
        border.bottom: 18;
    }

	Rectangle {
		anchors.fill: parent;
		radius: 8;
		color: "#000";
		smooth: true;
		opacity: 0.8;
		border.color: "#666";
		border.width: 1;
	}
}
