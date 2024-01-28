#!/bin/bash
#


## Password for the user admin - minimum of 10 characters
#
ADMIN_PASSWORD="adminpassword"

## Name of the site
#
MW_SITE_NAME="Local Test Wiki"

## Type of service.  http  or  https
#
SERVICE=https

##  PORT number where service is offered
#
PORT=443

# TODO should be generated automagically somewhere  similar as mysql root password and also stored in private directory
# The name of a user which will be entitled to do a dump of the entire mysql installation
MYSQL_DUMP_USER=username
MYSQL_DUMP_PASSWORD=otherpassword

##
## SMTP Settings
##
#
# If you want to enable dante-wiki to send an email to you, you must provide some credentials
# to dante-wiki to an SMTP service from which it can send emails.
# Doing so is useful for a number of reasons, one of which is password recovery for your wiki.
#
#
# the email address which will be used as sender address of the emails
SMTP_SENDER_ADDRESS="sender@domain.de"

# hostname of an smtp server for the email account
SMTP_HOSTNAME='FILLIN',                      

# the port number on which the SMTP server offers its service
SMTP_PORT=587

# the username for logging in into the SMTP account
SMTP_USERNAME='usernamesamplexx'

# the password for logging in into the SMTP account
SMTP_PASSWORD='password'

##
## Below values should not be changed unless you know what you are doing
##

SITE_ACRONYM=acro
LOCALTIMEZONE="Europe/Berlin"
DEFAULT_DB_VOLUME_NAME=my-mysql-data-volume

# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR="${DIR}"


if test -f ${TOP_DIR}/../generated-conf-file.sh; then
  echo "A manually generated configuration file exists at ${TOP_DIR}/../generated-conf-file.sh and will be read in"
  source ${TOP_DIR}/../generated-conf-file.sh
fi

MW_SITE_SERVER=${SERVICE}://${HOSTNAME}/

# MW_SITE_SERVER=https://iuk-stage.informatik.uni-rostock.de/



