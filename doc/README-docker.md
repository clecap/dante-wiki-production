# Remarks for Docker


## Installing docker on a Debian VM

#### Fix a locale problem inherent for most Debian installations
*   `sudo su locale-gen en_US.UTF-8`
* `sudo su -`
* Edit `/etc/default/locale` to have the following contents:
  ```
  LC_CTYPE="en_US.UTF-8"
  LC_ALL="en_US.UTF-8"
  LANG="en_US.UTF-8" 
  ```
* Log out and log in again.

#### Generate required user
* We need a user with a home directory (in which we install everything) and with shell /bin/bash.
  ```
  sudo adduser --disabled-password dante
  sudo chsh -s /bin/bash dante
  grep 'dante' /etc/passwd
  sudo grep 'dante' /etc/shadow
   ```

#### Install docker

* Install docker
  ```
  sudo apt update
  sudo apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common
  sudo curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh ./get-docker.sh --dry-run
  ```


## Some helpful commands and references

* Find out, which shell we are running in: 
 `echo $0`

* https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user


## Starting docker on a Debian VM
