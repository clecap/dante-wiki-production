# DanteWiki Production

<b>This repository</b> https://github.com/clecap/dante-wiki-production is for 
1. **end users** wanting to install DanteWiki on their machine and for 
2. **administrators** wanting to roll out DanteWikis automatically for a larger number of users.

The repository for <b>development</b> work can be found here: https://github.com/clecap/dante-wiki

## Requirements for Installing DanteWiki

<table>
<tr><td><b>Ecosystem</b></td><td><b>Recommended:</b> Linux, MacOS<br>Windows (Win 10 and 11 with WSL Windows Subsystem for Linux)</td></tr>
<tr><td><b>Deployment<br> Environment</b></td><td>Docker<br>
  <a href="doc/README-docker.md">Preparing docker on a Debian VM</a><br>
  <a href="https://docs.docker.com/engine/install/">Preparing docker desktop on an arbitrary machine</a>
</td></tr>
<tr><td><b>Software</b></td><td>
 Installed <code>/bin/bash</code> and <code>curl</code></td></tr>
<tr><td><b>CPU</b></td><td>minimum 2 vCPUs, recommended 4 vCPUs</td></tr>
<tr><td><b>RAM</b></td><td>minimum 6GB, recommended 8 GB</td></tr>
<tr><td><b>DISC</b></td><td>20-30 GB recommended</td></tr>
</table>

<details>
<summary><b>Explanations:</b> (Click on triangle)</summary>su

<b>Docker:</b> DanteWiki is based on two Docker images, so you need a possibility to run Docker images. A traditional docker server is fine, but DanteWiki will also run on medium-sized laptops. It consists of a web-server, a PHP application process, which is a MediaWiki modification, and a number of latex processes. It uses extensive caching. It is not a microservice architecture and can make use of 
multicore / multithreade architectures for speeding up reaction time.

<b>Requirements:</b> We currently run the system on our development machine with 8 vCPUs, 8 GB Memory and 30 GB Disc and we are studying performance to cut down on this.

</details> 

## Installation for End Users

### Basic Installation
1. **Terminal:** Open a terminal window to the machine where you want to install. <br>
  Must use a user name having docker rights.
2. **Shell:** Ensure that you are running `/bin/bash`.<br>
  Check the shell you are running with `echo $SHELL`.<br>
  If needed switch to the required shell by `/bin/bash`.
2. **Directory:** Navigate to a directory into which you want to install. 
  A good place is your home directory.
  This installation procedure will generate a directory named `dante` inside of the directory you just navigated to. 
3. **Run:** `Copy-and-paste` the following line into your shell and press return.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/clecap/dante-wiki-production/HEAD/bin/quick-install.sh)"
```
4. **Configuration:** Answer the questions posed by the interactive shell.
5. **Wait** several minutes until completion.

### Adding an https Certificate

If you want to provide a trustworthy authentication of and encrypt the communication with your DanteWiki using https, you can provide a certificate and a private key using below steps. Below instructions assume that the working directory of your shell still is the directory where you started the installation procedure. This directory should contain the sub-directory `dante`.

1. **Obtain** an X.509 certificate and a matching private key for use with https. 
    1. The root certificate of the CA should be contained in the ca-certificates packahe of Alpine (which for most commercial CAs they probably are).
    1. Certificate and key files must be in `PEM` (privacy enhanced mail) format. 
    1. it is not necessary that the certificate contains the complete certificate chain.
1. **Copy** the certificate (as file `server.pem`) and the private key (as file `server.key`) to the directory `dante/KEYS-AND-CERTIFICATES`.

```
scp <user>@<host>:<path-to-certificate-file> ./dante/KEYS-AND-CERTIFICATES/server.pem
scp <user>@<host>:<path-to-key-file> ./dante/KEYS-AND-CERTIFICATES/server.key
```

3. **Install** the certificate and the private key into the container, protect them, and restart the web-server:
```
./dante/dante-wiki-production-master/bin/installl-keys.sh
```

### Updates

### Repeacted Installations

This process has to be repeated after every update, since an update removes the container.





<b>Note:</b> 
If you repeat the installation, no questions will be asked, but the file `dante/private/generated-conf-file.sh.sh` will be used. If you want to change the answers you gave in the first installation, you should edit this file manually
or delete it before running the installation.

<details>
<summary><b>Explanations:</b> (Click on triangle)</summary>

<div style="background-color:cyan">

`curl` will download an install script and `/bin/bash` will execute it on your machine.

Explanation of the curl parameters:
<table style="border-collapse:collapse;" cellpadding=0 cellspacing=10>
<tr><td>-f</td><td>Fail silently on server errors.</td></tr>
<tr><td>-s</td><td>Do not show a progress meter.</td></tr>
<tr><td>-S</td><td>Show error messages on all other errors.</td></tr>
<tr><td>-L</td><td>Follow redirects when received from the server.</td></tr>
</table>
</div>
</details>


## Installation  for Administrators

TODO. This description will allow for a mass installation of several instances as based on pre-prepared configuration files.

Copy files server.key and server.pem into  directory dante-wiki-production-master

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

```
Copy the private key of the server into conf/server.key
Copy the public key of the server into conf/server.pem
```


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

## Backup of DanteWiki

TBD

## Restore of DanteWiki

### Restore by Command Line Interface



### Restore by Browser User Interface




## Updating DanteWiki

DanteWiki is software in development. As it follows the perpetual-beta philosophy of Web 2.0 we will see updates.

For small updates you can execute `update-dante.sh`. 

It is good operational practice to make a backup of data before every update.
