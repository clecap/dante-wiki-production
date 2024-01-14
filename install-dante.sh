#!/bin/bash

DANTE_INSTALLER_VERSION=1.25

## The original of this file is in dante-wiki-production

##
## CONFIGURE script
##
#
# Name of the branch in dante-wiki-volume which we are going to download
#
BRANCH=master

# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${DIR}

printf "\n\n **********************************************\n"
printf     " *** THIS IS DANTE INSTALLER install-dante.sh ${DANTE_INSTALLER_VERSION} ***\n"
printf     " *******************************************\n\n"

curl -fsSL -o ${TOP_DIR}/volumes/full/spec/script-library.sh https://raw.githubusercontent.com/clecap/dante-wiki/HEAD/volumes/full/spec/script-library.sh

printf "\n\n*** Reading in the script library at ${TOP_DIR}/volumes/full/spec/script-library.sh"
  if ! bash  -n  "${TOP_DIR}/volumes/full/spec/script-library.sh"; then
    printf " *** ERROR: Syntax error detected in ${TOP_DIR}/volumes/full/spec/script-library.sh" >&2
    exit 1
  else
    source ${TOP_DIR}/volumes/full/spec/script-library.sh
  fi
printf "DONE, script library is version ${SCRIPT_LIB_VERSION}\n\n"


printf "*** Reading in the active configuration file ..."
  source ${DIR}/CONF.sh
printf "DONE \n\n" 


printf "*** Making required local directories\n"
  rm -Rf ${DIR}/volumes/full/content
  mkdir -p ${DIR}/volumes/full/content/wiki-dir
  mkdir -p ${DIR}/conf
  #chmod 700 ${DIR}/conf
printf "DONE making required local directories\n\n"

getDanteWikiVolume
makeMediawikiPrivate

CUS=${DIR}/conf/customize-PRIVATE.sh
printf "*** Generating customize-PRIVATE shell script file at ${CUS}\n"
  rm -f ${CUS}
  echo "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}"        > ${CUS}
  echo "MYSQL_DUMP_USER=${MYSQL_DUMP_USER}"                >> ${CUS}
  echo "MYSQL_DUMP_PASSWORD=${MYSQL_DUMP_PASSWORD}"        >> ${CUS}
  echo "DEFAULT_DB_VOLUME_NAME=${DEFAULT_DB_VOLUME_NAME}"  >> ${CUS}
  echo "MW_SITE_SERVER=${MW_SITE_SERVER}"                  >> ${CUS}
  echo "MW_SITE_NAME='${MW_SITE_NAME}'"                    >> ${CUS}
  echo "DONE generating mediawiki-PRIVATE.php"
printf "DONE generating customize-PRIVATE shell script file at ${CUS}\n\n"


## TODO: initial contents - is it in volume ????

#printf "*** Initial contents copied to volume directory to make it accessible in docker volume for later"
#  cp ${DIR}/initial-contents.xml  ${DIR}/volumes/full/content/wiki-dir/initial-contents.xml
#  cp ${DIR}/initial-mainpage.wiki ${DIR}/volumes/full/content/wiki-dir/initial-mainpage.wiki
#printf "DONE copying in initial contents"

LAP_VOLUME=lap-volume

printf " *** Building docker volume and copying in files\n"
  docker volume create ${LAP_VOLUME}
  #  -rm  automagically remove container when it exits
  docker run --rm --volume ${DIR}/volumes/full/content:/source --volume ${LAP_VOLUME}:/dest -w /source alpine cp -R wiki-dir /dest
printf "DONE building docker volume\n\n"


DOCKER_TAG=latest


pullDockerImages    ${DOCKER_TAG}
retagDockerImages   ${DOCKER_TAG}


MYSQL_CONTAINER=my-mysql
LAP_CONTAINER=my-lap-container

printf "*** Starting both containers..."
  # ${DIR}/images/lap/bin/both.sh --db my-test-db-volume --vol ${LAP_VOLUME}

  runDB
  waitingForDatabase
  runLap


printf "DONE starting containers\n\n"



fixPermissionsContainer

printf "*** Initializing Database"

# TODO: MYSQL PASSWORD
# volumes/full/spec/wiki-db-local-initialize.sh mysite https://localhost:4443 acro adminpassword sqlpassword
###echo ""; echo "******* initialize-dante.sh: MW_SITE_NAME=${MW_SITE_NAME}  MW_SITE_SERVER=${MW_SITE_SERVER}  SITE_ACRONYM=${SITE_ACRONYM}  ADMIN_PASSWORD=${ADMIN_PASSWORD}  MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}"

#####################  TODO: for wiki-dir use db name   dir
 DB_USER=dir

DB_NAME="DB_${DB_USER}"
DB_PASS="password-$DB_USER"

# Wiki user
WK_USER=Admin

WK_PASS="${ADMIN_PASSWORD}"
# WK_PASS="password-$DB_USER"


MOUNT="/var/www/html"
VOLUME_PATH=wiki-dir

# the following two commands are not found
# dropUser ${MYSQL_CONTAINER} ${MYSQL_ROOT_PASSWORD} ${DB_USER}
# dropDatabase ${DB_NAME} ${MYSQL_CONTAINER} ${MYSQL_ROOT_PASSWORD}
addDatabase ${DB_NAME} ${DB_USER} ${DB_PASS} ${MYSQL_CONTAINER}
removeLocalSettings ${LAP_CONTAINER} ${MOUNT} ${VOLUME_PATH}


##
printf "*** Setting up drawio as an external service (the extension is set up together with mediawiki in cmd.sh and wiki-init.sh)\n"
  docker exec my-lap-container mkdir -p /var/www/html/wiki-dir/external-services/draw-io/
  docker exec my-lap-container wget https://github.com/clecap/drawio/archive/refs/heads/dev.zip -O /var/www/html/wiki-dir/external-services/dev.zip
  docker exec my-lap-container unzip -q -o /var/www/html/wiki-dir/external-services/dev.zip -d /var/www/html/wiki-dir/external-services/draw-io/
  docker exec my-lap-container rm /var/www/html/wiki-dir/external-services/dev.zip
printf "DONE setting up drawio\n\n"


runMWInstallScript "${MW_SITE_NAME}" "${MW_SITE_SERVER}" "${SITE_ACRONYM}" "${WK_PASS}"
addingReferenceToDante ${MOUNT} ${VOLUME_PATH} ${LAP_CONTAINER}

fixPermissionsContainer
fixPermissionsProduction

apacheRestartDocker

minimalInitialContents

# after minimalInitialContents some ownerships are wrong
fixPermissionsContainer


printf "*** THE INSTALLATION HAS COMPLETED *** \n"
printf "*** DanteWiki should now be available locally at ${DANTE_WIKI_URL}/wiki-dir/index.php \n\n"
printf "*** You can now install initial content ***\n"

trap : EXIT         # switch trap command back to noop (:) on EXIT