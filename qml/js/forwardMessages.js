.pragma library

var forwardMessages = [];
var observers = [];
var hasSelectedMessages = false;

function notifyObservers() {
    for (var i in observers) {
        var ob = observers[i];
        ob.callback(ob.obj);
    }
}

function clearSelectedMessages() {
    forwardMessages = [];
    hasSelectedMessages = false;
    notifyObservers();
}

function findMessage(id) {
    for (var i = 0; i < forwardMessages.length; ++i)
        if (forwardMessages[i].id == id)
            return i;
    return -1;
}

function toggleSelectedMessage(id, owner) {
    var i = findMessage(id);

    if (i == -1)
        forwardMessages.push({id: id, owner: owner});
    else
        forwardMessages.splice(i, 1);

    notifyObservers();
}

function addObserver(obj, callback) {
    observers.push({obj: obj, callback: callback});
    callback(obj);
}

function removeObserver(obj, owner) {
    for (var i in observers) {
        if (observers[i].obj == obj) {
            console.log("observer unregistered");
            observers.splice(i, 1);

            for (var j = 0; j < forwardMessages.length;) {
                if (forwardMessages[j].owner == owner)
                    forwardMessages.splice(j, 1);
                else
                    ++j;
            }

            notifyObservers();
            return;
        }
    }
}
