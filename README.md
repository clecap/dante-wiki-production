# DanteWiki

This repository https://github.com/clecap/dante-wiki-production is for end users wanting to install DanteWiki.

## Requirements for DanteWiki

DanteWiki is based on two Docker images, so you need a possibility to run Docker images. A traditional
docker server is fine, but DanteWiki will also run on a medium-sized laptop. It consists of a web-server,
a PHP application process, which is a MediaWiki modification, and a number of latex processes. 
It uses extensive caching. It is not a microservice architecture and can make use of several CPUs
for speeding up reaction time.

We currently run the system on our development machine with 8 vCPUs, 8 GB Memory and 20 GB Disc and we are
studying performance to cut down on this.

**CPU:**  minimum 2 vCPUs, recommended 4 vCPUs
**MEMORY:** minimum 6GB, recommended 8 GB
**DISK:** 8-10 GB recommended

## Installation

The instructions here are meant for a Linux or a MacOS machine with a running docker installation.

If you use a Windows machine you are yourself responsible for this mistake ;-)  
and should read https://programmerbear.com/why-microsoft-is-evil/ 

Maybe we will later provide installation files for Windows later.

### Description of Installation

1. Log in as a normal user and navigate to a directory which shall contain the installation directory.
2. Ensure that this directory has permission 700
3. Download the zip archive at https://github.com/clecap/dante-wiki-production/archive/refs/heads/main.zip into directory `dante`.
4. Unzip file `main.zip`
5. Navigate into the newly generated directory `dante-wiki-production-main`
6. Edit the configuration file `CONF.sh`. The data required in the configuration file is described by comments directly in this file. 
You might want to consult the section on configuration changes below before editing this file.
7. Run DanteWIki installation script `install-dante.sh` (this may take several minutes).

### Command Cheat Sheet for Installation

```
wget https://github.com/clecap/dante-wiki-production/archive/refs/heads/main.zip
unzip main.zip
cd dante-wiki-production-main
```

Alternatively:
```
curl -L https://github.com/clecap/dante-wiki-production/archive/refs/heads/main.zip --output main.zip
```

Edit using your favorite editor, for example: ```vi CONF.sh                                   ```

```./install-dante.sh```

### First Test

DanteWiki should now be up and running on the target machine at 

* http://localhost:8080/wiki-dir/index.php
* http://IP-ADDRESS-OF-MACHINE:8080/wiki-dir/index.php
* https://localhost:4443/wiki-dir/index.php (probably with some https security warning)
* https://IP-ADDRESS-OF-MACHINE:4443/wiki-dir/index.php (probably with some https security warning)

## Configuration Changes

Right now you can already use DanteWiki through the http protocol. 

Serving DanteWiki via http instead of https will cause some problems. 

1. Using http makes the system unsafe, as passwords and data could be eavesdropped by an attacker. 
2. Some features of the browser are only available to web pages which are serverd via https. 
  The automatic window placement on external monitors is just one of several examples.
  If you want to use these features, you will need https.
3. The configuration of DanteWiki web server currently uses a non-trusted certificate, since I cannot know
the domain under which you want to run it. This certificate produces a browser warning when accessing the service via https.

Therefore, you will want to make DanteWiki available via https. 

For this, three solutions are suggested. The optimal solution depends on your use case and your IT skills.

### 1. https Solution: Reverse Proxy

This is the most secure and convenient solution. It needs the most IT skills to set up.
Here, you will
* Set up a reverse proxy which directs the browser to the DanteWiki web server and
* Block access to ports 4443 and 8080 on the local machine.

### 2. https Solution: Server Certificate

Here, you will
* buy a web server certificate
* install the certificate into DanteWiki web server and
* change the configuration of DanteWiki web server to make the service available on port 443 and
* change the configuration of DanteWiki web server to redirect an access to port 8080 to port 443

### 3. https Solution: Localhost Certificate

Here, you will
* generate a certificate for localhost using mkcert and
* install the certificate for localhost on DanteWiki web server

### Port Change

We configured DanteWiki web server to use ports 4443 (for https) and 8080 (for http), as these ports most likely are
available on the target machine. However, these ports are not completely standard and require entering the port
number as part of the URL.

You may want to change the port numbers to the standard 443 (for https) and 80 (for http).

### How to Make Configuration Changes

You can enter the containers for introspection or configuration change by shell commands via

`docker exec -it my-lap-container /bin/ash`
`docker exec -it my-mysql /bin/ash`

There you have an Alpine shell (ash) and can navigate the container as needed.

Note, that the changes you make are persistent only as long as the lifetime of the container.

To prevent this, we will provide some automated shell scripts for the standard cases. This still has to be done.


## Running DanteWiki

TBD


## Backup and Restore of DanteWiki

TBD

## Updating DanteWiki

DanteWiki is software in development. As it follows the perpetual-beta philosophy of Web 2.0 we will see updates.

For small updates you can execute `update-dante.sh`. 

It is good operational practice to make a backup of data before every update.
