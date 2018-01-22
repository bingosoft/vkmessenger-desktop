#-------------------------------------------------
#
# Project created by QtCreator 2010-09-17T15:18:22
#
#-------------------------------------------------

QT       += core widgets gui network script declarative

TEMPLATE = app

MOC_DIR = ./obj/
OBJECTS_DIR = ./obj/
UI_SOURCES_DIR = ./obj/
UI_HEADERS_DIR = ./obj/
RCC_DIR = ./obj/

TARGET = ./build/vkmessenger
RESOURCES = res.qrc

win32 {
#	LIBS += lib/bass.lib
#   RC_FILE = icon.rc
}

unix:!mac {
	HARDWARE_PLATFORM = $$system(uname -m)
	QMAKE_LFLAGS += -Wl,--rpath=\\\$\$ORIGIN/lib
	QMAKE_LFLAGS_RPATH=
	LIBS+=-L./lib/
	contains(HARDWARE_PLATFORM, x86_64) {
		TARGET = ./build_x64/vkmessenger
#		LIBS += -lbass_x64
		message("linux x64 build")
	} else {
#		LIBS += -lbass
		message("linux i386 build")
	}
}

HEADERS  += \
	ui/mainwindow.h \
    api/vkapi.h \
    version.h \
    roundimageprovider.h \
    models/contactsmodel.h \
    src/useritem.h \
    src/usersmanager.h \
    src/chatitem.h \
    models/dialogsheadermodel.h \
    src/settings.h \
    ui/dialogs.h

SOURCES += \
	main.cpp \
	ui/mainwindow.cpp \
    api/vkapi.cpp \
    roundimageprovider.cpp \
    models/contactsmodel.cpp \
    src/usersmanager.cpp \
    models/dialogsheadermodel.cpp \
    src/settings.cpp \
    ui/dialogs.cpp

FORMS    += \
	ui/mainwindow.ui \
    ui/dialogs.ui

OTHER_FILES += \
    qml/Main.qml \
    \
    qml/controls/LinkLabel.qml \
    qml/controls/ScrollBar.qml \
    qml/controls/ToolButton.qml \
    qml/controls/Button.qml \
    qml/controls/ScaleButton.qml \
    qml/controls/SmoothImage.qml \
    qml/controls/PageStack.qml \
    qml/controls/ContextMenu.qml \
    qml/controls/Panel.qml \
    qml/controls/ListViewDelegate.qml \
    qml/controls/Bullet.qml \
\
    qml/contacts/ContactsHeader.qml \
    qml/contacts/Contacts.qml \
    qml/contacts/ContactsDelegate.qml \
    qml/contacts/StatusPanel.qml \
\
    qml/dialogs/Dialogs.qml \
    qml/dialogs/DialogsHeader.qml \
    qml/dialogs/DialogEdit.qml \
    qml/dialogs/Dialog.qml \
    qml/dialogs/MessageDelegate.qml \
    qml/dialogs/SmilesPanel.qml \
    qml/dialogs/PhotoAttachment.qml \
    qml/dialogs/ForwardMessageDelegate.qml \
\
    qml/js/forwardMessages.js \
    qml/js/smiles.js \

