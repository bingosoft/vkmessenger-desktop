#ifndef LASTFMAUTHDIALOG_H
#define LASTFMAUTHDIALOG_H

#include <QWidget>
#include <QDesktopWidget>

namespace Ui {
class LastFmAuthDialog;
}

class LastFmAuthDialog : public QWidget
{
    Q_OBJECT
    
public:
    explicit LastFmAuthDialog(QWidget *parent = 0);
    ~LastFmAuthDialog();
	void show();
	
signals:
	void authorize(const QString &login, const QString &pass);
    
private slots:
    void on_loginButton_clicked();
    
    void on_passEdit_returnPressed();
    
private:
    Ui::LastFmAuthDialog *ui;
};

#endif // LASTFMAUTHDIALOG_H
