import QtQuick 1.0

import "../controls/"

Item {
    id: header;
    height: 60;

    property variant user;
    signal showStatusPanel;
    signal hideStatusPanel;
    property alias statusColor: statusBullet.color;

    Rectangle {
        anchors.fill: parent;

        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#7d9dc4";
            }
            GradientStop {
                position: 0.29;
                color: "#6d8cb8";
            }
            GradientStop {
                position: 1.00;
                color: "#44588b";
            }
        }
    }

    SmoothImage {
        id: avatarImage;
        anchors.left: parent.left;
        anchors.leftMargin: 5;
        width: 45;
        height: 45;
        anchors.verticalCenter: parent.verticalCenter;
        source: user && user.avatarLoaded ? "image://round/" + user.uid + "|" + user.avatar : "../images/unknown.png";
    }

    Rectangle {
        anchors.left: avatarImage.right;
        anchors.top: parent.top;
        anchors.bottom: parent.bottom;
        anchors.margins: 15;
        anchors.leftMargin: 5;
        width: 1;
        color: "#85a8cf"
    }
    
    Bullet {
        id: statusBullet;
        anchors.left: avatarImage.right;
        anchors.leftMargin: 12;
        anchors.verticalCenter: userNameText.verticalCenter;
    }

    Text {
        id: userNameText;
        anchors.left: statusBullet.right;
        anchors.leftMargin: 7;
        anchors.top: parent.top;
        anchors.topMargin: 10;
        anchors.right: parent.right;
        clip: true;
        style: Text.Raised;
        smooth: true;
        font.pointSize: 15;
        color: "#eee";
        text: user ? user.name : "Loading...";
    }

    LinkLabel {
        id: statusLabel;
        anchors.left: statusBullet.left;
        anchors.leftMargin: -3;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 3;
        height: 30;
        color: "#aaa";
        hoveredColor: "#eee";
        text: "Change status";
        
        onClicked: {
            showStatusPanel();
        }
        
        onHoveredChanged: {
            if (!hovered)
                hideStatusPanel();
        }
    }
    
    Rectangle {
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 1;
        height: 2;
        color: "#87abd7"
    }

    Rectangle {
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        height: 1;
        color: "#fff";
    }
    
    Rectangle {
        id: dimmer;
        anchors.top: parent.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        height: 15;
        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#d0d0d0";
            }
            GradientStop {
                position: 1.00;
                color: "#00ffffff";
            }
        }
    }
}
