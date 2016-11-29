#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "ui_mainwindow.h"
#include "models/contactsmodel.h"
#include <QtGui/QtGui>

namespace Ui {
    class MainWindow;
}

class MainWindow : public QMainWindow
{
	Q_OBJECT

	Q_PROPERTY(QString appId READ getAppId)
	Q_PROPERTY(QString appPath READ getAppPath)
    Q_PROPERTY(int currentUser READ getCurrentUser WRITE setCurrentUser)
public:
	static const char *version;
	static const char *OS;
	static MainWindow *instance;

private:
    int currentUser;
	QSystemTrayIcon *trayIcon;
	QMenu *trayMenu;
	QMenu *contextMenu;
    int timerId;

	void closeEvent(QCloseEvent *);
    void timerEvent(QTimerEvent *);

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();
    static MainWindow* shared();

	QString getAppId() const;
	QString getAppPath() const;
	int getCurrentUser() const { return currentUser; }
	void setCurrentUser(int user) { currentUser = user; }

	Q_INVOKABLE void open(const QString &path);
	Q_INVOKABLE void openFile(const QString &path);
	Q_INVOKABLE void showAbout();
	Q_INVOKABLE void raise();
	Q_INVOKABLE void showTrayIconMessage(const QString &title, const QString &message);
	Q_INVOKABLE void showContextMenu(int x, int y);
	Q_INVOKABLE void setHasNewMessages(bool newMessages);
	Q_INVOKABLE void copyToClipboard(const QString &message);

	Ui::MainWindow *ui;

signals:
    void startConversation();
    void removeFromFriends();
    void openUserPage();

private slots:
	void trayIconActivated(QSystemTrayIcon::ActivationReason);
    void triggerShowHide();
    void showDialogs();
};

#endif // MAINWINDOW_H
