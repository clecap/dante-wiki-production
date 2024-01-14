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
rm ${BRANCH}.zip
wget https://github.com/clecap/${REPO}/archive/refs/heads/${BRANCH}.zip
unzip ${BRANCH}.zip
cd ${REPO}-${BRANCH}

./install-dante.sh