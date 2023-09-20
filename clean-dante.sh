#!/bin/bash

# Cleaning up a dante installation

## NOTE: The original of this file currently is in dante-wiki-production
 
# get directory where this script resides wherever it is called from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


usage() {
  echo "Usage: $0   and add one or more options on what to clean."
  echo "Clean files:        --files         "
  echo "Clean volumes:      --volumes       "
  echo "Clean containers:   --containers       "
  echo "Clean images:       --images        "
  echo "Clean networks:     --networks     "
  echo "Clean all:          --all          "
  echo "Clean most:         --most      (all except images)  "
 exit 1
}

cleanFiles () {
  echo "*** Removing generated directories"
  rm -Rf ${DIR}/volumes
  rm -Rf ${DIR}/conf
echo "DONE removing generated directories"
}

cleanVolumes () {
  echo "*** Cleaning up docker volumes generated..."
  docker volume rm my-test-db-volume
  docker volume rm sample-volume
  docker volume rm lap-volume
  echo "DONE cleaning up docker volumes generated"
}

cleanContainers () {
  echo "*** Stopping and removing docker containers"
  docker container stop my-lap-container -t 0
  docker container rm my-lap-container
  docker container stop my-mysql -t 0
  docker container rm my-mysql
  echo "DONE stopping and removing docker containers"
}

cleanImages () {
  echo "*** Cleaning up docker images..."
  docker rmi -f $(docker images -aq)
  echo "DONE cleaning up docker images"
}

cleanNetworks () {
  echo "*** Cleaning up docker networks generated..."
  docker network   rm dante-network
  echo "DONE cleaning up docker networks generated"
}

cleanAll () {
  cleanFiles
# CAVE: FIRST the containers and only then the volumes
  cleanContainers
  cleanVolumes
  cleanImages
  cleanNetworks
}

cleanMost () {
  cleanFiles
# CAVE: FIRST the containers and only then the volumes
  cleanContainers
  cleanVolumes
  cleanNetworks
}

display () {
  echo "";echo ""; echo "*** Displaying existing docker resources..."
  echo ""; echo "*** CONTAINERS:"
  docker container ls
  echo ""; echo "*** NETWORKS:"
  docker network ls
  echo ""; echo "*** VOLUMES:"
  docker volume ls
  echo ""; echo "*** IMAGES:"
  docker image ls
  echo ""; echo "DONE displaying docker resources"
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


