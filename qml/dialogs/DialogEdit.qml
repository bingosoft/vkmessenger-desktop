import QtQuick 1.1 // to target S60 5th Edition or Maemo 5
import info.bingosoft.vkmessenger 1.0
import "../js/smiles.js" as Smiles;
import "../controls";


FocusScope {
    id: inputArea;
    property int actualHeight: Math.max(Math.min(3, edit.lineCount), 1) * (edit.font.pixelSize + 4) + 32;
    height: 50;
    signal sendMessage(string text, bool forwardMessages);
    signal clearForwardMessages();
    signal smilesButtonPressed();
    property int forwardMessagesCount;

    Rectangle {
        anchors.fill: parent;

        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#f0f0f0";
            }
            GradientStop {
                position: 0.52;
                color: "#e6e6e6";
            }
            GradientStop {
                position: 1.00;
                color: "#ececec";
            }
        }
    }

    onActualHeightChanged: {
        heightAnimation.to = actualHeight;
        heightAnimation.restart();
    }

    Rectangle {
        anchors.left: parent.left;
        anchors.right: resendButton.left;
        anchors.verticalCenter: parent.verticalCenter;
        anchors.margins: 15;
        anchors.rightMargin: 5;
        height: inputArea.height - 22;
        radius: 8;
        smooth: true;
        border.width: 1;
        border.color: "#ccc";
        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#e4e4e4";
            }
            GradientStop {
                position: 0.50;
                color: "#d9d9d9";
            }
            GradientStop {
                position: 1.00;
                color: "#dedede";
            }
        }

        Flickable {
            id: flick
            anchors.fill: parent;
            anchors.margins: 5;
            anchors.leftMargin: 28;
            anchors.rightMargin: 8;
            contentWidth: edit.paintedWidth
            contentHeight: edit.paintedHeight
            clip: true
            property int endContentY;

            function ensureVisible(r)
            {
                 if (contentX >= r.x)
                     contentX = r.x;
                 else if (contentX+width <= r.x+r.width)
                     contentX = r.x+r.width-width;
                 if (contentY >= r.y)
                     contentY = r.y;
                 else if (contentY+(inputArea.actualHeight - 32) <= r.y+r.height)
                     contentY = r.y+r.height-(inputArea.actualHeight - 32);

//                    contentYAnimation.to = endContentY;
//                    contentYAnimation.restart();
            }

            Text {
                id: flashText;

                anchors.left: parent.left;
                anchors.right: parent.right;
                anchors.top: parent.top;
                opacity: 0;

                function flash(s) {
                    opacity = 1;
                    text = s;
                    flashTextAnimation.to = 0;
                    flashTextAnimation.restart();
                }

                NumberAnimation {
                    id: flashTextAnimation;
                    duration: 300;
                    target: flashText;
                    property: "opacity";
                    easing.type: Easing.OutCirc;
                }
            }

            TextEdit {
                 id: edit
                 width: flick.width;
                 height: flick.height;
                 focus: true
                 wrapMode: TextEdit.Wrap
                 selectByMouse: true;
                 textFormat: TextEdit.PlainText;
                 mouseSelectionMode: TextEdit.SelectWords;
                 color: "#333";
                 onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                 Keys.priority: Keys.BeforeItem;

                 Keys.onPressed: {
                    if (event.key == 16777221) //return on num pad
                        edit.sendMessage(false);
                    else if (event.modifiers & Qt.AltModifier)
                        dialogsItem.switchBetweenTabs(event);
                    else if (event.modifiers & Qt.ControlModifier && event.key == Qt.Key_W)
                        dialogsItem.closeDialog();
                    else if (event.key == Qt.Key_Space && text.length == 0 && hasUnreadMessages) {
                         vkApi.makeQuery("messages.markAsRead", {user_id: dialogId, start_message_id: 0});
                         hasUnreadMessages = false;
					} else
                        return;

                    event.accepted = true;
                 }

                 Keys.onReturnPressed: {
                    if (event.modifiers & Qt.ControlModifier) {
                        edit.text += '\n';
                        edit.select(text.length, text.length);
                    } else {
                        edit.sendMessage(false);
                    }
                 }

                 onTextChanged: {
                    if (!printNotificationTimeout.running && text.trim().length > 0) {
                         printNotificationTimeout.restart();
                         vkApi.makeQuery("messages.setActivity", {user_id: dialogId, type:"typing"});
                    }

                    if (hasUnreadMessages) {
                         vkApi.makeQuery("messages.markAsRead", {user_id: dialogId, start_message_id: 0});
                         hasUnreadMessages = false;
                    }
                 }

                 function sendMessage(forward) {
                     flashText.flash(edit.text);
                     inputArea.sendMessage(edit.text, forward);
                     edit.text = "";
                     printNotificationTimeout.stop();
                 }
            }

            Behavior on contentY {
                animation: NumberAnimation {
                    duration: 300;
                    easing.type: Easing.OutCirc;
                }
            }

            Behavior on contentHeight {
                animation: NumberAnimation {
                    duration: 300;
                    easing.type: Easing.OutBack;
                }
            }
        }

        ScaleButton {
            anchors.left: parent.left;
            anchors.top: parent.top;
            anchors.margins: 4;
            img: "../images/smile.png";

            onPressed: {
                smilesButtonPressed();
            }
        }

        NumberAnimation {
            id: heightAnimation;
            duration: 300;
            easing.type: Easing.OutCirc;
            target: inputArea;
            property: "height";
        }
    }

    Button {
        id: resendButton;
        text: "Переслать (" + forwardMessagesCount + ")";
        opacity: forwardMessagesCount > 0;
        anchors.verticalCenter: parent.verticalCenter;
        anchors.right: parent.right;
        anchors.rightMargin: 5;
        leftMargin: 2;
        rightMargin: 12;
        width: forwardMessagesCount > 0 ? (buttonWidth + 20) : 0;

        ScaleButton {
            img: "../images/close.png";
            anchors.right: parent.right;
            anchors.rightMargin: 4;
            anchors.verticalCenter: parent.verticalCenter;

            onPressed: {
                clearForwardMessages();
            }
        }

        onPressed: {
            edit.sendMessage(true);
        }

        Behavior on opacity {
            animation: NumberAnimation {
                duration: 300;
            }
        }

        Behavior on width {
            animation: NumberAnimation {
                duration: 400;
                easing.type: Easing.OutBack;
            }
        }
    }

    Rectangle {
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: parent.top;
        height: 1;
        color: "#fff";
    }

    Rectangle {
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: parent.top;
        anchors.topMargin: 1;
        height: 1;
        color: "#ddd";
    }

    function appendText(text) {
		edit.text = edit.text + text;
    }
}
