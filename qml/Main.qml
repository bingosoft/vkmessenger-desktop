import QtQuick 1.0
import info.bingosoft.vkmessenger 1.0
import QtWebKit 1.0
import "."
import "./controls/"
import "./contacts/"

FocusScope {
	id: mainWindow;

    WebView {
        id: webView;
        anchors.fill: parent;
        visible: false;
        preferredHeight: height;
        preferredWidth: width;
        z: 2;

        onUrlChanged: {
            var s = new String(url);
            if (s.indexOf("#access_token=") > 0) {
                console.log("has token");
                var r = new RegExp("#access_token=([0-9a-f]+)");
                var res = r.exec(s);
                options.accessToken = res[1];
                statusPanel.currentStatus = statusPanel.statusOnline;
            }
        }
    }

    ContactsHeader {
        id: header;
        anchors.top: parent.top;
        anchors.left: parent.left;
        anchors.right: parent.right;
        statusColor: statusPanel.statusColor;
        z: 1;

        onShowStatusPanel: {
           statusPanel.showAt(50, 55);
        }

        onHideStatusPanel: {
            statusPanel.hide();
        }
    }

    Contacts {
        id: contacts;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: header.bottom;
        anchors.bottom: parent.bottom;
    }

    StatusPanel {
        id: statusPanel;
        z: 3;

        onCurrentStatusChanged: {
            var online = 1 << (statusPanel.statusOnline + 1) | 1 << (statusPanel.statusInvisible + 1);
            if (((1 << (currentStatus + 1)) & online) > 0 && ((1 << (prevStatus + 1)) & online) == 0) { // switching from offline to online mode
                console.log("online");
				vkApi.accessToken = settings.value("accessToken");
				vkApi.checkAuth();
            } else if (currentStatus == statusPanel.statusOffline) {
                vkApi.disconnect();
            } else if (currentStatus == statusPanel.statusDisconnected) {
                vkApi.disconnect();
                vkApi.accessToken = "";
                vkApi.checkAuth();
            }
            prevStatus = currentStatus;
        }
    }

    VkApi {
        id: vkApi;

        onAuthorized: {
            console.log("authorized");
            vkApi.makeQuery("users.get", {fields: "photo_50,status"}).completed.connect(onUserReceived);
            updateContactsTimer.restart();
            webView.visible = false;
            contacts.visible = true;
        }

        onNeedAuthorization: {
            console.log("need auth");
            webView.visible = true;
            contacts.visible = false;
            webView.url = "https://oauth.vk.com/authorize?client_id=3800364&redirect_uri=http://api.vk.com/blank.html&scope=messages,friends,audio,offline&display=wap&response_type=token";
        }

        onErrorReceived: {
            console.log("error " + error);
        }
    }

    Timer {
        id: updateOnlineTimer;
        triggeredOnStart: true;
        repeat: true;
        interval: 1000 * 60 * 15;
        running: statusPanel.currentStatus == statusPanel.statusOnline;

        onTriggered: {
            vkApi.makeQuery("account.setOnline", {}).completed.connect(function(data) { console.log("setting user online " + data); });
        }

        onRunningChanged: {
            if (!running)
				vkApi.makeQuery("account.setOffline", {}).completed.connect(function(data) { console.log("setting user offline " + data); });
        }
    }

    Timer {
        id: updateContactsTimer;
        triggeredOnStart: true;
        repeat: true;
        interval: 120000;
        running: statusPanel.isConnected;

        onTriggered: {
            vkApi.makeQuery("friends.get", {order:"hints"}).completed.connect(onFriendsReceived);
        }
    }

    Timer {
        id: postInitTimer;
        interval: 100;

        onTriggered: {
            init();
        }
    }

    function init() {
        context.startConversation.connect(contacts.startConversation);
        context.openUserPage.connect(contacts.openUserPage);
        context.removeFromFriends.connect(contacts.removeFromFriends);

        statusPanel.currentStatus = settings.value("status", statusPanel.statusOnline);
    }

    function onUserReceived(data) {
        console.log("user received " + data);
        var res = JSON.parse(data).response;
        console.log("setting curr user");
        header.user = usersManager.getUser(res[0].uid);
        context.currentUser = res[0].uid;
    }

    function onFriendsReceived(data) {
        var res = JSON.parse(data).response;
        console.log("friends received " + res.length);
        contacts.load(res);
    }

    Component.onCompleted: {
        postInitTimer.restart();
    }
}
