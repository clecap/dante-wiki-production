#!/bin/bash
#
# The DanteWiki will be accessible under the Wiki user name     Admin
# 
# Below, chose a password for the user Admin
# The password MUST NOT contain any blanks, double or single quotes.
#
ADMIN_PASSWORD=adminpassword

# Below, chose the URL under which the DanteWiki will be available.
#
# TO BE DETERMINED experimentally still....
# https://localhost:4443 
#
# https://dante.informatik.uni-rostock.de/wiki-dir
#
# https://dante.informatik.uni-rostock.de/
# 
# CAVE: We might not need a path component if reverse proxy maps it in specific ways
#
# MW_SITE_SERVER=https://localhost:4443/wiki-dir

MW_SITE_SERVER=https://iuk-stage.informatik.uni-rostock.de:4443/


# currently NO blank in below name
MW_SITE_NAME="LocalTestWiki"

##
##  PORT numbers
##
#
#  Normally, the port numbers are HTTP_PORT=80   and  HTTPS_PORT=443
#  Alternative port numbers are   HTTP_PORT=8080 and  HTTPS_PORT=4443
#
HTTP_PORT=80
HTTPS_PORT=4443

# TODO: WHY? conflicts with the file based root password which is generated in ./private
# The root password to be installed for the MYSQL database
MYSQL_ROOT_PASSWORD=sqlrootpassword

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
TOP_DIR="${DIR}/../"


source ${TOPD_DIR}/../generated-conf-file.sh


