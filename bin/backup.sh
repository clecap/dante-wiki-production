#!/bin/ash

#
# Script which will be used inside of the container of a containerized DanteWiki to generate regular backups
# and send information on this to the intended user
#

# Example:   clemens@clemens-cap.de  heinrich "Math Wiki"  backup-user  ki40.iuk.one

# Parameter 1: Email address of the recipient of the backup completed email
# Parameter 2: Email address to be used as sender of the backup completed email
# Parameter 3: Short name (preferably without blank), identifying the source wiki
# Parameter 4: User name on the remote machine
# Parameter 5: Fully qualified domain name of the remote machine to which the dump is sent

MAIL=$1
FROM=$2
SOURCE_NAME=$3
TARGET_USER=$4
TARGET_HOST=$5

MODE="dumpPagesBySsh"


# Directory prefix for the wiki directory inside of the container
PREFIX=wiki-dir

# Subject of email
SUBJECT="Report on dump of DanteWiki ${PREFIX} to ${TARGET_HOST} via ${DROP}"

# Name of the
DUMP_FILE_NAME="wiki-xml-dump-$(date +%d.%m.%y).xml"

# Name of a temporary file for building up the mail
TMPFILE=`mktemp`
TMPFILE2=`mktemp`

DUMPUSER=backmeup

# generate header in mail file
echo "To: $MAIL"         >> $TMPFILE
echo "From: $FROM"       >> $TMPFILE
echo "Subject: $SUBJECT" >> $TMPFILE

case "$MODE" in
  "dumpPagesBySsh")
    echo "backup.sh: Generating dump files via $MODE" >> $TMPFILE
    echo "" >> $TMPFILE
    php /var/www/html/${PREFIX}/maintenance/dumpBackup.php --full --include-files --uploads | ssh -o ServerAliveInterval=240 ${TARGET_USER}@${TARGET_HOST} ${DUMP_FILE_NAME} >> $TMPFILE 2>>$TMPFILE2
    echo "" >> $TMPFILE
    echo "backup.sh: Done generating dump files" >> $TMPFILE
    echo "" >> $TMPFILE
    echo "backup.sh: stderr of ssh is:" >> $TMPFILE
    cat $TMPFILE2 >> $TMPFILE
    ;;
  "aws")
    echo "AWS not yet implemented " >> $TMPFILE
    ;;
  *)
    echo "Unknown drop mode: $DROP" >> $TMPFILE
    ;;
esac


echo "Done dumping, now sending email"

# dispatch email

msmtp $MAIL < $TMPFILE

echo "Sent email"
