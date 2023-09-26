#!/bin/bash

## The original of this file is in dante-wiki-production



##
## CONFIGURE script
##
#
# Name of the branch in dante-wiki-volume which we are going to download
#
BRANCH=master


##### TODO
PRIVATE_KEY=server.key
PUBLIC_KEY=server.pem

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

printf "*** Making fresh template directory\n"
  rm -Rf ${DIR}/volumes/full/content
  mkdir -p ${DIR}/volumes/full/content/wiki-dir
printf "DONE mkdir completed\n\n"


printf "*** wget branch ${BRANCH} from dante-wiki-volume ...\n"
  rm -f ${DIR}/volumes/full/content/${BRANCH}.zip
  wget https://github.com/clecap/dante-wiki-volume/archive/refs/heads/${BRANCH}.zip -O ${DIR}/volumes/full/content/${BRANCH}.zip
  unzip  ${DIR}/volumes/full/content/${BRANCH}.zip -d ${DIR}/volumes/full/content > unzip.log
  mv ${DIR}/volumes/full/content/dante-wiki-volume-main/wiki-dir ${DIR}/volumes/full/content/
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

${DIR}/volumes/full/spec/wiki-db-local-initialize.sh ${MW_SITE_NAME} ${MW_SITE_SERVER} ${SITE_ACRONYM} ${ADMIN_PASSWORD} ${MYSQL_ROOT_PASSWORD}

# Fix permissions also for the files newly generated right now
docker exec -it my-lap-container chown -R ${OWNERSHIP} /var/www/html/wiki-dir





printf "*** Setting up public key infrastructure, if present\n\n"
  if [ -f $PRIVATE_KEY ]; then
    chmod 400 ${PRIVATE_KEY}
    printf "*** Found a private key at ${PRIVATE_KEY}, copying it in and fixing permissions ... \n" 
    docker cp $PRIVATE_KEY    /etc/ssl/apache2/server.key
    docker exec -it my-lap-container   chown root.root /etc/ssl/apache2/server.key
    docker exec -it my-lap-container   chmod 400 /etc/ssl/apache2/server.key
    printf "DONE\n\n"
  else
    printf "*** Found no private key, checked at ${PRIVATE_KEY}, nothing to do ... DONE\n\n"
  fi
  if [ -f $PUBLIC_KEY ]; then
    printf "*** Found a public key at ${PUBLIC_KEY}, copying it in and fixing permissions ... \n" 
    chmod 444 ${PUBLIC_KEY}
    docker cp $PUBLIC_KEY my-lap-container:/etc/ssl/apache2/server.pem
    docker exec -it my-lap-container   chown root.root /etc/ssl/apache2/server.pem
    docker exec -it my-lap-container   chmod 444 /etc/ssl/apache2/server.pem
    printf "DONE\n\n"
  else
    printf "*** Found no public key, checked at ${PUBLIC_KEY}, nothing to do ... DONE\n\n"
  fi
printf "DONE setting up public key infrastructure, if present\n\n"


printf "*** Setting up drawio\n"
  docker exec -it my-lap-container mkdir -p /var/www/html/wiki-dir/external-services/draw-io/
  docker exec -it my-lap-container wget https://github.com/clecap/drawio/archive/refs/heads/dev.zip -O /var/www/html/wiki-dir/external-services/dev.zip
  docker exec -it my-lap-container unzip /var/www/html/wiki-dir/external-services/dev.zip -d /var/www/html/wiki-dir/external-services/draw-io/
  docker exec -it my-lap-container rm /var/www/html/wiki-dir/external-services/dev.zip
printf "DONE setting up drawio\n\n"


printf "*** Fix permissions ..."
  docker exec -it my-lap-container chown -R ${OWNERSHIP} /var/www/html/wiki-dir
printf "DONE fixing permissions \n\n"


printf "*** Installer install-dante.sh completed\n\n"




#echo ""; echo "*** Initial contents copied to template directory"
#cp ${DIR}/initial-contents.xml ${DIR}/volumes/full/content/wiki-dir/initial-contents.xml
#echo "DONE copying"

###### TODO
##### CAVE: We not always want to do the inital content thing in an update !!!!!
#
#printf "*** Installer now calling inital.content\n\n"
#${DIR}/initial-content.sh
#
#
#


printf "*** THE INSTALLATION HAS COMPLETED *** \n"
printf "*** DanteWiki should now be available locally at ${DANTE_WIKI_URL}/wiki-dir/index.php"
printf "*** You

trap : EXIT         # switch trap command back to noop (:) on EXIT