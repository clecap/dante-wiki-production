#!/bin/bash
{

# The { ... } forces bash to parse the entire script until the closing } 
# This makes sure that we get defined results and are not overwriting the script while it is executing
# which could produce random results. See https://stackoverflow.com/questions/21096478/overwrite-executing-bash-script-files?rq=3



## 
##        update-dante.sh MUST stay stand-alone and MUST NOT use script-library (for reasons fo stability) 
##

# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

VERSION=2.38


###
### CONFIGURATION
###

BRANCH=master
LAP_CONTAINER=my-lap-container


# user name for docker exec
USER=apache


function usage() {
  echo "Usage: $0       "
  echo "  --skip-content     Skip the content backup (eg when we already have a backup and the container is not running)     "
  echo "  --no-usage         Dummy parameter which can be usd to prevent display of usage (which happens when no parameter is given)"
#  exit 1
}

##
## Parse command line
##
function parseCommandLine() {
  if [ "$#" -eq 0 ]; then
    usage
    CONTENT_BACKUP=true
  else                      ### Variant 2: We were called with parameters.
    while (($#)); do
      case $1 in 
        (--skip-content) 
          CONTENT_BACKUP=false;;
         (--no-usage)
           ;;
        (*) 
           echo "Error parsing options - aborting" 
           usage 
           exit 1
      esac
      shift 1
    done
  fi
}

abort()
{
  printf "%b" "\e[1;31m *** UPDATER of DANTEWIKI was ABORTED, check error messages *** \e[0m"
  exit 1
}

set -e                                  # abort execution on any error
trap 'abort' ERR                        # call abort on ERROR
trap 'abort' EXIT                       # call abort on EXIT 

function configBackup () {
  printf "\n *** Making a backup of the configuration file ..."
    mkdir -p  ../DANTE-BACKUP
    chmod 700 ../DANTE-BACKUP
    cp CONF.sh ../DANTE-BACKUP/CONF.sh
    chmod 700  ../DANTE-BACKUP/CONF.sh
  printf "DONE making a backup of the configuration file\n"
}

function contentBackup () {
  if [ "$CONTENT_BACKUP" = true ]; then
    printf "\n *** Making a backup of Wiki Contents ...\n"
      mkdir -p  ../DANTE-BACKUP
      chmod 700 ../DANTE-BACKUP
      docker exec  --user ${USER} ${LAP_CONTAINER} php  /var/www/html/wiki-dir/maintenance/dumpBackup.php --full --include-files --uploads  > ../DANTE-BACKUP/wiki-xml-dump-$(date +%d.%m.%y-%k:%M)
      printf "\n\n **  Listing of directory DANTE-BACKUP \n\n"
      ls -l ../DANTE-BACKUP
    printf "\n\n DONE making a backup of Wiki Contents\n\n"
  else
    printf "\n *** SKIPPING CONTENTS BACKUP !!!\n\n"
  fi
}


function clearing () {
  printf "*** Clearing existing files ...\n"
    rm -Rf ${DIR}/volumes/full

  printf "DONE clearing existing files\n\n"
}


function getting () {
  printf " *** Getting fresh system from branch ${BRANCH}...\n\n"
    rm -f ${BRANCH}.zip
    COMMIT=`wget -qO- https://github.com/clecap/dante-wiki-production/commits/master | grep -m1 -oP 'commit/\K[0-9a-f]{40}'`
    printf "*** COMMIT Hash currently is ${COMMIT}\n\n"
    wget --no-cookies --no-cache https://github.com/clecap/dante-wiki-production/archive/refs/heads/${BRANCH}.zip
    printf " DONE getting fresh source, COMMIT is ${COMMIT}\n\n"
  printf " *** Unzipping source..."
    # -o is overwrite mode
    unzip -q -o ${BRANCH}.zip -d .. 
    rm ${BRANCH}.zip
  printf " DONE unzipping fresh source\n\n"
  printf " *** Copying in backup of configuration file ..."
    cp -f ${DIR}/.BAK/CONF.sh ${DIR}/CONF.sh
    chmod 700 ${DIR}/CONF.sh
  printf " DONE copying in backup of configuration file\n\n"
}
 


function getScripts () {
  printf " *** Getting script elements\n"
    cd volumes/full/spec
    rm -f script-library.sh
    wget --no-cookies --no-cache https://raw.githubusercontent.com/clecap/dante-wiki/HEAD/volumes/full/spec/script-library.sh
  
    cd ${DIR}/images/lap/bin
    rm -f run.sh
    rm -f both.sh
    wget --no-cookies --no-cache https://raw.githubusercontent.com/clecap/dante-wiki/HEAD/images/lap/bin/run.sh
    wget --no-cookies --no-cache https://raw.githubusercontent.com/clecap/dante-wiki/HEAD/images/lap/bin/both.sh

    cd ${DIR}/images/my-mysql/bin
    rm -f run.sh
    wget --no-cookies --no-cache https://raw.githubusercontent.com/clecap/dante-wiki/HEAD/images/my-mysql/bin/run.sh
  printf " DONE getting script elements\n\n"
}




printf "\n\n\n **********************************\n"
printf       " *** Dante Updater Version $VERSION ***\n" 
printf       " **********************************\n"

BASE_NAME=$(basename "$0")

printf "\n *** BASE_NAME is $BASE_NAME \n"
if [ "$BASE_NAME" = "update-dante-run.sh" ]; then
    printf "\n *** We are update-dante-run.sh and will run the update script now\n"
    configBackup
    contentBackup
    getting
    getScripts
else
    printf "\n *** We are just the copying stub\n"
    rm -f update-dante-run.sh
    cp update-dante.sh update-dante-run.sh
    chmod 700 update-dante-run.sh
    /bin/bash ${DIR}/update-dante-run.sh --no-usage "$@"
fi

#printf "*** Running installer ..."
#  source ${DIR}/install-dante.sh
#printf "DONE running installer\n\n"

trap : EXIT         # switch trap command back to noop (:) on EXIT

}