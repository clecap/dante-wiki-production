#!/bin/bash

# Shell script to generate a fresh configuration file

# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR="${DIR}/.."

CF=${TOP_DIR}/../generated-conf-file.sh

input ()
{
local HOSTNAME
echo ""
echo "Enter a hostname including domain"
echo "  For example: iuk-stage.informatik.uni-rostock.de"
echo "  For example: localhost"
echo -n "HOSTNAME: " 
read -r HOSTNAME


local ADMIN_PASSWORD
echo ""
read -p "Enter the password for the Dantewiki admin user: "$'\n' -s ADMIN_PASSWORD

local HTTPS_PORT
echo ""
echo "Enter port number for HTTPS service or press return if no HTTPS service is required"
echo "  For example:  443"
echo "  For example: 4443"
read -p "HTTPS_PORT: " HTTPS_PORT

local HTTP_PORT
echo ""
echo "Enter port number for HTTP service or press return if no HTTP service is required"
echo "  For example:   80"
echo "  For example: 8080"
read -p "HTTP_PORT: " HTTP_PORT


echo -n "Removing ${CF}..."
rm -f ${CF}
echo -n "DONE"
echo "ADMIN_PASSWORD=\"${ADMIN_PASSWORD}\"" >> ${CF}
echo "HTTPS_PORT=${HTTPS_PORT}" >> ${CF}
echo "HTTP_PORT=${HTTP_PORT}" >> ${CF}
}

input