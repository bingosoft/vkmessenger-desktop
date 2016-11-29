import QtQuick 1.1

Rectangle {
    id: buttonItem;
    height: 34;
    property int rightMargin: 5;
    property int leftMargin: 5;
    width: buttonWidth;
    radius: 8;
    clip: true;
    smooth: true;
    color: hovered ? "#fff" : "#f1f1f1";
    gradient: Gradient {
        GradientStop {
            position: 0.00;
            color: Qt.lighter(buttonItem.color, 0.96);
        }
        GradientStop {
            position: 0.33;
            color: buttonItem.color;
        }
        GradientStop {
            position: 1.00;
            color: Qt.lighter(buttonItem.color, 0.90);
        }
    }
    border.width: 1;
    border.color: Qt.lighter(color, 0.8);
    
    signal pressed;
    
    property bool hovered;
    property alias text: innerText.text;
    property int buttonWidth: innerText.paintedWidth + leftMargin + rightMargin;
    
    Rectangle {
        anchors.fill: parent;
        radius: parent.radius;
        smooth: true;
        anchors.topMargin: 1;
        anchors.bottomMargin: 2;
        anchors.rightMargin: 2;
        anchors.leftMargin: 1;
        color: "#00000000";
        border.color: Qt.lighter(parent.color, 1.2);
        border.width: 1;
    }
    
    Text {
        id: innerText;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.leftMargin: leftMargin;
        anchors.rightMargin: rightMargin;
        anchors.verticalCenter: parent.verticalCenter;
        horizontalAlignment: Text.AlignHCenter;
        color: buttonItem.hovered ? "#333" : "#666";
    
        Behavior on color {
            animation: ColorAnimation {
                duration: 300;
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent;
        hoverEnabled: true;
        
        onPressed: {
            mouse.accepted = true;
            buttonItem.pressed();
        }
        
        onEntered: {
            buttonItem.hovered = true;
        }
        
        onExited: {
            buttonItem.hovered = false;
        }
    }
    
    Behavior on color {
        animation: ColorAnimation {
            duration: 300;
        }
    }
}
