#ifndef CONVERSATIONDIALOG_H
#define CONVERSATIONDIALOG_H

#include <QtCore>
#include <QtGui>
#include "models/contactsmodel.h"
#include "ui_dialogs.h"

namespace Ui {
	class Dialogs;
}

class Dialogs : public QDialog
{
    Q_OBJECT

    void changeEvent(QEvent *event);
	void closeEvent(QCloseEvent *);

	static Dialogs *instance;

public:
    Ui::Dialogs *ui;
	QMenu *contextMenu;

    explicit Dialogs(QWidget *parent = 0);
    ~Dialogs();
    static Dialogs* shared();

    Q_INVOKABLE void openDialog(QObject *user);
    Q_INVOKABLE void showDialog();
    Q_INVOKABLE void closeDialog() { close(); }
    Q_INVOKABLE bool isVisible() const { return QDialog::isVisible(); }
    Q_INVOKABLE bool isActiveWindow() { return QDialog::isActiveWindow(); }
	Q_INVOKABLE void showContextMenu(int x, int y);

signals:
    void doOpenDialog(QObject *user);
    void selectMessage();
    void convertToRu();
    void copyToClipboard();
    void isActiveChanged(bool isActive);
};

#endif // CONVERSATIONDIALOG_H
