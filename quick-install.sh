#!/bin/bash

MAIN_DIR=dante
BRANCH=master
REPO=dante-wiki-production

mkdir dante
cd dante

wget https://github.com/clecap/${REPO}/archive/refs/heads/${BRANCH}.zip
unzip ${BRANCH}.zip
cd ${REPO}-${BRANCH}



vi CONF.sh

./install-dante.sh
