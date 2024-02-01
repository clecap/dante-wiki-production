#!/bin/bash

# quick-install shell script which downloads ${REPO} and uses the shellscripts from there to set up the system

MAIN_DIR=dante
BRANCH=master
REPO=dante-wiki-production
VERSION=1.1

# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR="${DIR}/.."

CF=${TOP_DIR}/../generated-conf-file.sh

printf "\n"
printf "***************************\n"
printf "*** QUICK INSTALLER ${VERSION} ***\n"
printf "***************************\n\n" 


if [ -d ${MAIN_DIR} ]; then
  echo "*** I found an old installation directory at ${MAIN_DIR} "
  echo "Shall I attempt to delete that old installation in ${PWD}/${MAIN_DIR} ?"
  read -p "Press  y  to delete or   n to keep:  " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    
    cd ${MAIN_DIR}
    rm -Rf ${BRANCH}.zip
    rm -Rf ${REPO}-${BRANCH}
  fi
fi

mkdir -p ${MAIN_DIR}
cd ${MAIN_DIR}
wget https://github.com/clecap/${REPO}/archive/refs/heads/${BRANCH}.zip
unzip ${BRANCH}.zip
cd ${REPO}-${BRANCH}


if [ -f ${CF} ]; then
  echo "Found an existing configuration file at ${CF}"
  echo "Shall I attempt to recreate a configuration from interactive questions ?"
  read -p "Press  y  to recreate or  n  to use old one: " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    ./bin/make-conf.sh
  fi
else
  # did not find a configuration file: generate one 
  ./bin/make-conf.sh
fi


mkdir private
openssl rand -base64 16 > private/mysql-root-password.txt
openssl rand -base64 16 > private/mysql-backup-password.txt
chmod 700 private
chmod 700 private/mysql-root-password.txt
chmod 700 private/mysql-backup-password.txt


./install-dante.sh