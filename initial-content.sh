#!/bin/bash

## The original of this file is in dante-wiki-production

# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${DIR}/.. 



USER=apache
# we need to run the maintenance scripts under the user under which the dante wiki is running normally in the server
# to get the correct permissions

LAP_CONTAINER=my-lap-container

DUMPFILE=/var/www/html/wiki-dir/initial-contents.xml

echo ""; echo "*** Initial contents will be uploaded to wiki"
echo ""; echo "*** IGNORE THE 'Done!' messages, they do not apply"
echo ""; echo "*** WAIT until we tell you that the installation is complete" 

# CAVE: this must run as user apache
echo ""; echo "* Doing namespaces 8"
docker exec  --user ${USER} ${LAP_CONTAINER}  php /var/www/html/wiki-dir/maintenance/importDump.php --namespaces '8' --debug ${DUMPFILE}
echo "DONE namespaces 8"

echo ""; echo "* Doing namespaces 10"
docker exec  --user ${USER} ${LAP_CONTAINER}  php /var/www/html/wiki-dir/maintenance/importDump.php --namespaces '10' --debug ${DUMPFILE}
echo "DONE namespaces 10"

echo ""; echo "* Doing the rest, but no uploads flag"
docker exec  --user ${USER} ${LAP_CONTAINER}  php /var/www/html/wiki-dir/maintenance/importDump.php --debug ${DUMPFILE}
echo "DONE rest, no upload flag"

echo ""; echo "* Doing the upload flag" 
docker exec  --user ${USER} ${LAP_CONTAINER}  php /var/www/html/wiki-dir/maintenance/importDump.php --uploads --debug ${DUMPFILE}
echo "DONE the upload flag"

echo ""; echo "*** Running some maintenance commands"
docker exec  --user ${USER} ${LAP_CONTAINER}  php /var/www/html/wiki-dir/maintenance/rebuildrecentchanges.php
docker exec  --user ${USER} ${LAP_CONTAINER} php /var/www/html/wiki-dir/maintenance/initSiteStats.php --update 
echo "DONE running some maintenance commands"


