#!/bin/bash

MAIN_DIR=dante
BRANCH=master
REPO=dante-wiki-production
VERSION=1.1

printf "\n"
printf "***************************\n"
printf "*** QUICK INSTALLER ${VERSION} ***\n"
printf "***************************\n"

echo "We will attempt to delete an old installation in ${PWD}/${MAIN_DIR} "
read -p "Press  y  if this is okay." -n 1 -r
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

./bin/make-conf.sh

mkdir private
openssl rand -base64 16 > private/mysql-root-password.txt
chmod 700 private
chmod 700 private/mysql-root-password.txt

./install-dante.sh