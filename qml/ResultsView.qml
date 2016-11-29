import QtQuick 1.0
import com.bs.vk.audio 1.0

Item {
	id: resultsViewItem;
    property int topMargin;
	property bool isMyAudios;
	property int lastPlayedItemIndex: -1;
	signal scrolledToEnd;
    property alias contentY: resultsView.contentY;
    property alias contentHeight: resultsView.contentHeight;
    property alias count: resultsView.count;
    property string aid;
	
	ListView {
		id: resultsView;
		spacing: 2;
		clip: true;
		model: audioItemsModel;
		anchors.fill: parent;
		anchors.topMargin: topMargin;
		
		property bool scrollNotified;
		
		delegate: FoundItemDelegate {
			id: delegate;
			myAudioDelegate: isMyAudios;
			
			onWallPost: {
				resultsViewItem.aid = model.owner + "_" + model.aid;
				inputDialog.accepted.connect(wallPostAccepted);
				inputDialog.refused.connect(wallPostRefused);
				inputDialog.show(qsTranslate("qml", "Enter your comment:"));
			}
			
			onAddToPlaylist: {
				if (options.defaultAccount) {
					messageBox.show(qsTranslate("qml", "Adding to playlist function is disabled<br>Please go to the settings and login under your VK account!"), "images/error.png");
					messageBox.postHide(5);
				} else {
					vk.addToMyAudios(model.aid, model.owner);
					refreshMyAudiosTimer.restart();
					messageBox.show("<b>" + model.artist + " - " + model.title + "</b><br>" + qsTranslate("qml", "sucessfully added to playlist"), "images/check.png");
					messageBox.postHide(1.5);
				}
			}
			
			onRemoveAudio: {
				vk.removeAudio(model.aid, model.owner);
				audioItemsModel.remove(model.index);
			}
			
			onShowLyrics: {
				vk.getLyrics(lyricsId);
				lyricsTitle.text = model.artist + " - " + model.title;
			}
	
			onPlayPressed: {
				play(model.index);
				player.playingTab = pageStack.currentIndex;
			}
	
			onPausePressed: {
				var audioItem = audioItemsModel.get(model.index);
				audioItem.pause();
			}
			
			onDownloadPressed: {
				var audioItem = audioItemsModel.get(model.index);
				downloadsPage.add(audioItem);
				stats.audioDownloaded(audioItem.owner + "_" + audioItem.aid);
				messageBox.show("<b>" + audioItem.artist + " - " + audioItem.title + "</b><br>" + qsTranslate("qml", "sucessfully added to downloads"), "images/check.png");
				messageBox.postHide(1.5);
			}
			
			onArtistPressed: {
				if (textInput.text == artist) {
					textInput.text = "";
				} else {
					textInput.text = artist;
					searchAudio();
				}
			}
			
			onSelectPlaylist: {
				if (selectPlaylistPanel.delegate == delegate) {
					if (selectPlaylistPanel.opacity == 0) {
						selectPlaylistPanel.visible = true;
						selectPlaylistPanel.opacity = 1;
					} else {
						selectPlaylistPanel.opacity = 0;
					}
				} else {
					selectPlaylistPanel.delegate = delegate;
					selectPlaylistPanel.opacity = 1;
					selectPlaylistPanel.visible = true;
					selectPlaylistPanel.index = model.index;
					for (var i = 0; i < playListModel.count; ++i) {
						if (playListModel.get(i).albumId == model.albumId) {
							selectPlaylistPanel.checkedIndex = i;
							return;
						}
					}
				}
			}
	
 			onMouseLeftPressed: {
				contextMenu.opacity = 0;
			}
			
			onMouseRightPressed: {
				contextMenu.showAt(x, delegate.y + y - resultsView.contentY + resultsView.y);
			}
			
			onHoveredChanged: {
				if (!hovered || selectPlaylistPanel.delegate != delegate)
					selectPlaylistPanel.opacity = 0;
			}
			
			ListView.onRemove:
				SequentialAnimation {
					PropertyAction { target: delegate; property: "ListView.delayRemove"; value: true }
					ParallelAnimation {
						NumberAnimation { target: delegate; property: "height"; to: 0; duration: 500; easing.type: Easing.InCirc; }
						NumberAnimation { target: delegate; property: "opacity"; to: 0; duration: 600; easing.type: Easing.OutCirc; }
					}
					PropertyAction { target: delegate; property: "ListView.delayRemove"; value: false }
				}
		}
	
		Text {
			id: nothingFoundText;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.margins: 60;
			font.pointSize: 22;
			wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
			horizontalAlignment: Text.AlignHCenter;
			opacity: 0;
			color: "#999";
			text: qsTr("No audios found!");
	
			Behavior on opacity {
				NumberAnimation {
					duration: 400;
				}
			}
		}

		Rectangle {
			anchors.bottom: resultsView.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			height: 20;
			gradient: Gradient {
				GradientStop {
					color: "#00cccccc";
					position: 0;
				}

				GradientStop {
					color: "#cccccc";
					position: 1;
				}
			}
			
			Behavior on opacity {
				animation: NumberAnimation {
					duration: 300;
				}
			}
		}
		
		ScrollBar {	
			view: resultsView;
		}
		
		Timer {
			id: refreshMyAudiosTimer;
			interval: 3000;
			
			onTriggered: {
				refreshMyAudio();
			}
		}
		
		onContentYChanged: {
			if (contentY >= (contentHeight - height) && !scrollNotified) {
				scrolledToEnd();
				scrollNotified = true;
			} else if (contentY < (contentHeight - height) && scrollNotified) {
				scrollNotified = false;
			}
		}
	
		Behavior on contentY {
			animation: NumberAnimation {
				duration: 300;
				easing.type: Easing.OutCirc;
			}
		}
	}
	
	Panel {
		id: selectPlaylistPanel;
        property Item delegate;
		property int index;
		property int checkedIndex;
		anchors.right: parent.right;
		anchors.rightMargin: 5;
		y: delegate ? (delegate.y - resultsView.contentY + delegate.height + resultsView.y) : -111;
		width: 200;
		height: playListView.count * 25 + 10;
		opacity: 0;
		visible: false;
		
		MouseArea {
			anchors.fill: parent;
			hoverEnabled: true;
			
			onEntered: {
				selectPlaylistPanel.opacity = 1;
			}
			
			onExited: {
				selectPlaylistPanel.opacity = 0;
			}
		
			ListView {
				id: playListView;
				anchors.fill: parent;
				anchors.topMargin: 5;
				anchors.bottomMargin: 5;
				anchors.margins: 1;
				model: playListModel;
				clip: true;
		
				delegate: ListViewDelegate {
					textLeftMargin: selectPlaylistPanel.checkedIndex == model.index ? 27 : 10;
					text: model.title;
					fontSize: 9;
					
					Image {
						anchors.left: parent.left;
						anchors.leftMargin: 7;
						anchors.verticalCenter: parent.verticalCenter;
						source: "images/checked.png";
						opacity: selectPlaylistPanel.checkedIndex == model.index ? 1 : 0;
						
						Behavior on opacity {
							animation: NumberAnimation {
								duration: 300;
							}
						}
					}
					
					onEntered: {
						playListView.currentIndex = model.index;
					}
					
					onExited: {
						playListView.currentIndex = -1;
					}
				
					onItemPressed: {
						var albumId = playListModel.get(model.index).albumId;
						var audioItem = audioItemsModel.get(selectPlaylistPanel.index);
						audioItem.albumId = albumId;
						audioItemsModel.updateItem(selectPlaylistPanel.index);
						vk.setAudioAlbum(albumId, audioItem.aid);
						selectPlaylistPanel.opacity = 0;
						selectPlaylistPanel.checkedIndex = model.index;
					}
				}
			}
		}
		
		onYChanged: {
			if (y == -111)
				opacity = 0;
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
	}
	
	ContextMenu {
		id: contextMenu;
		width: 220;
			
		onItemPressed: {
			if (index == 0) {
				for (var i = 0; i < audioItemsModel.count; ++i)
					downloadsPage.add(audioItemsModel.get(i));

				messageBox.show(qsTranslate("qml", "All audio results<br>were sucessfully added to downloads"), "images/check.png");
				messageBox.postHide(1.5);
				contextMenu.opacity = 0;
			} else if (index == 1 && !addAudiosTimer.running) {
				addAudiosTimer.currentIndex = 0;
				addAudiosTimer.restart();
			}
		}
	}

	Timer {
		id: addAudiosTimer;
		triggeredOnStart: true;
		interval: 1500;
		repeat: true;
		property int currentIndex;

		onTriggered: {
			addAudioToPlaylist(currentIndex);
		}
	}
	
	ListModel {
		id: lastPlayedItems;
	}

	AudioItemsModel {
		id: audioItemsModel;
	}
			
	Behavior on topMargin {
		animation: NumberAnimation {
			duration: 400;
			easing.type: Easing.OutCirc;
		}
	}

	Component.onCompleted: {
		contextMenu.add(qsTr("Download all"));
		if (!isMyAudios)
			contextMenu.add(qsTr("Add all tracks to playlist"));
	}

	function load(data) {
		audioItemsModel.loadModel(data);
		audioItemsModel.calcBitrate();
		nothingFoundText.opacity = audioItemsModel.count == 0 ? 0.6 : 0;
		resultsView.currentIndex = -1;
	}

	function loadFromWall(data) {
		audioItemsModel.loadFromWall(data);
		var aids = "";
		for (var i = 0; i < audioItemsModel.count; ++i) {
			var item = audioItemsModel.get(i);
			aids += item.owner + "_" + item.aid;
			if (i != audioItemsModel.count - 1)
				aids += ",";
		}

		if (audioItemsModel.count > 0) {
			statusDialog.show(qsTranslate("qml", "Getting full audio info..."));
			vk.getAudiosById(aids);
		}
		
		nothingFoundText.opacity = audioItemsModel.count == 0 ? 0.6 : 0;
		resultsView.currentIndex = -1;
	}
	
	function updateExistingAudioItems(data) {
		console.log(data);
		audioItemsModel.updateExistingAudioItems(data);
		audioItemsModel.calcBitrate();
	}

	function playPrev() {
		if (player.isRandom) {
			if (lastPlayedItemIndex > 0) {
				lastPlayedItemIndex--;
				play(lastPlayedItems.get(lastPlayedItemIndex).index);
				resultsView.positionViewAtIndex(lastPlayedItems.get(lastPlayedItemIndex).index, ListView.Center);
			}
		} else {
			play(resultsView.currentIndex - 1);
		}
	}

	function playNext() {
		if (player.repeatMode == 1)
			play(resultsView.currentIndex);
		else if (player.isRandom) {
			if (lastPlayedItemIndex >= lastPlayedItems.count - 1) {
				var i = -1;
				var allPlayed = true;
				for (var i = 0; i < audioItemsModel.count; ++i) {
					if (!audioItemsModel.get(i).isPlayed) {
						allPlayed = false;
						break;
					}
				}
				if (allPlayed) {
					if (player.repeatMode == 0)
						return;
					
					for (var i = 0; i < audioItemsModel.count; ++i) {
						audioItemsModel.get(i).isPlayed = false;
						audioItemsModel.updateItem(i);
					}
				}
				do {
					i = Math.round(Math.random() * 15687982) % audioItemsModel.count;
				} while (audioItemsModel.get(i).isPlayed);
				lastPlayedItems.append({"index": i});
				lastPlayedItemIndex++;
				play(i);
				resultsView.positionViewAtIndex(i, ListView.Center);
			} else {
				lastPlayedItemIndex++;
				play(lastPlayedItems.get(lastPlayedItemIndex).index);
				resultsView.positionViewAtIndex(lastPlayedItems.get(lastPlayedItemIndex).index, ListView.Center);
			}
		} else {
			play(resultsView.currentIndex + 1);
		}
	}

	function play(index) {
		if (index >= 0 && index < audioItemsModel.count) {
			var audioItem = audioItemsModel.get(index);
			if (!audioItem.isPaused) {
    			resultsView.currentIndex = index;
				if (options.sendCurrentSongInStatus)
					vk.setStatus(audioItem.owner, audioItem.aid);
				if (lastFM.isAuthorized())
					lastFM.updateNowPlaying(audioItem.artist, audioItem.title, audioItem.seconds);
				stats.audioPlayed(audioItem.owner + "_" + audioItem.aid);
				lastFM.artistGetInfo(audioItem.artist);
				var res = {
					"xesam:artist": audioItem.artist,
					"xesam:title": audioItem.title,
					"mpris:artUrl": "file://" + context.appPath + "/icon64.png"
				};
				mpris.notify("Metadata", res);
			}
			audioItem.play();
		}
	}
	
	function filterItems(expr) {
		audioItemsModel.filterByWords(expr);
	}

	function clear() {
		lastPlayedItemIndex = 0;
		lastPlayedItems.clear();
		audioItemsModel.clear();
	}
	
	function wallPostAccepted(message) {
		vk.wallPost(resultsViewItem.aid, message); 
		inputDialog.accepted.disconnect(wallPostAccepted);
		inputDialog.refused.disconnect(wallPostRefused);
	}
	
	function wallPostRefused() {
		textInput.forceActiveFocus();
		inputDialog.accepted.disconnect(wallPostAccepted);
		inputDialog.refused.disconnect(wallPostRefused);
	}

	function addAudioToPlaylist(index) {
		if (index < audioItemsModel.count && index < 20) {
			var item = audioItemsModel.get(index);
			vk.addToMyAudios(item.aid, item.owner);
			statusDialog.show(qsTranslate("qml", "Adding audios to playlist<br>") + item.artist + " - " + item.title);
			addAudiosTimer.currentIndex++;
		} else {
			statusDialog.hide();
			messageBox.show(qsTranslate("qml", "First 20 audio results<br>were sucessfully added to your playlist"), "images/check.png");
			messageBox.postHide(1.5);
			refreshMyAudiosTimer.restart();
			addAudiosTimer.stop();
		}
	}
}
