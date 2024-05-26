# Preparation of Backup Servers

This document describes how to prepare a backup server.

## Preparation of an ssh based Backup System

1. **User:** Add a backup user to the server. In this example we will use user `backmeup`.
2. **Dump area:** Make a directory on the server which will serve as dump area. In this example we will use `/opt/dantewiki-backup`.
<br>Ensure directory has owner backmeup.
<br>Ensure directory has permissions 700. 
2. **Script:** Add the following script as file `back.sh` to the home directory of user. 
<br>Place the path name pf the doirectory into shell variable `DUMP_DIR`.

```
#!/bin/bash
DUMP_DIR=/opt/dantewiki-backup
regex="^[a-zA-Z0-9_\-\.][a-zA-Z0-9_\.-]*$"
echo "File name provided is $1"
if echo "$1" | grep -qE "$regex"; then
  echo "Starting to pipe input to file ${DUMP_DIR}/$1 at $(date)"
  cat /dev/stdin > ${DUMP_DIR}/$1
  echo "Finished to pipe input to file ${DUMP_DIR}/$1 at $(date)"
  chmod 400 ${DUMP_DIR}/$1
  ls -l --block-size=M ${DUMP_DIR}
  df --block-size=M ${DUMP_DIR}
else
    echo "The provided file name $1 did not match the given regular expression"
    ls -l --block-size=M ${DUMP_DIR}
    df --block-size=M ${DUMP_DIR}
fi
echo "Script completed at $(date)"
```

4. **Permissions:** Ensure that this script file is executable by the user `backmeup` only.

```
chmod 700 back.sh
```

5. **Client Keys:** On the client (which here is the docker container running the web server)

``` 
  rm /root/.ssh/id_rsa
  rm /root/.ssh/id_rsa.pub
  ssh-keygen -R full-domain-name-of-backup-host
#  -t rsa -b 4096    use an rsa key of block liength 4096
#  Write the new (public,private) key pair into id_rsa.pub and id_rsa
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ''
# The following will require the user backmeup to be set up on the host already.
ssh-copy-id  backmeup@full-domain-name-of-backup-host
``` 

6. **Restrict** the ssh login on the server of that specific key by adding in file `~backmeup/.ssh/authorized_keys` in front of the specific key the following command restriction:

```
command="/home/backmeup/back.sh ${SSH_ORIGINAL_COMMAND}" ssh-rsa AAAAB3NzaC...(key)
```

7. **Prepare Client Scripts**

Place backup.sh into /etc
Place backup-do.sh into /etc and adapt the encoded parameters

```
chmod 700 /etc/backup.sh
chmdo 700 /etc/backup-do.sh
ln -s /etc/backup-do.sh backup-do.sh
``` 

8. **Kickoff Cron Daemon**

Inside of the conatiner, run `crond`
<br>Check that it is running with ps


#### Explanation:

1. The command restriction ensures that under the specific key only the specific command bask.sh can be executed.
2. Any command string which is supplied by the ssh client as part of the ssh call will be made available in environment variable SSH_ORIGINAL_COMMAND
3. The script will treat this as a file name and will ensure by a regex check that no .. or tilde or other illegal file system navigation will be hacked in.

## Preparation of AWS S3 based backup Server