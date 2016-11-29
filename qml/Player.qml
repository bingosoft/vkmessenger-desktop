import QtQuick 1.0
import com.bs.vk.audio 1.0

Rectangle {
	id: player;
	property int progress: 0;
	property int bufferProgress: 0;
    property int playingTab: 0;
    property bool isRandom;
    property int repeatMode; // 0 - none, 1 - track, 2 - playlist
	anchors.bottom: parent.bottom;
	anchors.left: parent.left;
	anchors.right: parent.right;
	height: 63;
	border.width: 1;
	border.color: "#bbb"
	gradient: Gradient {
		GradientStop {
			position: 0.00;
			color: "white";
		}
		GradientStop {
			position: 1.00;
			color: "#bbb";
		}
	}

	signal playPressed;
	signal pausePressed;
	signal stopPressed;
	signal prevPressed;
	signal nextPressed;

	Behavior on progress {
		NumberAnimation {
			easing.type: Easing.OutCirc;
			duration: 250;
		}
	}

	Button {
		id: backButton;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: 10;
		hint: qsTr("Previous track");
		img: "images/player-back.png"

		onPressed: {
			prevPressed();
		}
	}

	Button {
		id: playButton;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.left: backButton.right;
		anchors.leftMargin: 3;
		hint: bassPlayer.state == BassPlayer.Playing ? qsTr("Pause") : qsTr("Play");
		img: bassPlayer.state == BassPlayer.Playing ? "images/player-pause.png" : "images/player-play.png";

		onPressed: {
			if (bassPlayer.state == BassPlayer.Playing)
				pausePressed();
			else
				playPressed();
		}
	}
	
//	Button {
//		id: stopButton;
//		anchors.verticalCenter: parent.verticalCenter;
//		anchors.left: playButton.right;
//		anchors.leftMargin: 3;
//		hint: qsTr("Stop");
//		img: "images/player-stop.png"

//		onPressed: {
//			stopPressed();
//		}
//	}

	Button {
		id: nextButton;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.left: playButton.right;
		anchors.leftMargin: 3;
		hint: qsTr("Next track");
		img: "images/player-next.png"

		onPressed: {
			nextPressed();
		}
	}

	Rectangle {
		id: playerPanel;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.left: nextButton.right;
		anchors.right: volume.left;
		anchors.topMargin: 10;
		anchors.bottomMargin: 10;
		anchors.leftMargin: 20;
		anchors.rightMargin: 20;
		border.width: 1;
		border.color: "#033354";
		radius: 6;
		smooth: true;

		gradient: Gradient {
			GradientStop {
				position: 0.00;
				color: "#5b6b80";
			}
			GradientStop {
				position: 1.00;
				color: "#223246";
			}
		}

		Rectangle {
			id: slider;
			border.color: "#3e4855"
			border.width: 1;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.leftMargin: 45;
			anchors.rightMargin: 45;
			anchors.bottomMargin: 8;
			smooth: true;
			radius: 5;
			height: 13;
			color: "#1d3047";

			Rectangle {
				id: bufferProgressRect;
				anchors.fill: parent;
				anchors.margins: 1;
				anchors.rightMargin: (100 - bufferProgress) / 100 * parent.width;
				border.color: "#263a51";
				border.width: 1;
				smooth: true;
				radius: 5;
				opacity: 0;
				NumberAnimation on opacity {
					duration: 1000;
					to: 1
				}

				gradient: Gradient {
					GradientStop {
						position: 0.00;
						color: "#ffae00";
					}
					GradientStop {
						position: 0.50;
						color: "#ffa11e";
					}
					GradientStop {
						position: 1.00;
						color: "#28394d";
					}
				}

				Behavior on anchors.rightMargin {
					NumberAnimation {
						duration: 200;
						easing.type: Easing.OutCirc;
					}
				}
			}

			Rectangle {
				id: sliderProgress;
				anchors.fill: parent;
				anchors.margins: 1;
				anchors.rightMargin: (100 - progress) / 100 * parent.width;
				border.color: "#263a51";
				border.width: 1;
				smooth: true;
				radius: 5;
				gradient: Gradient {
					GradientStop {
						position: 0.00;
						color: "#4e647e";
					}
					GradientStop {
						position: 0.50;
						color: "#32455d";
					}
					GradientStop {
						position: 1.00;
						color: "#28394d";
					}
				}
			}

			Image {
				id: knob
				source: "images/knob.png";
				width: sourceSize.width;
				height: sourceSize.height;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: sliderProgress.right;
				anchors.leftMargin: -8;
				
				Behavior on x {
					animation: NumberAnimation {
						duration: 300;
					}
				}
			}

			Image {
				id: opacityKnob;
				source: "images/knob.png";
				width: sourceSize.width;
				height: sourceSize.height;
				anchors.verticalCenter: parent.verticalCenter;
				opacity: 0;

				Behavior on opacity {
					NumberAnimation {
						duration: 200;
					}
				}
			}

			MouseArea {
				anchors.fill: parent;

				onPressed: {
					if (mouse.x < (slider.width - 3)) {
						opacityKnob.opacity = 0.7;
						opacityKnob.x = mouse.x - 7;
					}
				}

				onPositionChanged: {
					if (mouse.x >= 0 && mouse.x < parent.width)
						opacityKnob.x = mouse.x - 7;
				}

				onReleased: {
					setProgress((opacityKnob.x + 7) / parent.width * 100);
					opacityKnob.opacity = 0;
				}
			}
		}
		
		FloatingText {
			id: titleText;
			color: "white";
			font.pointSize: 10;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.margins: 5;
			anchors.top: parent.top;
			anchors.topMargin: 2;
			horizontalAlignment: Text.AlignHCenter;
			clip: true;
			text: bassPlayer.song;
		}
		
        Image {
            source: "images/player-leftdimmer.png";
            anchors.left: parent.left;
            anchors.top: parent.top;
            anchors.topMargin: 1;
            anchors.leftMargin: 5;
        }
		
        Image {
            source: "images/player-rightdimmer.png";
            anchors.right: parent.right;
            anchors.top: parent.top;
            anchors.topMargin: 1;
            anchors.rightMargin: 5;
        }

		Text {
			id: currentTimeText;
			color: "#ccc";
			font.family: "Tahoma";
			font.pointSize: 8;
			text: bassPlayer.currTime;
			anchors.left: parent.left;
			anchors.leftMargin: 5;
			anchors.right: slider.left;
			anchors.rightMargin: 5;
			anchors.top: slider.top;
			//horizontalAlignment: Text.AlignHCenter;
		}

		Text {
			id: totalTimeText;
			color: "#ccc";
			font.family: "Tahoma";
			font.pointSize: 8;
			text: bassPlayer.totalTime;
			anchors.left: slider.right;
			anchors.leftMargin: 5;
			anchors.right: parent.right;
			anchors.rightMargin: 5;
			anchors.top: slider.top;			
			horizontalAlignment: Text.AlignHCenter;
		}
	}

	Item {
		id: volume;
		property int progress: 100;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.right: parent.right;
		anchors.rightMargin: 20
		width: 100;
		height: volumeLow.sourceSize.height;

		Image {
			id: volumeLow;
			width: sourceSize.width;
			height: sourceSize.height;
			source: "images/volume-low.png";
			anchors.left: parent.left;
		}

		Rectangle {
			id: volumeSlider;
			anchors.top: parent.top;
			anchors.left: volumeLow.right;
			anchors.right: volumeHigh.left;
			anchors.margins: 8;
			anchors.topMargin: 2;
			height: 6;
			color: "#2c4564";
			smooth: true;
			radius: 5;
		}

		Image {
			id: volumeHigh;
			width: sourceSize.width;
			height: sourceSize.height;
			source: "images/volume-high.png";
			anchors.right: parent.right;
		}

		Image {
			id: volumeKnob
			source: "images/knob.png";
			width: sourceSize.width;
			height: sourceSize.height;
			anchors.top: parent.top;
			anchors.topMargin: -3;
			x: volume.progress / 100 * volumeSlider.width + volumeLow.width;
		}

		Image {
			id: opacityVolumeKnob
			source: "images/knob.png";
			width: sourceSize.width;
			height: sourceSize.height;
			anchors.top: parent.top;
			anchors.topMargin: -3;
			opacity: 0;

			Behavior on opacity {
				NumberAnimation {
					duration: 200;
				}
			}
		}

		Behavior on progress {
			NumberAnimation {
				easing.type: Easing.OutBack;
				duration: 250;
			}
		}

		MouseArea {
			anchors.fill: parent;

			onPressed: {
				if (mouse.x > (volumeLow.width + 8) && mouse.x < (volumeSlider.width + volumeLow.width)) {
					opacityVolumeKnob.opacity = 0.7;
					opacityVolumeKnob.x = mouse.x - 7;
				}
			}

			onPositionChanged: {
				if (mouse.x > (volumeLow.width + 8) && mouse.x < (volumeSlider.width + volumeLow.width + 5))
					opacityVolumeKnob.x = mouse.x - 7;
			}

			onReleased: {
				opacityVolumeKnob.opacity = 0;
				if (opacityVolumeKnob.x > 0)
					setVolumeProgress(Math.min(((opacityVolumeKnob.x - volumeLow.width) / volumeSlider.width * 100 - 3) * 1.1, 100));
			}
		}
	}
	
	Row {
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.rightMargin: 5;
		
		Button {
			img: repeatMode == 0 ? "images/repeat.png" : repeatMode == 1 ? "images/repeat_song.png" : "images/repeat_playlist.png";
			hint: qsTr("Repeat: ") + (repeatMode == 0 ? qsTr("Off") : repeatMode == 1 ? qsTr("Track") : qsTr("Playlist"));
			
			onPressed: {
				if (repeatMode == 2)
					repeatMode = 0;
				else
					repeatMode++;

				options.repeatMode = repeatMode;
			}
		}
		
		Button {
			img: !isRandom ? "images/random.png" : "images/norandom.png";
			hint: qsTr("Random: ") + (isRandom ? qsTr("On") : qsTr("Off"));
			
			onPressed: {
				options.random = !options.random;
				isRandom = options.random;
			}
		}
	}

	function setProgress(progress) {
		bassPlayer.position = progress;
	}

	function setVolumeProgress(progress) {
		volume.progress = progress;
		bassPlayer.volume = progress;
	}
}
