import QtQuick 1.0

MouseArea {
	id: foundItemDelegate;
	height: 45;
	anchors.left: parent.left;
	anchors.right: parent.right;
	anchors.margins: 2;
	hoverEnabled: true;
	clip: true;
	acceptedButtons: Qt.RightButton | Qt.LeftButton;
	
    property bool hovered;
    property bool myAudioDelegate;
	property color baseColor: model.isPlaying || model.isPaused ? "#BACAFF" : model.isPlayed ? "#d0d0e5" : "#e0e0e0";
    
	signal wallPost;
	signal showLyrics(string lyricsId);
	signal playPressed;
	signal pausePressed;
	signal downloadPressed;
	signal artistPressed(string artist);
	signal addToPlaylist();
	signal removeAudio();
	signal selectPlaylist();
	signal mouseLeftPressed(int x, int y);
	signal mouseRightPressed(int x, int y);
    
	Rectangle {
		anchors.fill: parent;
		border.width: 1;
		border.color: "#aaa";
		radius: 5;
		smooth: true;
		gradient: Gradient {
			GradientStop {
				position: 0;
				color: Qt.lighter(foundItemDelegate.baseColor, 1.1);
			}
	
			GradientStop {
				position: 0.49;
				color: foundItemDelegate.baseColor;
			}
	
			GradientStop {
				position: 0.5;
				color: Qt.lighter(foundItemDelegate.baseColor, 0.95);
			}
	
			GradientStop {
				position: 1.00;
				color: Qt.lighter(foundItemDelegate.baseColor, 0.92);
			}
		}
		
		Button {
			id: playButton;
			anchors.left: parent.left;
			anchors.top: parent.top;
			anchors.bottom: parent.bottom;
			anchors.leftMargin: 3;
			anchors.topMargin: 5;
			anchors.bottomMargin: 5;
			hint: model.isPlaying ? qsTr("Pause") : qsTr("Play");
			img: model.isPlaying ? "images/player-pause.png" : "images/player-play.png";
			onPressed: {
				if (model.isPlaying)
					foundItemDelegate.pausePressed();
				else
					foundItemDelegate.playPressed();
			}
		}
	
		Text {
			id: indexText;
			anchors.top: parent.top;
			anchors.topMargin: 5;
			anchors.left: playButton.right;
			anchors.leftMargin: 5;
			font.pointSize: 11;
			color: "#777";
			text: ((model.index + 1) / 10 < 1  ? "0" : "") + (model.index + 1) + ".";
		}
		
		Text {
			id: artistText;
			font.pointSize: 11;
			anchors.left: indexText.right;
			anchors.leftMargin: 3;
			anchors.top: parent.top;
			anchors.topMargin: 5;
			width: Math.min(paintedWidth, 300);
			clip: true;
			text: model.artist;
			property string hint: model.artist + " - " + model.title;
			
			MouseArea {
				anchors.fill: parent;
				hoverEnabled: true;
				
				onEntered: hintItem.show(title);
				onExited: hintItem.hide();
				
				onPressed: {
					artistPressed(artistText.text);
				}
			}
		}
	
		Text {
			id: title;
			font.pointSize: 11;
			anchors.left: artistText.right;
			anchors.top: parent.top;
			anchors.topMargin: 5;
			anchors.right: duration.left;
			anchors.rightMargin: 5;
			color: "#444";
			clip: true;
			text: " - " + model.title;
			property string hint: model.artist + " - " + model.title;
	
			MouseArea {
				anchors.fill: parent;
				hoverEnabled: true;
	
				onEntered: hintItem.show(title);
				onExited: hintItem.hide();
			}
		}
	
		Text {
			id: duration;
			font.pointSize: 11;
			anchors.right: downloadButton.left;
			anchors.top: parent.top;
			anchors.topMargin: 5;
			clip: true;
			text: model.duration;
		}
	
		Text {
			id: size;
			font.pointSize: 9;
			anchors.left: indexText.left;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: 5;
			color: "#444";
			text: model.size;
		}
	
		Text {
			id: bitrate;
			font.pointSize: 9;
			anchors.left: size.right;
			anchors.leftMargin: 10;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: 5;
			text: model.bitrate;
			color: "#444";
		}
		
		Text {
			id: album;
			visible: myAudioDelegate;
			font.pointSize: 9;
			anchors.right: downloadButton.left;
			anchors.rightMargin: 64;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: 5;
			text: { return playListModel.getAlbumById(model.albumId); }
			color: "#666";
			
			Behavior on color {
                animation: ColorAnimation { 
					duration: 300;
				}
			}
		}

		MouseArea {
			anchors.fill: album;
			hoverEnabled: true;

			onEntered: {
				album.color = "#09c";
				album.font.underline = true;
			}

			onExited: {
				album.color = "#666";
				album.font.underline = false;
			}

			onPressed: {
				selectPlaylist();
			}
		}
		
		Row {
			id: actionsRow;
			anchors.right: downloadButton.left;
			anchors.rightMargin: 0;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: 4;
			spacing: 6;
			opacity: hovered ? 1 : 0;
	
			Button {
				img: "images/remove.png";
				hint: qsTr("Remove");
				visible: myAudioDelegate;
		
				onPressed: {
					removeAudio();
				}
			}

			Button {
				img: "images/add.png";
				hint: qsTr("Add to playlist");
				visible: !myAudioDelegate;
		
				onPressed: {
					addToPlaylist();
				}
			}
		
			Button {
				img: "images/lyrics.png";
				hint: qsTr("View lyrics");
				visible: model.lyrId != 0;
		
				onPressed: {
					showLyrics(model.lyrId);
				}
			}

			Button {
				img: "images/heart.png";
				hint: qsTr("Post on VK wall");
		
				onPressed: {
					wallPost();
				}
			}
			
			Behavior on opacity {
				animation: NumberAnimation {
					duration: 300;
				}
			}
		}
	
		Button {
			id: downloadButton;
			img: "images/download.png";
			anchors.right: parent.right;
			anchors.rightMargin: 4;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: 3;
			hint: qsTr("Download");
			opacity: hovered ? 1 : 0.7;
	
			onPressed: {
				downloadPressed();
			}
			
			Behavior on opacity {
				animation: NumberAnimation {
					duration: 300;
				}
			}
		}
	}
	
	Behavior on baseColor {
		animation: ColorAnimation {
			duration: 300;
		}
	}
	
	onDoubleClicked: {
		playButton.showPressEffect();
		foundItemDelegate.playPressed();
	}
	
	onEntered: {
		hovered = true;
	}
	
	onExited: {
		hovered = false;
	}
	
	onPressed: {
		if (mouse.button == Qt.LeftButton)
			mouseLeftPressed(mouse.x, mouse.y);
		if (mouse.button == Qt.RightButton)
			mouseRightPressed(mouse.x, mouse.y);
		else
			mouse.accepted = false;
	}
}
	
