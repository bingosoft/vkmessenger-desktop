import QtQuick 1.0

Rectangle {
	id: listViewDelegateItem;
	anchors.left: parent.left;
	anchors.right: parent.right;
	color:  model.index % 2 == 0 ? "#000" : "#222";
	height: 25;
    property bool isCurrentItem: ListView.isCurrentItem;
    property alias text: text.text;
	property alias textLeftMargin: text.x;
    property alias fontSize: text.font.pointSize;
	signal itemPressed();
	signal entered();
	signal exited();
	
	Rectangle {
		anchors.fill: parent;
		opacity: isCurrentItem ? 1 : 0;
		gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#08a8f7";
            }
            GradientStop {
                position: 0.495;
                color: "#0087db";
            }
            GradientStop {
                position: 0.50;
                color: "#0068ca";
            }
            GradientStop {
                position: 1.00;
                color: "#027cc8";
            }
        }
            
		Behavior on opacity {
			animation: NumberAnimation {
				duration: 300;
			}
		}
	}
	
	Text { 
		id: text;
		anchors.verticalCenter: parent.verticalCenter;
		x: 10;
		font.pointSize: 12;
		color: "#fff";
		
		Behavior on x {
			animation: NumberAnimation {
				duration: 300;
				easing.type: Easing.OutBack;
			}
		}
	}
	
	MouseArea {
		anchors.fill: parent;
		hoverEnabled: true;
		
		onEntered: {
			listViewDelegateItem.entered();
		}
		
		onPressed: {
			itemPressed();
		}
		
		onExited: {
			listViewDelegateItem.exited();
		}
	}
}
