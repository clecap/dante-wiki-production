#!/bin/bash


## The original of this file is in dante-wiki-production

exit 1


exit 1

####### CAvE: both.sh cleans the container !!
####### CAVE: NOT FIT TO RUN


# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${DIR}/..

LAP_VOLUME=lap-volume

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
