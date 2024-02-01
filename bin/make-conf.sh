#!/bin/bash

# Shell script to generate a fresh configuration file

# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR="${DIR}/.."

CF=${TOP_DIR}/../generated-conf-file.sh

input ()
{

echo -n "Removing ${CF}..."
rm -f ${CF}
echo "DONE"

local HOSTNAME
echo ""
echo "Enter a hostname including domain"
echo "  For example: iuk-stage.informatik.uni-rostock.de"
echo "  For example: `hostname -f`"
echo "  For example: localhost"
echo -n "HOSTNAME: " 
read -r HOSTNAME

if [[ -z "$HOSTNAME" ]]; then
    echo "Hostame is empty, picking up default"
    HOSTNAME="iuk-stage.informatik.uni-rostock.de"
else
    echo "Hostname chosen is ${HOSTNAME}"
fi

local MY_SITE_NAME
echo ""
read -p "Enter a short name for the site. " MY_SITE_NAME
echo "MY_SITE_NAME=\"${MY_SITE_NAME}\"" >> ${CF}

local ADMIN_PASSWORD
echo ""
read -p "Enter the password for the Dantewiki admin user. Minimal length 10 characters "$'\n' -s ADMIN_PASSWORD
echo "ADMIN_PASSWORD=\"${ADMIN_PASSWORD}\"" >> ${CF}


local SERVICE
echo ""
echo "Will you be using http  or  https ?"
echo "In case you answer  https  you will later have the opportunity to install the certificate and key"
read -p "Enter type of service:  http   or   https (DEFAULT) : " SERVICE
if [[ -z "$SERVICE" ]]; then
    echo "Service is empty, picking up default https"
    SERVICE="https"
else
    echo "Service chosen is ${SERVICE}"
fi

local PORT
echo ""
echo "Enter port number on which the container offers the service on the host "
echo "  For example:  443, 4443, 80, 8080 "
read -p "PORT: " PORT

local SMTP_SENDER_ADDRESS="sender@domain.de"
echo ""
read -p "Enter email address used by DanteWiki to send messages: " SMTP_SENDER_ADDRESS
echo "SMTP_SENDER_ADDRESS=${SMTP_SENDER_ADDRESS}" >> ${CF}

local SMTP_HOSTNAME
echo ""
read -p "Enter hostname includingg domain for an smtpserver used for sending emails "  SMTP_HOSTNAME
echo "SMTP_HOSTNAME=${SMTP_HOSTNAME}" >> ${CF}

local SMTP_PORT
echo ""
read -p "Enter the port number on which the SMTP server offers its service: Often it is 587. " SMTP_PORT
echo "SMTP_PORT=${SMTP_PORT}" >> ${CF}

local SMTP_USERNAME
read -p "Enter the username for logging in into the SMTP account: " SMTP_USERNAME
echo "SMTP_USERNAME=${SMTP_USERNAME}" >> ${CF}

local SMTP_PASSWORD
read -p "Enter the password for logging in into the SMTP account: " SMTP_PASSWORD
echo "SMTP_PASSWORD=${SMTP_PASSWORD}" >> ${CF}

}

input