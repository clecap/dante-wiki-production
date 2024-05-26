#!/bin/bash

# install a backup feature which will do backups to a server using ssh for copying the backup

MAIN_DIR=dante
BRANCH=master
REPO=dante-wiki-production
VERSION=1.51

BACKUP_HOST=ki40.iuk.one
BACKUP_USER=backmeup

printf "\n"
printf "****************************\n"
printf "*** BACKUP INSTALLER ${VERSION} ***\n"
printf "****************************\n\n" 


printf "*** Generating an identity for use on a remote backup server..."
rm /root/.ssh/id_rsa
rm /root/.ssh/id_rsa.pub
ssh-keygen -R ${BACKUP_HOST}
#  -t rsa -b 4096    use an rsa key of block liength 4096
#  Write the new (public,private) key pair into id_rsa.pub and id_rsa
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ''
printf "DONE\n"

printf "*** Injecting this identity into the remote backup server..."
########################################################
ssh-copy-id  ${BACKUP_USER}@${BACKUP_HOST}

# command="/home/backmeup/back.sh ${SSH_ORIGINAL_COMMAND}" 


printf "*** Installing backup script into alpine crontab at /etc/periodic "

 /etc/periodic/daily



