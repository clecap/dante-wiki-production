#!/bin/bash

## The original of this file is in dante-wiki-production

    
 
##
## CONFIGURE script
##
#
# Name of the branch in dante-wiki-volume which we are going to download
#
BRANCH=master


# 100.101 on alpine installations is apache.www-data
# This defines the target ownership for all files
OWNERSHIP="100.101"


# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${DIR}/..

set -e

abort()
{
  printf "%b" "\e[1;31m *** INSTALLATION fo DANTEWIKI was ABOERTED *** \e[0m"
  exit 1
}

set -e                                  # abort execution on any error
trap 'abort' EXIT                       # call abort on EXIT


printf "\n\n*** THIS IS INSTALLER install-dante.sh ***\n\n"

printf "*** Making fresh volumes directory\n"
  rm -Rf ${DIR}/volumes/full/content
  mkdir -p ${DIR}/volumes/full/content/wiki-dir
printf "DONE making fresh volumes directory\n\n"


printf "*** wget branch ${BRANCH} from dante-wiki-volume ...\n"
  rm -f ${DIR}/volumes/full/content/${BRANCH}.zip
  wget https://github.com/clecap/dante-wiki-volume/archive/refs/heads/${BRANCH}.zip -O ${DIR}/volumes/full/content/${BRANCH}.zip
  unzip -o ${DIR}/volumes/full/content/${BRANCH}.zip -d ${DIR}/volumes/full/content > unzip.log
  rm -f  ${DIR}/volumes/full/content/${BRANCH}.zip 
  mv ${DIR}/volumes/full/content/dante-wiki-volume-${BRANCH}/wiki-dir ${DIR}/volumes/full/content/
  rmdir ${DIR}/volumes/full/content/dante-wiki-volume-${BRANCH}/
printf "DONE building template directory\n\n"


printf "*** Generating mediawiki configuration file directory\n"
  mkdir -p ${DIR}/conf
printf "DONE generating configuration file directory\n\n"


printf "*** Reading in configuration"
source ${DIR}/CONF.sh
printf "DONE reading configuration\n\n" 

## TODO: why set +e ?????
set +e
echo ""; echo "*** Fixing permission of config files\n" 
chmod -f 700 CONF.sh
chmod -f 700 CONF-backup.sh
echo "DONE fixing permissions of config files\n\n"
set -e


MWP=${DIR}/conf/mediawiki-PRIVATE.php
printf "*** Generating mediawiki-PRIVATE configuration file at ${MWP}\n"
  rm   -f ${MWP}
  echo  "<?php "   > ${MWP}
  echo "\$wgPasswordSender='${SMTP_SENDER_ADDRESS}';          // address of the sending email account                            " >> ${MWP}
  echo "\$wgSMTP = [                                                                                                             " >> ${MWP}
  echo  "  'host'     => '${SMTP_HOSTNAME}',                 // hostname of the smtp server of the email account  " >> ${MWP}
  echo  "  'IDHost'   => 'localhost',                        // sub(domain) of your wiki                                             " >> ${MWP}
  echo  "  'port'     => ${SMTP_PORT},                       // SMTP port to be used      " >> ${MWP}
  echo  "  'username' => '${SMTP_USERNAME}',                 // username of the email account   " >> ${MWP}
  echo  "  'password' => '${SMTP_PASSWORD}',                 // password of the email account   " >> ${MWP}
  echo  "  'auth'     => true                                // shall authentisation be used    " >> ${MWP}
  echo "]; "                                  >> ${MWP}
  echo "\$wgLocaltimezone='${LOCALTIMEZONE}';"    >> ${MWP}
  echo "?>  "                                 >> ${MWP}
  cp ${MWP} ${DIR}/volumes/full/content/wiki-dir
  rm ${MWP}
printf "DONE generating mediawiki-PRIVATE configuration file at ${MWP}\n\n"


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


printf "*** Initial contents copied to volume directory to make it accessible in docker volume for later"
  cp ${DIR}/initial-contents.xml  ${DIR}/volumes/full/content/wiki-dir/initial-contents.xml
  cp ${DIR}/initial-mainpage.wiki ${DIR}/volumes/full/content/wiki-dir/initial-mainpage.wiki
printf "DONE copying in initial contents"

