import QtQuick 1.1
import "."
import "../controls/"

ContextMenu {
	id: statusPanel;
    property string statusColor: "#888";
    property int currentStatus: -1;
    property int prevStatus: -1;
    property bool isConnected: currentStatus == statusOnline || currentStatus == statusInvisible;
    
    property int statusOnline: 0;
    property int statusInvisible: 1;
    property int statusOffline: 2;
    property int statusDisconnected: 4;
    
    onCurrentStatusChanged: {
        statusColor = model.get(currentStatus).color;
        console.log("statusColor " + statusColor)
        options.status = currentStatus;
    }
    
	model: ListModel {
		ListElement {
			text: "Online";
			color: "#0a0";
		}
		
		ListElement {
			text: "Invisible";
			color: "#6faec4";
		}
        
		ListElement {
			text: "Disconnected";
			color: "#CC4D35";
		}
		
		ListElement {
			text: "--";
			color: "#000";
		}
		
		ListElement {
			text: "Logout";
			color: "#888";
		}
	}
	delegate: ListViewDelegate {
		id: delegate;
		text: qsTr(model.text);
		fontSize: 11;
		textLeftMargin: 30;
		
		Bullet {
			anchors.left: parent.left;
			anchors.leftMargin: 10;
			visible: !delegate.isSeparator;
			anchors.verticalCenter: parent.verticalCenter;
			color: model.color;
			width: 10;
		}
		
		onEntered: {
			contextMenuView.currentIndex = model.index;
		}
		
		onExited: {
			contextMenuView.currentIndex = -1;
		}
		
		onItemPressed: {
			contextMenu.itemPressed(model.index);
			contextMenu.opacity = 0;
            currentStatus = model.index;
		}
	}
}