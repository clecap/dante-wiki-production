#!/bin/bash

# quick-install shell script which downloads ${REPO} and uses the shellscripts from there to set up the system

MAIN_DIR=dante
BRANCH=master
REPO=dante-wiki-production
VERSION=1.31

printf "\n"
printf "***************************\n"
printf "*** QUICK INSTALLER ${VERSION} ***\n"
printf "***************************\n\n" 

if [ -d ${MAIN_DIR} ]; then
  echo "*** quick-install.sh found an old installation directory at ${PWD}/${MAIN_DIR} "
  echo "    k     Keep configuration and delete remaining installation [DEFAULT: press return]"
  echo "    d     Delete configuration and delete installation "
  echo "    x     Exit shell script "
  read -p " Enter one of  k  d  x  " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[kK]$ ]]; then
    echo "  Keeping configuation and deleting old installation at ${PWD}/${MAIN_DIR} "
    ls -l
    rm -Rf ${MAIN_DIR}/${BRANCH}.zip
    rm -Rf ${MAIN_DIR}/${BRANCH}.zip.*
    rm -Rf ${MAIN_DIR}/${REPO}-${BRANCH}
  fi
  if [[ $REPLY =~ ^[dD]$ ]]; then
    echo "  Deleting configuration and installation at ${PWD}/${MAIN_DIR} "
    ls -l
    rm -Rf ${MAIN_DIR}/${BRANCH}.zip
    rm -Rf ${MAIN_DIR}/${BRANCH}.zip.*
    rm -Rf ${MAIN_DIR}/${REPO}-${BRANCH}
    rm -Rf ${MAIN_DIR}/generated-conf-file.sh
  fi
  if [[ $REPLY =~ ^[xX]$ ]]; then
    echo "  Exiting script "
    exit
  fi
  else
    echo "*** quick-install.sh making new installation directory at ${PWD}/${MAIN_DIR} "
    mkdir -p ${MAIN_DIR}
fi


echo ""
echo "*** quick-install.sh is in directory ${PWD} and starts downloading ${BRANCH}.zip ..."
wget --directory-prefix=${MAIN_DIR} https://github.com/clecap/${REPO}/archive/refs/heads/${BRANCH}.zip
unzip -d ${MAIN-DIR} ${MAIN_DIR}/${BRANCH}.zip
echo ""
echo "DONE downloading ${BRANCH}.zip "

# ensure presence of a configuration file
if [ -f ${MAIN_DIR}/generated-conf-file.sh ]; then
  echo "*** quick-install.sh found an existing configuration file at ${MAIN_DIR}/generated-conf-file.sh"
  echo "    Shall I recreate a configuration from interactive questions ?"
  read -p "Press  y  to recreate or  n  to use old one: " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "*** quick-install is recreating a new configuration file at ${MAIN_DIR}/generated-conf-file.sh"
    source ${MAIN_DIR}/${REPO}-${BRANCH}/bin/make-conf.sh
  else
    echo "*** quick-install.sh is reusing existing configuration file ${MAIN_DIR}/generated-conf-file.sh"
  fi
else
  # did not find a configuration file: generate one 
  echo "*** quickinstall.sh did not find a configuration file at ${MAIN_DIR}/generated-conf-file.sh and is creating one" 
   source ${MAIN_DIR}/${REPO}-${BRANCH}/bin/make-conf.sh
fi

# now generate throw-away secrets for the new installation
mkdir ${MAIN_DIR}/${REPO}-${BRANCH}/private
openssl rand -base64 16 > ${MAIN_DIR}/${REPO}-${BRANCH}/private/mysql-root-password.txt
openssl rand -base64 16 > ${MAIN_DIR}/${REPO}-${BRANCH}/private/mysql-backup-password.txt
chmod 700 ${MAIN_DIR}/${REPO}-${BRANCH}/private
chmod 700 ${MAIN_DIR}/${REPO}-${BRANCH}/private/mysql-root-password.txt
chmod 700 ${MAIN_DIR}/${REPO}-${BRANCH}/private/mysql-backup-password.txt

# now kick-off installation routine
source ${MAIN_DIR}/${REPO}-${BRANCH}/install-dante.sh