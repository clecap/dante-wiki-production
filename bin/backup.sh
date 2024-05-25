#!/bin/ash

#
# Script which will be used inside of the container of a containerized DanteWiki to generate regular backups
# and send information on this to the intended user
#

# Example:   clemens@clemens-cap.de  heinrich "Math Wiki"  backmeup  ki40.iuk.one

# Email address of the recipient of the backup completed email
MAIL=$1

# Email address to be used as sender of the backup completed email
FROM=$2

# Short name (preferably without blank), identifying the source wiki
SOURCE_NAME=$3

TARGET_USER=$4
TARGET_HOST=$5

# Directory prefix for the wiki directory inside of the container
PREFIX=wiki-dir

# Subject of email
SUBJECT="Report on dump of DanteWiki ${PREFIX} to ${TARGET_HOST}"

# Name of the
DUMP_FILE_NAME="${REMOTE_PATH}/wiki-xml-dump-$(date +%d.%m.%y).xml"


# Name of a temporary file for building up the mail
TMPFILE=`mktemp`

DUMPUSER=backmeup

# request proper newline behavior of shell
shopt -s xpg_echo

# generate header in mail file
echo "To: $MAIL"   >> $TMPFILE
echo "From: $FROM" >> $TMPFILE
echo "Subject: $SUBJECT" >> $TMPFILE

php /var/www/html/${PREFIX}/maintenance/dumpBackup.php --full --include-files --uploads | ssh ${TARGET_USER}@${TARGET_HOST} 'cat > ${DUMP_FILE_REMOTE}'

ssh ${TARGET_USER}@$TARGET_HOST "ls -l -t $TARGET_PATH" >> $TMPFILE

# dispatch email
msmtp $MAIL < $TMPFILE
