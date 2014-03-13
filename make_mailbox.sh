#!/bin/bash

source ./config.sh

email=$1

if [ ! $email ]; then
    echo 'USAGE: ./make_mailbox.sh user@example.com'
    exit 0
fi

name=`expr "$email" : '^\([^@]*\)'`
if [ ! $name ]; then
    echo 'Invalide email!'
    exit 0
fi

password=$(doveadm pw -s sha512 -r 100)
if [ ! $password ]; then
    echo 'Invalide password!'
    exit 0
fi
psql -h localhost -U $POSTFIX_USER -d $POSTFIX_DB -f sql/user_insert.sql -v email=\'$email\' -v password=\'$password\' -v maildir=\'$name/\'