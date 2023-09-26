#!/bin/bash
{

# The { ... } forces bash to parse the entire script until the closing } 
# This makes sure that we get defined results and are not overwriting the script while it is executing
# which could produce random results. See https://stackoverflow.com/questions/21096478/overwrite-executing-bash-script-files?rq=3

# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BRANCH=master

abort()
{
  printf "%b" "\e[1;31m *** UPDATER of DANTEWIKI was ABOERTED, check error messages *** \e[0m"
  exit 1
}

set -e                                  # abort execution on any error
trap 'abort' EXIT                       # call abort on EXIT
 
printf "\n*** Making a backup of the configuration file ..."
  mkdir -p  .BAK
  chmod 700 .BAK
  cp CONF.sh .BAK/CONF.sh
  chmod 700 .BAK/CONF.sh
printf "DONE making a backup of the configuration file\n\n"

printf "*** Clearing existing files ...\n"
  # must go upstairs by one level or else we cannot do the ls
  cd ${DIR}/..
  rm -Rf ${DIR}
  ls -al ${DIR}
printf "DONE\n\n"

printf "*** Getting fresh system from branch ${BRANCH}..."
  rm -f ${DIR}/../${BRANCH}.zip
  cd ${DIR}/..
  wget https://github.com/clecap/dante-wiki-production/archive/refs/heads/${BRANCH}.zip
printf "DONE getting fresh source"

printf "*** Unzipping source..."
  # -o is overwrite mode
  unzip -o ${BRANCH}.zip
printf "DONE unzipping fresh source\n\n"

printf "*** Copying in backup of configuration file ..."
  cp -f ${DIR}/.BAK/CONF.sh ${DIR}/CONF.sh
  chmod 700 ${DIR}/CONF.sh
printf "DONE copying in backup of configuration file\n\n"

printf "*** Running installer ..."
  source ${DIR}/install-dante.sh
printf "DONE running installer\n\n"

trap : EXIT         # switch trap command back to noop (:) on EXIT

}