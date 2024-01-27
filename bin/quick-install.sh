#!/bin/bash

MAIN_DIR=dante
BRANCH=master
REPO=dante-wiki-production
VERSION=1.1

printf "\n"
printf "**************************\n"
printf "*** QUICK INSTALLER ${VERSION} ***\n"
printf "**************************\n"

read -p "We will attempt to delete an old installation in ${PWD}/${MAIN_DIR} " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  cd ${MAIN_DIR}
  rm -Rf ${BRANCH}.zip
  rm -Rf ${REPO}-${BRANCH}
fi

mkdir -p ${MAIN_DIR}
cd ${MAIN_DIR}
wget https://github.com/clecap/${REPO}/archive/refs/heads/${BRANCH}.zip
unzip ${BRANCH}.zip
cd ${REPO}-${BRANCH}

mkdir private
openssl rand -base64 16 > private/mysql-root-password.txt
chmod 700 private
chmod 700 private/mysql-root-password.txt

./install-dante.sh