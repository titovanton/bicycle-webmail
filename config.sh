#!/bin/bash

# PostgreSQL access
POSTFIX_DB=mail
POSTFIX_USER=mailreader
POSTFIX_PWD=1

# ROUNDCUBE_DB=roundcubemail
# ROUNDCUBE_USER=roundcubuser
# ROUNDCUBE_PWD=1

# Linux group and user
# Also, group id = 500
DOVECOT_USER=vmail

MAILBOXES=/home/mailboxes

# For example: example.com
DOMAIN=mail4.local
MYHOSTNAME=mail.$DOMAIN
MAILNAME=$DOMAIN