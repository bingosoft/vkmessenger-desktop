import QtQuick 1.0

FocusScope {
	id: pageStackItem;
	property int currentIndex: -1;
	property int count: 0;

	ListModel {
		id: model;
	}

	onCurrentIndexChanged: {
		for (var i = 0; i < count; ++i) {
			getItem(i).opacity = currentIndex == i ? 1 : 0;
			getItem(i).focus = currentIndex == i;
		}
	}

	function addItem(item) {
		item.parent = pageStackItem;
		item.anchors.fill = pageStackItem;
		item.opacity = 0;
		model.append({"item": item});
		count++;
	}

	function getItem(index) {
		return model.get(index).item;
	}

	function clear() {
		model.clear();
		currentIndex = -1;
	}

	function removeItem(index) {
		model.remove(index);
		count--;

		if (count == 0)
			currentIndex = -1;
	}
}
