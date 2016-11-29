import QtQuick 1.1
import "../controls"
import "../js/smiles.js" as Smiles;
import "."

Panel {
    id: smilesPanel;
	property bool active;
    opacity: 0;
    width: 400;
    height: 200;

    signal addSmile(string code);

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: true;

		GridView {
			id: smilesGrid;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.top: parent.top;
			anchors.bottom: recentSmilesView.top;
			anchors.margins: 10;
			anchors.bottomMargin: 8;
			cellWidth: 28;
			cellHeight: 28;
			clip: true;
			model: ListModel { id: smilesModel; }
			delegate: SmileDelegate {
				smileCode: model.code;
				width: smilesGrid.cellWidth;
				height: smilesGrid.cellHeight;

				onSmilePressed: {
					addSmile(smile);
				}
			}
		}

		Rectangle {
			anchors.left: parent.left;
			anchors.right: parent.right;
			color: "#666";
			height: 1;
			anchors.bottom: recentSmilesView.top;
			anchors.bottomMargin: 5;
		}

		ListView {
			id: recentSmilesView;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.leftMargin: 5;
			anchors.rightMargin: 5;
			orientation: ListView.Horizontal;
			height: 28;
			spacing: 5;
			model: ListModel {
				id: recentSmilesModel;

				ListElement { code: "D83DDE0A";	}
				ListElement { code: "D83DDE03";	}
				ListElement { code: "D83DDE09";	}
				ListElement { code: "D83DDE06";	}
				ListElement { code: "D83DDE1C";	}
				ListElement { code: "D83DDE0B";	}
				ListElement { code: "D83DDE0D";	}
				ListElement { code: "D83DDE0E";	}
				ListElement { code: "D83DDE12";	}
			}
			delegate: SmileDelegate {
				smileCode: model.code;
				width: recentSmilesView.height;
				height: recentSmilesView.height;

				onSmilePressed: {
					addSmile(smile);
				}
			}
		}

		onExited: {
			hide();
		}
	}

	Behavior on opacity {
		animation: NumberAnimation {
			duration: 250;
			easing.type: Easing.InOutCirc;
		}
	}

	Behavior on scale {
		animation: NumberAnimation {
			duration: 250;
			easing.type: Easing.InOutQuad;
		}
	}

    function show() {
		active = true;
        smilesPanel.opacity = 1;
    }

    function hide() {
		active = false;
        smilesPanel.opacity = 0;
    }

	Component.onCompleted: {
		for (var k in Smiles.smiles) {
			for (var i in Smiles.smiles[k]) {
				smilesModel.append({code: Smiles.smiles[k][i].toString(16).toUpperCase()});
			}
		}
	}
}
