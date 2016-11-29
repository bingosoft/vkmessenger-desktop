import QtQuick 1.0
import ".";
	
Panel {
	id: contextMenu;
	width: 180;
	height: contextMenuView.height + 20;
	opacity: 0;
	visible: false;
    property alias model: contextMenuView.model;
    property alias delegate: contextMenuView.delegate;
    property int fontSize: 9;
	
	signal itemPressed(int index);

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: true;
		
		onEntered: {
			contextMenu.opacity = 1;
		}
		
		onExited: {
			contextMenu.opacity = 0;
		}

		ListView {
			id: contextMenuView;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			currentIndex: -1;
			anchors.margins: 1;
			anchors.topMargin: 10;
			model: ListModel { }
			delegate: ListViewDelegate {
				text: qsTr(model.text);
				fontSize: contextMenu.fontSize;
				
				onEntered: {
					contextMenuView.currentIndex = model.index;
				}
				
				onExited: {
					contextMenuView.currentIndex = -1;
				}
				
				onItemPressed: {
					contextMenu.itemPressed(model.index);
					contextMenu.opacity = 0;
				}
			}
		}
	}

	Behavior on opacity {
		animation: NumberAnimation {
			duration: 300;
		}
	}

	onOpacityChanged: {
		if (opacity == 0)
			visible = false;
	}

	function showAt(x, y) {
		contextMenu.x = x - 2;
		contextMenu.y = y - 2;
		visible = true;
		contextMenu.opacity = 0.85;
	}
    
    function hide() {
        opacity = 0;
    }

	function add(menuEntry) {
		contextMenuView.model.append({"text": menuEntry});
        updateHeight();
	}
    
    function updateHeight() {
        var height = 0;
        
        for (var i = 0; i < contextMenu.model.count; ++i)
            height += contextMenu.model.get(i).text != "--" ? 25 : 1;
        
        contextMenuView.height = height;
        console.log("height " + height);
    }
    
    Component.onCompleted: {
        updateHeight();
    }
}
