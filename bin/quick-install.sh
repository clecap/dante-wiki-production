#!/bin/bash

MAIN_DIR=dante
BRANCH=master
REPO=dante-wiki-production
VERISON=1.1

printf "\n"
printf "**************************\n"
printf "*** QUICK INSTALLER ${VERSION} ***\n"
printf "**************************\n"

cd ~dante
rm -Rf ${BRANCH}.zip
rm -Rf ${REPO}-${BRANCH}
wget https://github.com/clecap/${REPO}/archive/refs/heads/${BRANCH}.zip
unzip ${BRANCH}.zip
cd ${REPO}-${BRANCH}

mkdir private
openssl rand -base64 16 > private/mysql-root-password.txt
chmod 700 private
chmod 700 private/mysql-root-password.txt

./install-dante.sh