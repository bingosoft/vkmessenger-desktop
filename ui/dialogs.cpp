#include "ui/dialogs.h"
#include "ui/mainwindow.h"
#include <QDesktopWidget>

Dialogs *Dialogs::instance;

Dialogs::Dialogs(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialogs)
{
    ui->setupUi(this);
    Qt::WindowFlags flags = Qt::Window | Qt::WindowSystemMenuHint | Qt::WindowMaximizeButtonHint | Qt::WindowMinimizeButtonHint | Qt::WindowCloseButtonHint;
    setWindowFlags(flags);
   	setWindowTitle(QString("VkMessenger v%1 :: Dialogs").arg(MainWindow::version));
	ui->declarativeView->setSource(QUrl("qrc:/qml/dialogs/Dialogs.qml"));
	move((QApplication::desktop()->width() - width()) / 2, (QApplication::desktop()->height() - height()) / 2);
	ui->declarativeView->setResizeMode(QDeclarativeView::SizeRootObjectToView);

	contextMenu = new QMenu(this);
	contextMenu->addAction(tr("Select a message"), this, SIGNAL(selectMessage()));
	contextMenu->addAction(tr("Convert to RU layout"), this, SIGNAL(convertToRu()));
	contextMenu->addAction(tr("Copy to clipboard"), this, SIGNAL(copyToClipboard()));
}

Dialogs::~Dialogs()
{
    delete ui;
}

Dialogs* Dialogs::shared()
{
	if (!instance)
		instance = new Dialogs();

	return instance;
}

void Dialogs::closeEvent(QCloseEvent *event)
{
    hide();
    event->ignore();
}

void Dialogs::showContextMenu(int x, int y)
{
    contextMenu->popup(QPoint(this->x() + x, this->y() + y));
}

void Dialogs::showDialog()
{
    if (!isVisible()) {
        show();
    }
    raise();
    activateWindow();
}

void Dialogs::openDialog(QObject *user)
{
    showDialog();
    UserItem* contact = qobject_cast<UserItem *>(user);
    qDebug() << "user " << contact->get_name();
    doOpenDialog(user);
}

void Dialogs::changeEvent(QEvent *event)
{
    if (event->type() == QEvent::ActivationChange)
        isActiveChanged(isActiveWindow());

    QDialog::changeEvent(event);
}
