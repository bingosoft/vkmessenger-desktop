#include "mainwindow.h"
#include "dialogs.h"

const char * MainWindow::version = "1.0";
MainWindow *MainWindow::instance;

#ifdef Q_OS_LINUX
const char * MainWindow::OS = "Linux";
#endif
#ifdef Q_OS_WIN
const char * MainWindow::OS = "Windows";
#endif
#ifdef Q_OS_MAC
const char * MainWindow::OS = "Mac";
#endif

MainWindow::MainWindow(QWidget *parent) :
	QMainWindow(parent),
    timerId(),
	ui(new Ui::MainWindow)
{
    ui->setupUi(this);
	QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
//	QTextCodec::setCodecForTr(QTextCodec::codecForName("utf8"));
   	setWindowTitle(QString("VkMessenger v%1").arg(version));

	ui->declarativeView->setSource(QUrl("qrc:/qml/Main.qml"));
	move((QApplication::desktop()->width() - width()), (QApplication::desktop()->height() - height()));
	ui->declarativeView->setResizeMode(QDeclarativeView::SizeRootObjectToView);
	setMinimumHeight(250);

	trayMenu = new QMenu(this);
	trayMenu->addAction(tr("Show / Hide"), this, SLOT(triggerShowHide()));
	trayMenu->addAction(tr("Show dialogs"), this, SLOT(showDialogs()));
	trayMenu->addAction(tr("Exit"), qApp, SLOT(quit()));

	trayIcon = new QSystemTrayIcon(this);
	connect(trayIcon, SIGNAL(activated(QSystemTrayIcon::ActivationReason)), SLOT(trayIconActivated(QSystemTrayIcon::ActivationReason)));
	trayIcon->setIcon(QIcon(":/qml/images/trayicon.png"));
    trayIcon->setToolTip(QString("VkMessenger v%1").arg(version));
	trayIcon->setContextMenu(trayMenu);
	trayIcon->show();

	contextMenu = new QMenu(this);
	contextMenu->addAction(tr("Open page in a browser"), this, SIGNAL(openUserPage()));
	contextMenu->addAction(tr("Write a message"), this, SIGNAL(startConversation()));
	contextMenu->addAction(tr("Remove from friends"), this, SIGNAL(removeFromFriends()));

//    QNetworkProxy::setApplicationProxy(QNetworkProxy(QNetworkProxy::HttpProxy, "192.168.16.18", 5353));
//    https://oauth.vk.com/authorize?client_id=3800364&redirect_uri=http://api.vk.com/blank.html&scope=messages,friends,audio,offline&display=wap&response_type=token
}

MainWindow::~MainWindow()
{
    delete ui;
}

MainWindow* MainWindow::shared()
{
	if (!instance)
		instance = new MainWindow();

	return instance;
}

QString MainWindow::getAppId() const
{
#ifdef Q_OS_LINUX
	return "3800364";
#endif
#ifdef Q_OS_WIN
	return "2741306";
#endif
#ifdef Q_OS_MAC
#endif
	return "";
}

QString MainWindow::getAppPath() const
{
	return qApp->applicationDirPath();
}

void MainWindow::showContextMenu(int x, int y)
{
    contextMenu->popup(QPoint(this->x() + x, this->y() + y));
}

void MainWindow::showTrayIconMessage(const QString &title, const QString &message)
{
	trayIcon->showMessage(title, message);
}

void MainWindow::raise()
{
	show();
	QMainWindow::raise();
	activateWindow();
}

void MainWindow::triggerShowHide()
{
	if (timerId != 0)
		Dialogs::shared()->showDialog();
	else
#ifndef Q_OS_WIN
	if (!isVisible() || !isActiveWindow()) {
#else
	if (!isVisible()) {
#endif
		raise();
	} else {
		hide();
	}
}

void MainWindow::showDialogs()
{
	Dialogs::shared()->showDialog();
}

void MainWindow::trayIconActivated(QSystemTrayIcon::ActivationReason reason)
{
	switch (reason) {
    case QSystemTrayIcon::Trigger:
        triggerShowHide();
		break;
	default:
		break;
	}
}

void MainWindow::open(const QString &path)
{
	if (path.isEmpty())
		return;

	QDesktopServices::openUrl(QUrl(path));
}

void MainWindow::openFile(const QString &path)
{
	if (path.isEmpty())
		return;

	QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}

void MainWindow::showAbout()
{
	QMessageBox::information(0, QString("VkAudioSaver v%1").arg(version),
	tr("Tool for listening & downloading<br>the music from VK.COM<br><br>Web: <a href='http://vkaudiosaver.ru/'>http://vkaudiosaver.ru/</a><br><br>Copyright &copy; Bingo's Soft 2013"));
}

void MainWindow::setHasNewMessages(bool newMessages)
{
    if (newMessages && timerId == 0) {
        timerId = startTimer(500);
    } else if (!newMessages && timerId > 0) {
        killTimer(timerId);
        trayIcon->setIcon(QIcon(":/qml/images/trayicon.png"));
        trayIcon->setProperty("isNewMessageIcon", false);
        timerId = 0;
    }
}

void MainWindow::closeEvent(QCloseEvent *event)
{
    hide();
    event->ignore();
}

void MainWindow::timerEvent(QTimerEvent *)
{
    if (trayIcon->property("isNewMessageIcon").toBool())
        trayIcon->setIcon(QIcon(":/qml/images/trayicon.png"));
    else
        trayIcon->setIcon(QIcon(":/qml/images/tray_unread.png"));

    trayIcon->setProperty("isNewMessageIcon", !trayIcon->property("isNewMessageIcon").toBool());
}

void MainWindow::copyToClipboard(const QString &message)
{
    QApplication::clipboard()->setText(message);
}
