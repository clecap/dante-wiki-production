#!/bin/bash

MAIN_DIR=dante
BRANCH=master
REPO=dante-wiki-production

mkdir dante
cd dante

# rather place this into a preparation file
# apt-get install unzip

wget https://github.com/clecap/${REPO}/archive/refs/heads/${BRANCH}.zip
unzip ${BRANCH}.zip
cd ${REPO}-${BRANCH}




./install-dante.sh
