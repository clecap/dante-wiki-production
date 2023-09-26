#!/bin/bash

## The original of this file is in dante-wiki-production

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


rm -f ${TOP_DIR}/main.zip

echo ""; echo "*** Making a backup of the configuration file CONF.sh"
cp ${DIR}/CONF.sh ${DIR}/CONF-backup.sh
echo "DONE making a backup of the configuration file CONF.sh";


printf "*** Building template directory ... "
  mkdir -p ${DIR}/volumes/full/content/wiki-dir
  tar --no-same-owner -xzvf ${DIR}/dante-deploy.tar.gz  -C ${DIR}/volumes/full/content > ${DIR}/tar-extraction-log
printc "DONE building template directory\n\~"


printf "*** Generating configuration file directory\n\n"
  mkdir -p ${DIR}/conf
printf "DONE generating configuration file directory\n\n"


echo ""; echo "*** Reading in configuration"
source ${DIR}/CONF.sh
echo "DONE reading configuration" 

## TODO: why set +e ?????
set +e
echo ""; echo "*** Fixing permission of config files" 
chmod -f 700 CONF.sh
chmod -f 700 CONF-backup.sh
echo "DONE fixing permissions of config files"
set -e

echo ""; echo "*** Generating mediawiki-PRIVATE.php"
MWP=${DIR}/conf/mediawiki-PRIVATE.php
rm -f ${MWP}
echo  "<?php "   > ${MWP}
echo "\$wgPasswordSender='${SMTP_SENDER_ADDRESS}';          // address of the sending email account                            " >> ${MWP}
echo "\$wgSMTP = [                                                                                                             " >> ${MWP}
echo  "  'host'     => '${SMTP_HOSTNAME}',                 // hostname of the smtp server of the email account  " >> ${MWP}
echo  "  'IDHost'   => 'localhost',                        // sub(domain) of your wiki                                             " >> ${MWP}
echo  "  'port'     => ${SMTP_PORT},                       // SMTP port to be used      " >> ${MWP}
echo  "  'username' => '${SMTP_USERNAME}',                 // username of the email account   " >> ${MWP}
echo  "  'password' => '${SMTP_PASSWORD}',                 // password of the email account   " >> ${MWP}
echo  "  'auth'     => true                                // shall authentisation be used    " >> ${MWP}
echo "]; ?>  " >> ${MWP}

cp ${MWP} ${DIR}/volumes/full/content/wiki-dir
echo "DONE generating mediawiki-PRIVATE.php"

echo "*** Generating customize-PRIVATE.php"
CUS=${DIR}/conf/customize-PRIVATE.sh
rm -f ${CUS}
echo "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}"        > ${CUS}
echo "MYSQL_DUMP_USER=${MYSQL_DUMP_USER}"                >> ${CUS}
echo "MYSQL_DUMP_PASSWORD=${MYSQL_DUMP_PASSWORD}"        >> ${CUS}
echo "DEFAULT_DB_VOLUME_NAME=${DEFAULT_DB_VOLUME_NAME}"  >> ${CUS}
echo "MW_SITE_SERVER=${MW_SITE_SERVER}"                  >> ${CUS}
echo "MW_SITE_NAME='${MW_SITE_NAME}'"                    >> ${CUS}
echo "DONE generating mediawiki-PRIVATE.php"


echo ""; echo "*** Initial contents copied to template directory"
cp ${DIR}/initial-contents.xml ${DIR}/volumes/full/content/wiki-dir/initial-contents.xml
echo "DONE copying"


echo ""; echo "*** Building docker volume"
LAP_VOLUME=lap-volume
docker volume create ${LAP_VOLUME}
echo "DONE building docker volume"

#  -rm  automagically remove container when it exits
echo "*** we have a PWD of: ${PWD} and a DIR of ${DIR}"
echo ""

docker run --rm --volume ${DIR}/volumes/full/content:/source --volume ${LAP_VOLUME}:/dest -w /source alpine cp -R wiki-dir /dest


printf "*** Pulling Docker Images from docker hub... "
  docker pull clecap/lap:latest
  docker pull clecap/my-mysql:latest
printf "DONE pulling docker images\n\n"


printf "*** Retagging docker images into local names for install mechanisms ... "
  docker tag clecap/lap:latest lap
  docker tag clecap/my-mysql:latest my-mysql
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

# volumes/full/spec/wiki-db-local-initialize.sh mysite https://localhost:4443 acro adminpassword sqlpassword

echo ""; echo "******* initialize-dante.sh: MW_SITE_NAME=${MW_SITE_NAME}  MW_SITE_SERVER=${MW_SITE_SERVER}  SITE_ACRONYM=${SITE_ACRONYM}  ADMIN_PASSWORD=${ADMIN_PASSWORD}  MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}"

${DIR}/volumes/full/spec/wiki-db-local-initialize.sh ${MW_SITE_NAME} ${MW_SITE_SERVER} ${SITE_ACRONYM} ${ADMIN_PASSWORD} ${MYSQL_ROOT_PASSWORD}

# Fix permissions also for the files newly generated right now
docker exec -it my-lap-container chown -R ${OWNERSHIP} /var/www/html/wiki-dir



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


printf "*** Installer install-dante.sh completed\n\~"

printf "*** Installer now calling inital.content\n\~"
${DIR}/initial-content.sh

echo ""; echo "";
echo "******** THE INSTALLATION IS COMPLETE"
echo "";
echo "*** DanteWiki should now be available locally at ${DANTE_WIKI_URL}/wiki-dir/index.php"

