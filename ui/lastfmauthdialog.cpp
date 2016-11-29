#include "ui/lastfmauthdialog.h"
#include "ui_lastfmauthdialog.h"

LastFmAuthDialog::LastFmAuthDialog(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::LastFmAuthDialog)
{
    ui->setupUi(this);
}

LastFmAuthDialog::~LastFmAuthDialog()
{
    delete ui;
}

void LastFmAuthDialog::on_loginButton_clicked()
{
    emit authorize(ui->loginEdit->text(), ui->passEdit->text());
	close();
}

void LastFmAuthDialog::on_passEdit_returnPressed()
{
    emit authorize(ui->loginEdit->text(), ui->passEdit->text());
	close();
}

void LastFmAuthDialog::show()
{
	ui->loginEdit->clear();
	ui->passEdit->clear();
	move((QDesktopWidget().width() - width()) / 2, (QDesktopWidget().height() - height()) / 2);
	QWidget::show();
}
