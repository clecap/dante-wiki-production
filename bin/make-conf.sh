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

local MW_HOSTNAME
echo ""
echo "Enter a hostname, preferably including the domain"
echo "  For example: `hostname -f`   (DEFAULT; to select pres RETURN)"
echo "  For example: somehost.informatik.uni-rostock.de"
echo "  For example: localhost"
echo -n "HOSTNAME: " 
read -r MW_HOSTNAME

if [[ -z "$MW_HOSTNAME" ]]; then
    MW_HOSTNAME=`hostname -f`
    echo "Picked up default: ${MW_HOSTNAME}"
else
    echo "Hostname chosen is: ${MW_HOSTNAME}"
fi
echo "MW_HOSTNAME=\"${MW_HOSTNAME}\"" >> ${CF}

local MW_SITE_NAME
echo ""
read -p "Enter a short name for the site. May include blanks. Does not require quoting: " MW_SITE_NAME
echo "Will use:  ${MW_SITE_NAME}"
echo "MW_SITE_NAME=\"${MW_SITE_NAME}\"" >> ${CF}

local ADMIN_PASSWORD
echo ""
read -p "Enter the password for the Dantewiki admin user. Minimal length is 10 characters. "$'\n' -s ADMIN_PASSWORD
echo "ADMIN_PASSWORD=\"${ADMIN_PASSWORD}\"" >> ${CF}

local SERVICE
echo ""
echo "Will you be using http  or  https ?"
echo "In case you answer  https  you will later have the opportunity to install the certificate and key"
read -p "Enter type of service:  http   or   https (DEFAULT; to select press return) : " SERVICE
if [[ -z "$SERVICE" ]]; then
  echo "Service was empty, picking up default https"
  SERVICE="https"
fi
echo "Service chosen is: ${SERVICE}"
echo "SERVICE=\"${SERVICE}\"" >> ${CF}

local PORT
echo ""
echo "Enter port number on which the container offers the service on the host "
echo "  For example:  443, 4443, 80, 8080"

if [ "$SERVICE" = "http" ]; then
  echo "  DEFAULT 80: Just press return"
fi
if [ "$SERVICE" = "https" ]; then
  echo "  DEFAULT 443: Just press return"
fi

read -p "PORT: " PORT
if [[ -z "$PORT" ]]; then
  if [ "$SERVICE" = "http" ]; then
    PORT="80"
  fi
  if [ "$SERVICE" = "https" ]; then
    PORT="443"
  fi
fi

echo "Picked port ${PORT}"
echo "PORT=\"${PORT}\"" >> ${CF}

echo ""
echo "DanteWiki can use an optional SMTP server for sending emails to users."

local SMTP_SENDER_ADDRESS="sender@domain.de"
read -p "Enter email address used by DanteWiki to send messages (RETURN to skip email configuration): " SMTP_SENDER_ADDRESS


local SMTP_HOSTNAME
local SMTP_PORT
local SMTP_USERNAME
local SMTP_PASSWORD

if [[ -z "$SMTP_SENDER_ADDRESS" ]]; then
  echo "Skipping configuration of SMTP server"
  SMTP_HOSTNAME=""
  SMTP_PORT="587"
  SMTP_USERNAME=""
  SMTP_PASSWORD=""
else
  read -p "Enter hostname includingg domain for an smtpserver used for sending emails "  SMTP_HOSTNAME
  read -p "Enter the port number on which the SMTP server offers its service: Often it is 587. " SMTP_PORT
  read -p "Enter the username for logging in into the SMTP account: " SMTP_USERNAME
  read -p "Enter the password for logging in into the SMTP account: " SMTP_PASSWORD
fi

# writing the information to the configuration file
echo "SMTP_SENDER_ADDRESS=${SMTP_SENDER_ADDRESS}" >> ${CF}
echo "SMTP_HOSTNAME=${SMTP_HOSTNAME}" >> ${CF}
echo "SMTP_PORT=${SMTP_PORT}" >> ${CF}
echo "SMTP_USERNAME=${SMTP_USERNAME}" >> ${CF}
echo "SMTP_PASSWORD=${SMTP_PASSWORD}" >> ${CF}


chmod 700 ${CF}

}

input