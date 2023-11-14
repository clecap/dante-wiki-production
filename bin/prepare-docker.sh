#!/biin/bash

apt-get install unzip

locale-gen en_US.UTF-8
echo "LC_CTYPE=\"en_US.UTF-8\"" > /etc/default/locale
echo "LC_ALL=\"en_US.UTF-8\""   >> /etc/default/locale
echo "LANG=\"en_US.UTF-8\""     >> /etc/default/locale 

adduser --disabled-password dante
chsh -s /bin/bash dante

apt update
apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://get.docker.com -o get-docker.sh
