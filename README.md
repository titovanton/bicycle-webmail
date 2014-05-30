# Bicycle Webmail

This guide provides you to get up Webmail servers bundle and contains SQL and configuration files, that makes process much easy. The following apps will be installed on Ubuntu Server 12.04:

* Postfix (SMTP server)
* Dovecot (IMAP server)
* SpamAssassin
* Roundcube (Webmail interface)
* PostgreSQL
* NGINX

Most guides describes how to install Webmail bundle with Apache2 and MySQL... But I use Django for website developing and I like NGINX instead Apache2, and there are no needs to install another Data Base server and HTTP server.

## Prepare

First of all, update and upgrade your OS:

    sudo aptitude update && sudo aptitude upgrade -y

next install git to clone the repository:

    sudo aptitude install git -y

then install PostgreSQL:

    sudo aptitude install postgresql -y

Postfix, Dovecot, SpamAssassin:

    sudo aptitude remove exim4 -y
    sudo aptitude install postfix postfix-pgsql -y
    sudo aptitude install dovecot-core dovecot-common dovecot-lmtpd dovecot-pgsql dovecot-imapd dovecot-pop3d -y
    sudo apt-get install spamassassin spamc

select `no configuration` when Postfix will aske you.

## PostgreSQL prepare

If you already set password for postgres user (like root in MySQL), then move next, else enter to psql client as postgres user:

    sudo -u postgres psql postgres

and launch the command:

    \password postgres

you will see password request (twice) - give it to him and then quit:

    \q

Following to /etc/postgresql/9.1/main/pg_hba.conf 
Make sure to add it right after the Put your actual configuration here comment block! Otherwise one of the default entries might catch first and the databse authentication will fail.
    
    local   all             all                                     password

Now you can login using psql client without specifying `-h localhost`:
    
    psql -U <user> <db>

and our mail bundle has access to DB. Reload PostgreSQL:

    sudo service postgresql reload


## Clone repo

Now is the time to clone this repository (I hope you have your own home directory):

    mkdir -p $HOME/src
    cd $HOME/src
    git clone https://github.com/titovanton-com/bicycle-webmail.git
    cd bicycle-webmail

## Configure

Following to config.sh for specifying password and domains.

## Run

    sudo ./run.sh

Be ready to enter sudo password, postgres password, and password that you specify in config.sh, to access Postfix to DB.
Also, script make SSL certificates for mail client access, such as Thunderbird, so be ready for openssl dialog.

## Configure mail clients

In Thunderbird, just add a new Account (File -> New -> Existing Mail Account) and enter joe@yourdomain.com and the password in the dialog.

If your mail client doesn't auto-detect the necessary settings: The username for the IMAP connection is joe, the port is 143, and the authentication method is unencrypted password via STARTTLS. For SMTP it's the same, but port 587.

If anything isn't working, check for error messages in the system log with tail -n 50 /var/log/syslog and in the mail log with tail -n 50 /var/log/mail.log.

## Links and sources:

* [How To Set Up a Postfix Email Server with Dovecot: Dynamic Maildirs and LMTP](https://www.digitalocean.com/community/articles/how-to-set-up-a-postfix-email-server-with-dovecot-dynamic-maildirs-and-lmtp "How To Set Up a Postfix Email Server with Dovecot: Dynamic Maildirs and LMTP")
* [How To Set Up a Postfix E-Mail Server with Dovecot](https://www.digitalocean.com/community/articles/how-to-set-up-a-postfix-e-mail-server-with-dovecot "How To Set Up a Postfix E-Mail Server with Dovecot")
