#!/bin/bash

service postfix stop
service dovecot stop

source ./config.sh

# PostgreSQL setup
if [ ! -f /etc/postgresql/9.1/main/pg_ident.conf ]; then
    echo 'DOES NOT EXISTS: /etc/postgresql/9.1/main/pg_ident.conf'
    exit 0
fi
sed -e "s;%POSTFIX_USER%;$POSTFIX_USER;g" \
    templates/psql/pg_ident.conf.inc >> /etc/postgresql/9.1/main/pg_ident.conf

echo '########### CREATING DB AND USER ###########'
psql -h localhost -U postgres -f sql/createdb.sql -v usr=$POSTFIX_USER -v db=$POSTFIX_DB -v passwd=\'$POSTFIX_PWD\'
echo '########### CREATING TABLES ###########'
psql -h localhost -U $POSTFIX_USER -d $POSTFIX_DB -f sql/tables.sql

service postgresql reload

# Postfix setup
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/mail.key -out /etc/ssl/certs/mailcert.pem
chown root /etc/ssl/private/mail.key

cat templates/postfix/master.cf.inc >> /etc/postfix/master.cf

sed -e "s;%POSTFIX_USER%;$POSTFIX_USER;g" \
    -e "s;%POSTFIX_DB%;$POSTFIX_DB;g" \
    -e "s;%POSTFIX_PWD%;$POSTFIX_PWD;g" \
    templates/postfix/pgsql-aliases.cf > /etc/postfix/pgsql-aliases.cf

sed -e "s;%POSTFIX_USER%;$POSTFIX_USER;g" \
    -e "s;%POSTFIX_DB%;$POSTFIX_DB;g" \
    -e "s;%POSTFIX_PWD%;$POSTFIX_PWD;g" \
    templates/postfix/pgsql-boxes.cf > /etc/postfix/pgsql-boxes.cf

chown root /etc/postfix/pgsql-*.cf
chgrp postfix /etc/postfix/pgsql-*.cf

sed -e "s;%MYHOSTNAME%;$MYHOSTNAME;g" \
    -e "s;%DOMAIN%;$DOMAIN;g" \
    templates/postfix/main.cf > /etc/postfix/main.cf

sed -e "s;%MAILNAME%;$MAILNAME;g" templates/postfix/mailname > /etc/mailname

cp templates/postfix/aliases /etc/aliases

# Dovecot setup
adduser --system --no-create-home --uid 500 --group --disabled-password --disabled-login --gecos 'dovecot virtual mail user' $DOVECOT_USER
mkdir $MAILBOXES
chown -R $DOVECOT_USER:$DOVECOT_USER $MAILBOXES
chmod -R 700 $MAILBOXES

sed -e "s;%POSTFIX_DB%;$POSTFIX_DB;g" \
    -e "s;%POSTFIX_USER%;$POSTFIX_USER;g" \
    -e "s;%POSTFIX_PWD%;$POSTFIX_PWD;g" \
    -e "s;%MAILBOXES%;$MAILBOXES;g" \
    templates/dovecot/dovecot-sql.conf > /etc/dovecot/dovecot-sql.conf

chown root /etc/dovecot/dovecot-sql.conf
chmod 600 /etc/dovecot/dovecot-sql.conf

sed -e "s;%MAILNAME%;$MAILNAME;g" \
    -e "s;%MYHOSTNAME%;$MYHOSTNAME;g" \
    templates/dovecot/dovecot.conf > /etc/dovecot/dovecot.conf

# SpamAssassin
adduser spamd --disabled-login
cat templates/spamassassin/spamassassin > /etc/default/spamassassin
cat templates/spamassassin/local.cf > /etc/spamassassin/local.cf

newaliases
service spamassassin start
service postfix start
service dovecot start