LAP_VOLUME=lap-volume

printf "*** Building docker volume and copying in files\n"
  docker volume create ${LAP_VOLUME}
  #  -rm  automagically remove container when it exits
  docker run --rm --volume ${DIR}/volumes/full/content:/source --volume ${LAP_VOLUME}:/dest -w /source alpine cp -R wiki-dir /dest
printf "DONE building docker volume\n\n"


DOCKER_TAG=latest

printf "*** Pulling Docker Images from docker hub, tag ${DOCKER_TAG} "
  docker pull clecap/lap:${DOCKER_TAG}
  docker pull clecap/my-mysql:${DOCKER_TAG}
printf "DONE pulling docker images\n\n"

printf "*** Retagging docker images into local names for install mechanisms ... "
  docker tag clecap/lap:${DOCKER_TAG} lap
  docker tag clecap/my-mysql:${DOCKER_TAG} my-mysql
printf "DONE\n\n"

printf "*** Starting both containers..."
  ${DIR}/images/lap/bin/both.sh --db my-test-db-volume --vol ${LAP_VOLUME}
printf "DONE starting containers"


MYSQL_CONTAINER=my-mysql

printf "*** Waiting for database to come up ... \n"
  printf "PLEASE WAIT AT LEAST 1 MINUTE UNTIL NO ERRORS ARE SHOWING UP ANY LONGER\n\n"
# while ! docker exec ${MYSQL_CONTAINER} mysql --user=root --password=${MYSQL_ROOT_PASSWORD} -e "SELECT 1" >/dev/null 2>&1; do
  while ! docker exec ${MYSQL_CONTAINER} mysql --user=root --password=${MYSQL_ROOT_PASSWORD} -e "SELECT 1"; do
    sleep 1
    echo "   Still waiting for database to come up..."
  done
printf "DONE: database container is up\n\n"


printf "*** Fixing permissions of files ... \n"
  docker exec -it my-lap-container chown -R ${OWNERSHIP} /var/www/html/wiki-dir
printf "DONE fixing permissions of files\n\n"





printf "*** Initializing Database"

# TODO: MYSQL PASSWORD
# volumes/full/spec/wiki-db-local-initialize.sh mysite https://localhost:4443 acro adminpassword sqlpassword

echo ""; echo "******* initialize-dante.sh: MW_SITE_NAME=${MW_SITE_NAME}  MW_SITE_SERVER=${MW_SITE_SERVER}  SITE_ACRONYM=${SITE_ACRONYM}  ADMIN_PASSWORD=${ADMIN_PASSWORD}  MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}"

${DIR}/volumes/full/spec/wiki-db-local-initialize.sh  "${MW_SITE_NAME}"  "${MW_SITE_SERVER}"  "${SITE_ACRONYM}"  "${ADMIN_PASSWORD}"  "${MYSQL_ROOT_PASSWORD}"

# Fix permissions also for the files newly generated right now
docker exec -it my-lap-container chown -R ${OWNERSHIP} /var/www/html/wiki-dir







printf "*** Setting up drawio as an external service (the extension is set up together with mediawiki in cmd.sh and wiki-init.sh)\n"
  docker exec -it my-lap-container mkdir -p /var/www/html/wiki-dir/external-services/draw-io/
  docker exec -it my-lap-container wget https://github.com/clecap/drawio/archive/refs/heads/dev.zip -O /var/www/html/wiki-dir/external-services/dev.zip
  docker exec -it my-lap-container unzip -o /var/www/html/wiki-dir/external-services/dev.zip -d /var/www/html/wiki-dir/external-services/draw-io/
  docker exec -it my-lap-container rm /var/www/html/wiki-dir/external-services/dev.zip
printf "DONE setting up drawio\n\n"


printf "*** Fix permissions ..."
  docker exec -it my-lap-container chown -R ${OWNERSHIP} /var/www/html/wiki-dir
printf "DONE fixing permissions \n\n"


printf "*** Installer install-dante.sh completed\n\n"




printf "*** THE INSTALLATION HAS COMPLETED *** \n"
printf "*** DanteWiki should now be available locally at ${DANTE_WIKI_URL}/wiki-dir/index.php"
printf "*** You can now install initial content ***"

trap : EXIT         # switch trap command back to noop (:) on EXIT