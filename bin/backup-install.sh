#!/bin/bash

# install a backup feature to a server with ssh

MAIN_DIR=dante
BRANCH=master
REPO=dante-wiki-production
VERSION=1.51

printf "\n"
printf "****************************\n"
printf "*** BACKUP INSTALLER ${VERSION} ***\n"
printf "****************************\n\n" 

printf "*** Generating an identity for use on a remote backup server..."
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ''
printf "DONE\n"

printf "*** Injecting this identity into the remote backup server..."
########################################################
ssh-copy-id  backmeup@ki40.iuk.one



printf "*** Installing backup script into alpine crontab at /etc/periodic "

 /etc/periodic/daily



