import QtQuick 1.0
import com.bs.vk.audio 1.0

FocusScope {
	AudioItemsModel {
		id: audioItemsModel;

		onCountChanged: {
			nothingFoundText.opacity = count == 0 && statusDialog.isVisible() ? 0.6 : 0;
		}
	}

	ListView {
		id: playlistsHeaderView;
		anchors.left: parent.left;
		anchors.right: parent.right;
		height: 30;
		model: PlaylistModel { }
		delegate: Text {
			text: model.title;
		}
	}

	ListView {
		id: myAudiosView;
		property bool itemsLoaded: false;
		spacing: 2;
		z: -1;
		clip: true;
		anchors.fill: parent;
		model: audioItemsModel;

		delegate: FoundItemDelegate {
			onWallPost: {
				Script.lastAid = model.owner + "_" + model.aid;
				statusInputDialog.show("Введите Ваш комментарий:");
			}
		}

		Text {
			id: nothingFoundText;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.margins: 60;
			font.pointSize: 26;
			wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
			opacity: 0;
			text: "Не найдено ни одной записи. Попробуйте ввести другой запрос."

			Behavior on opacity {
				NumberAnimation {
					duration: 400;
				}
			}
		}
	}

	function refreshPlaylists() {
		playlistsHeaderView.model.refreshPlaylists();
	}
}
