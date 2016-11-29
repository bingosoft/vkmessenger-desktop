#include <QApplication>
#include <QDesktopWidget>
#include <QtDeclarative/QDeclarativeEngine>
#include "ui/mainwindow.h"
#include "ui/dialogs.h"
#include "api/vkapi.h"
#include "models/contactsmodel.h"
#include "roundimageprovider.h"
#include "models/dialogsheadermodel.h"
#include "src/settings.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

	qApp->addLibraryPath(qApp->applicationDirPath() + "/lib/");
	qmlRegisterType<VkApiResponse>("info.bingosoft.vkmessenger", 1, 0, "VkApiResponse");
	qmlRegisterType<VkApi>("info.bingosoft.vkmessenger", 1, 0, "VkApi");
	qmlRegisterType<ContactsModel>("info.bingosoft.vkmessenger", 1, 0, "ContactsModel");
	qmlRegisterType<DialogsHeaderModel>("info.bingosoft.vkmessenger", 1, 0, "DialogsHeaderModel");
	qmlRegisterType<UserItem>("info.bingosoft.vkmessenger", 1, 0, "UserItem");
	qmlRegisterType<ChatItem>("info.bingosoft.vkmessenger", 1, 0, "ChatItem");
    qApp->setFont(QFont("Ubuntu"));

    RoundImageProvider *imageProvider = new RoundImageProvider();
    MainWindow *m = MainWindow::shared();
    Dialogs *d = Dialogs::shared();

	m->ui->declarativeView->engine()->addImageProvider("round", imageProvider);
	m->ui->declarativeView->rootContext()->setContextProperty("context", m);
	m->ui->declarativeView->rootContext()->setContextProperty("dialogs", d);
	m->ui->declarativeView->rootContext()->setContextProperty("usersManager", UsersManager::Get());
	m->ui->declarativeView->rootContext()->setContextProperty("settings", Settings::shared());

	d->ui->declarativeView->engine()->addImageProvider("round", imageProvider);
	d->ui->declarativeView->rootContext()->setContextProperty("context", m);
	d->ui->declarativeView->rootContext()->setContextProperty("vkApi", VkApi::Get());
	d->ui->declarativeView->rootContext()->setContextProperty("dialogs", d);
	d->ui->declarativeView->rootContext()->setContextProperty("usersManager", UsersManager::Get());
	m->show();

	return a.exec();
}
