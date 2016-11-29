import QtQuick 1.0
import com.bs.vk.audio 1.0

FocusScope {
	id: queryTipsItem;
    property bool needVisible;
    property alias currentIndex: listView.currentIndex;
	height: listView.count * 25 + 6;
	opacity: needVisible && listView.count > 0 ? 0.7 : 0;
	
	signal itemPressed(string text);
	
	onActiveFocusChanged: {
		if (focus)
			listView.currentIndex = 0;
	}
	
	Panel {
		anchors.fill: parent;
		focus: true;
		
		ListView {
			id: listView;
			anchors.fill: parent;
			anchors.topMargin: 4;
			anchors.bottomMargin: 2;
			anchors.margins: 1;
			model: tipsModel;
			focus: true;
			delegate: ListViewDelegate {
				text: model.text;
				onItemPressed: {
					listView.currentIndex = model.index;
					var item = tipsModel.get(listView.currentIndex);
					queryTipsItem.itemPressed(item.text);
					hide();
				}
				
				onEntered: {
					listView.currentIndex = model.index;
				}
				
				onExited: {
					listView.currentIndex = -1;
				}
			}
		}
	}
	
	TipsModel {
		id: tipsModel;
	}
	
	Behavior on opacity {
		animation: NumberAnimation {
			duration: 700;
		}
	}
	
    Keys.onReturnPressed: {
		var item = tipsModel.get(listView.currentIndex);
		itemPressed(item.text);
		hide();
	}
	
	function isVisible() {
		return opacity > 0;
	}
	
	function hide() {
		needVisible = false;
		tipsModel.clear();
		tipsModel.cancel();
	}
	
	function loadTips(text) {
		tipsModel.loadTips(text);
		needVisible = true;
	}
}
