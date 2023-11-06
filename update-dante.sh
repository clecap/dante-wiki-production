#!/bin/bash
{

# The { ... } forces bash to parse the entire script until the closing } 
# This makes sure that we get defined results and are not overwriting the script while it is executing
# which could produce random results. See https://stackoverflow.com/questions/21096478/overwrite-executing-bash-script-files?rq=3

# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BRANCH=master

USER=apache
LAP_CONTAINER=my-lap-container


usage() {
  echo "Usage: $0       "
  echo "  --skip-content     Skip the content backup (eg when we have a backup and the container is not running)     "
  echo "  "
#  exit 1
}

##
## Parse command line
##
# region
if [ "$#" -eq 0 ]; then
  usage
  CONTENT_BACKUP=true
else                      ### Variant 2: We were called with parameters.
  while (($#)); do
    case $1 in 
      (--skip-content) 
        CONTENT_BACKUP=false;;
      (*) 
         echo "Error parsing options - aborting" 
         usage 
         exit 1
    esac
    shift 1
  done
fi


abort()
{
  printf "%b" "\e[1;31m *** UPDATER of DANTEWIKI was ABORTED, check error messages *** \e[0m"
  exit 1
}

set -e                                  # abort execution on any error
trap 'abort' EXIT                       # call abort on EXIT
 
function configBackup () {
  printf "\n*** Making a backup of the configuration file ..."
    mkdir -p  ../DANTE-BACKUP
    chmod 700 ../DANTE-BACKUP
    cp CONF.sh ../DANTE-BACKUP/CONF.sh
    chmod 700  ../DANTE-BACKUP/CONF.sh
  printf "DONE making a backup of the configuration file\n\n"
}

function contentBackup () {
  if [ "$CONTENT_BACKUP" = true ]; then
    printf "\n*** Making a backup of Wiki Contents ..."
      mkdir -p  ../DANTE-BACKUP
      chmod 700 ../DANTE-BACKUP
      docker exec  --user ${USER} ${LAP_CONTAINER} php  /var/www/html/wiki-dir/maintenance/dumpBackup.php --full --include-files --uploads  > ../DANTE-BACKUP/wiki-xml-dump-$(date +%d.%m.%y-%k:%M)
      ls -l ../DANTE-BACKUP
    printf "DONE making a backup of Wiki Contents\n\n"
  else
    printf "\n*** SKIPPING CONTENTS BACKUP !!!\n\n"
  fi
}

function clearing () {
  printf "*** Clearing existing files ...\n"
    # must go upstairs by one level or else we cannot do the ls
    cd ${DIR}/..
    rm -Rf ${DIR}/*
  printf "DONE clearing existing files\n\n"
}
 

function getting () {
  printf "*** Getting fresh system from branch ${BRANCH}...\n\n"
    rm -f ${BRANCH}.zip
    wget https://github.com/clecap/dante-wiki-production/archive/refs/heads/${BRANCH}.zip
  printf "DONE getting fresh source\n\n"
  printf "*** Unzipping source..."
    # -o is overwrite mode
    unzip -q -o ${BRANCH}.zip -d .. > unzip-branch.log
    rm ${BRANCH}.zip
  printf "DONE unzipping fresh source\n\n"
  printf "*** Copying in backup of configuration file ..."
    cp -f ${DIR}/.BAK/CONF.sh ${DIR}/CONF.sh
    chmod 700 ${DIR}/CONF.sh
  printf "DONE copying in backup of configuration file\n\n"
}

printf "\n\n\n **********************************\n"
printf       " *** Dante Updater Version 2.21 ***\n"
printf       " **********************************\n"


configBackup
contentBackup
getting








#printf "*** Running installer ..."
#  source ${DIR}/install-dante.sh
#printf "DONE running installer\n\n"

trap : EXIT         # switch trap command back to noop (:) on EXIT

}