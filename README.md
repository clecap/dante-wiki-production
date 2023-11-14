# DanteWiki Production

This repository https://github.com/clecap/dante-wiki-production is for **end users** wanting to install DanteWiki.

For development work on DanteWIki see https://github.com/clecap/dante-wiki

## Requirements for Installing DanteWiki

<details>
<summary><b>Summary:</b> (Click on triangle for additional explanations.)

<table>
<tr><td><b>OS</b></td><td>Docker environment <br>
  [Preparing docker on a VM](https://github.com/clecap/dante-wiki-production/doc/README-docker.md Preparing docker on a VM)
</td></tr>
<tr><td><b>Software</b></td><td>Preferably LINUX or Mac OS <br> Windows with Linux extensions <br>
 Installed <code>/bin/bash</code> and <code>curl</code></td></tr>
<tr><td><b>CPU</b></td><td>minimum 2 vCPUs, recommended 4 vCPUs</td></tr>
<tr><td><b>RAM</b></td><td>minimum 6GB, recommended 8 GB</td></tr>
<tr><td><b>DISC</b></td><td>20-30 GB recommended</td></tr>
</table>
</summary>

DanteWiki is based on two Docker images, so you need a possibility to run Docker images. A traditional
docker server is fine, but DanteWiki will also run on medium-sized laptops. It consists of a web-server,
a PHP application process, which is a MediaWiki modification, and a number of latex processes. 
It uses extensive caching. It is not a microservice architecture and can make use of several CPUs
for speeding up reaction time.

We currently run the system on our development machine with 8 vCPUs, 8 GB Memory and 30 GB Disc
and we are studying performance to cut down on this.

</details>

## Installation


<details>
<summary><b style="font-size:larger">Quick Install:</b> (Click on triangle for further <b>explanations</b>.)

1. Open a terminal shell on the machine where you want to install.
2. Navigate to a directory into which you want to install. A good place is your home directory.
  The procedure will generate a directory named `/dante` in your home directory.
3. `Copy-and-paste` the following line into your shell and press execute.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/clecap/dante-wiki-production/HEAD/quick-install.sh)"
```

4. Edit file `CONF.sh`to set an initial password and adjust the initial URL (comments in the file)
5. Execute in the shell the command `./complete-install.sh` and wait several minutes for completion.
</summary>

<div style="background-color:lightgrey">

##### Explanations:
`curl` will download an install script and `/bin/bash` will execute it on your machine.
<details>
<summary>Explanations of the curl parameters</summary>
<table>
<tr><td>-f</td><td>Fail silently on server errors.</td></tr>
<tr><td>-s</td><td>Do not show a progress meter.</td></tr>
<tr><td>-S</td><td>Show error messages on all other errors.</td></tr>
<tr><td>-L</td><td>Follow redirects when received from the server.</td></tr>
</table>
</details>

<details>
<summary>Explanation of what `quick-install.sh` does.</summary>

1.
2.
3.

</details>
<hr>

</details>
</div>


### Manual Insta

1. Log in to the installation machine as a normal user.
2. Navigate to a directory which shall later contain the installation directory.
2. Download the zip archive at https://github.com/clecap/dante-wiki-production/archive/refs/heads/master.zip into that.
3. Unzip file `master.zip` in that directory.
4. Navigate into the newly generated installation directory `dante-wiki-production-master`
5. **Edit the configuration file** `CONF.sh` in `dante-wiki-production-master`. 
  This step is essentially about naming your Wiki and entering an initial password.
  The data required in the configuration file is described by comments directly in this file. 
  You might want to consult the section on configuration changes below before editing this file.
6. In case you use https: Copy the https server private key file `server.key` and the https server certificate file `server.pem` 
into directory `dante-wiki-production-master`.
7. Run DanteWIki installation script `install-dante.sh` (this may take a while).

#### Cheat Sheet for Installation Commands

```
wget https://github.com/clecap/dante-wiki-production/archive/refs/heads/master.zip
unzip master.zip
cd dante-wiki-production-master

vi CONF.sh

Copy files server.key and server.pem into  directory dante-wiki-production-master

./install-dante.sh
```

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


### Installing HTTPS keys and certificates

NOTE: For the certificate: We do not need a certificate chain in the file but only the certificate itself.

1. Navigate to the parent directory of `dante-wiki-production-master`.
2. Make directory `KEYS-AND-CERTIFICATES`
  mkdir `KEYS-AND-CERTIFICATES`
3. Assume `NAME`is any name of a host, conforming to [a-zA-Z0-9]*
4. Copy the private key into file `NAME.key`
4. Copy the certificate into file `NAME.pem`
5. Inject the files into the container and restart the webserver.
 In `dante-wiki-production-master/` execute `./volumes/full/spec/inject-keys.sh  NAME`

This process has to be repeated after every update, since an update removes the container.


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




## Backup and Restore of DanteWiki

TBD

## Updating DanteWiki

DanteWiki is software in development. As it follows the perpetual-beta philosophy of Web 2.0 we will see updates.

For small updates you can execute `update-dante.sh`. 

It is good operational practice to make a backup of data before every update.
