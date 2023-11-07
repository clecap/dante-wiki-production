#!/bin/bash

# Cleaning up a dante installation

## NOTE: The original of this file currently is in dante-wiki-production
 
# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR="${DIR}/../"


usage() {
  echo "Usage: $0   and add one or more options on what to clean."
  echo "Clean files:        --files      ALL files are removed"
  echo "Clean volumes:      --volumes       "
  echo "Clean containers:   --containers       "
  echo "Clean images:       --images        "
  echo "Clean networks:     --networks     "
  echo "Clean all:          --all          "
  echo "Clean most:         --most      (all except images)  "
 exit 1
}


## this does not remove all files TODO !!!
function cleanFiles () {
  echo "*** Removing all files (NOT all)"
  rm -Rf ${TOP_DIR}/volumes/full
  rm -Rf ${TOP_DIR}/images
  rm -Rf ${TOP_DIR}/conf
echo "DONE removing generated directories"
}


function cleanVolumes () {
  echo "*** Cleaning up docker volumes generated..."
  docker volume rm my-test-db-volume
  docker volume rm sample-volume
  docker volume rm lap-volume
  echo "DONE cleaning up docker volumes generated"
}


function cleanContainers () {
  echo "*** Stopping and removing docker containers"
  docker container stop my-lap-container -t 0
  docker container rm my-lap-container
  docker container stop my-mysql -t 0
  docker container rm my-mysql
  echo "DONE stopping and removing docker containers"
}


function cleanImages () {
  echo "*** Cleaning up docker images..."
  docker rmi -f $(docker images -aq)
  echo "DONE cleaning up docker images"
}


function cleanNetworks () {
  echo "*** Cleaning up docker networks generated..."
  docker network   rm dante-network
  echo "DONE cleaning up docker networks generated"
}


function cleanAll () {
  cleanFiles
# CAVE: FIRST the containers and only then the volumes
  cleanContainers
  cleanVolumes
  cleanImages
  cleanNetworks
}


function cleanMost () {
  cleanFiles
# CAVE: FIRST the containers and only then the volumes
  cleanContainers
  cleanVolumes
  cleanNetworks
}


function display () {
  printf "\n\n"
  printf "********************************************\n"
  printf "*** Displaying existing docker resources ***\n"
  printf "********************************************\n\n"
  printf "*** CONTAINERS:\n"
  docker container ls
  printf "\n\n*** NETWORKS:\n"
  docker network ls
  printf "\n\n*** VOLUMES:\n"
  docker volume ls
  printf "\n\n*** IMAGES:\n"
  docker image ls
  printf "\n\nDONE displaying docker resources"
}


##
## Parse command line
##
# region
if [ "$#" -eq 0 ]; then
  usage
else 
  display
  while (($#)); do
    case $1 in 
      (--files) 
         cleanFiles;;
      (--volumes) 
        cleanVolumes;;
      (--containers)
        cleanContainers;;
      (--images)
        cleanImages;; 
      (--networks)
        cleanNetworks;;
      (--all)
        cleanAll;;
      (--most)
        cleanMost;;
    esac
    shift 1
  done
  display
fi


