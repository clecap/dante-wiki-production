#!/bin/bash
#

# TODO should be generated automagically somewhere  similar as mysql root password and also stored in private directory
# The name of a user which will be entitled to do a dump of the entire mysql installation
MYSQL_DUMP_USER=username
MYSQL_DUMP_PASSWORD=otherpassword

##
## Below values should not be changed unless you know what you are doing
##

SITE_ACRONYM=acro
LOCALTIMEZONE="Europe/Berlin"
DEFAULT_DB_VOLUME_NAME=my-mysql-data-volume

# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR="${DIR}"


if test -f ${TOP_DIR}/../generated-conf-file.sh; then
  printf "\n\n *** CONF.sh: A manually generated configuration file exists at ${TOP_DIR}/../generated-conf-file.sh"
  source ${TOP_DIR}/../generated-conf-file.sh
fi

MW_SITE_SERVER=${SERVICE}://${MW_HOSTNAME}/
