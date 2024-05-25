

## Preparation of an ssh based Backup Server

Prepare a server which allows to drop-off files by authentication via an ssh key file.

1. **User:** Add user `backmeup` to the server.
2. **Dump area:** Make a directory on the server which will serve as dump area. Ensure that it has owner backmeup and permissions 700. Below we will use `/opt/dantewiki-backup`.
2. **Script:** Add the following script as file `back.sh` to the home directory of that user: Use the apropriate path name for `DUMP_DIR`.

```
#!/bin/bash
DUMP_DIR=/opt/dantewiki-backup
regex="^[a-zA-Z0-9_\-]+.[a-zA-Z0-9]+$"
if [[ $1 =~ $regex ]]; then
  cat /dev/stdin > ${DUMP_DIR}/$1
  chmod 400 ${DUMP_DIR}/$1
  ls -l ${DUMP_DIR}
  df -h ${DUMP_DIR}
else
    echo "Provided file name $1 did not match regular expression"
    ls -l ${DUMP_DIR}
    df -h ${DUMP_DIR}
fi
```

3. **Permissions:** Ensure that this script file is executable to the user only.

```
chmod 700 back.sh
```

4.
4.
5. **Restrict** the ssh login of that specific key by adding in file `~backmeup/.ssh/authorized_keys` in front of the specific key the following command restriction:

```
command="/home/backmeup/back.sh ${SSH_ORIGINAL_COMMAND}" ssh-rsa AAAAB3NzaC
```

#### Explanation:

1. The command restriction ensures that under the specific key only the specific command bask.sh can be executed.
2. Any command string which is supplied by the ssh client as part of the ssh call will be made available in environment variable SSH_ORIGINAL_COMMAND
3. The script will treat this as a file name and will ensure by a regex check that no .. or tilde or other illegal file system navigation will be hacked in.

## Preparation of AWS S3 based backup Server