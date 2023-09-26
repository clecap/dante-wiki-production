#!/bin/bash


# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${DIR}/..

BRANCH=master

abort()
{
  printf "%b" "\e[1;31m *** UPDATER of DANTEWIKI was ABOERTED, check error messages *** \e[0m"
  exit 1
}

set -e                                  # abort execution on any error
trap 'abort' EXIT                       # call abort on EXIT

cd ${TOP_DIR}

printf "\n\n*** Getting fresh source from branch ${BRANCH}..."
rm -f ${TOP_DIR}/main.zip
wget https://github.com/clecap/dante-wiki-production/archive/refs/heads/${BRANCH}.zip
printf "DONE getting fresh source"

printf "*** Unzipping source..."
unzip -o ${BRANCH}.zip
printf "DONE unzipping fresh source"

printf "*** Copying in backup of configuration file ..."
cp -f ${DIR}/conf/CONF-backup.sh ${DIR}/CONF.sh
printf "DONE copying in backup of configuration file"

printf "*** Running installer ..."
  source ${DIR}/install-dante.sh
printf "DONE running installer\n"

trap : EXIT         # switch trap command back to noop (:) on EXIT