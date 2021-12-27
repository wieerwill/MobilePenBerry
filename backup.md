# Backups
there are different types of backups. You can create them while the drive is online (mounted) or offline (unmounted). 

## offline Backup
`dd` is a disk utility tool that can copy your whole disk bit for bit. But that leads to copying also emtpy space and generating files as big as the volume. Pretty good and simple way to deal with this is simply pipe it via gzip, something like this:
```bash
# sdb is the identificator of your disk/partition
dd if=/dev/sdb | gzip > backup.img.gz
```
This way your image will be compressed and most likely unused space will be squeezed to almost nothing.
You would use this to restore such image back:
```bash
# sdb is the identifier where to play to backup to
cat backup.img.gz | gunzip | dd of=/dev/sdb
```

If you had a lot of files which were recently deleted, image size may be still large (deleting file does not necessarily zeroes underlying sectors).

## save partitions and MBR
Copy all the files from all the partitions preserving meta data
```bash
mkdir myimage/partition1
mkdir myimage/partition2
sudo cp -rf --preserve=all /media/mount_point_partition1/* myimage/partition1/
sudo cp -rf --preserve=all /media/mount_point_partition2/* myimage/partition2/
```

Extract the MBR
```bash
# of is place to write backup to
sudo dd if=/dev/sdX of=myimage/mbr.img bs=446 count=1
```

Partition the destination disk into partitions with sizes greater than copied data and should be of the same format and same flags using gparted.

Mount the freshly formatted and partitioned disk. On most computers, you just need to connect the disk and you can find the mounted partitions in /media folder.
Copy the previously copied data to destination partitions using following commands
```bash
sudo cp -rf --preserve=all myimage/partition1/* /media/mount_point_partition1/ 
sudo cp -rf --preserve=all myimage/partition2/* /media/mount_point_partition2/
```
Copy back the MBR
```bash
sudo dd if=myimage/mbr.img of=/dev/sdX bs=446 count=1
```


## Borg Backup
Borg backup is a great solution for online backups. Reasons are
- Space efficient storage of backups
- Secure, authenticated encryption
- Compression: LZ4, zlib, LZMA, zstd
- Mountable backups with FUSE

Install borg
```bash
sudo apt install borgbackup
```

You can create the backup on the same disk (absolutly not recommended), on another disk in the same system/computer (not recommended) or an seperate backup-disk/server (recommended). 

Before a backup can be made a repository has to be initialized, mount the disk and set your chosen path
```bash
borg init --encryption=repokey <BackupPath>
```
Now you can backup all sort of folders and files to this repository, for example the ~/src and ~/Documents directories and call the archive "Documents":
```bash
borg create <BackupPath>::Documents ~/src ~/Documents
```
All archives and content of specific archives inside the backup can be listed with
```bash
borg list <BackupPath> 
borg list <backupPath>::<ArchiveName>
```
To restore an archive and extract all files to the current directory:
```bash
borg extract <BackupPath>::<ArchiveName>
```
You can also delete an archive, for example to free space:
```bash
borg delete <BackupPath>::<ArchiveName>
```

## automate Borg
Borg can be scripted, that allows us to create repeating automatic backups. This is a modified example from the BorgBackup website.

The following example script is meant to be run daily by the root user on different local machines. It backs up a machine’s important files (but not the complete operating system) to a repository `~/backup/main` on a remote server. Some files which aren’t necessarily needed in this backup are excluded.
After the backup this script also uses the borg prune subcommand to keep only a certain number of old archives and deletes the others in order to preserve disk space.

Create a file with the current contents `nano backup.sh`
```bash
#!/bin/sh
# Setting this, so the repo does not need to be given on the commandline
export BORG_REPO=ssh://username@example.com:2022/~/backup/main
# paste the passphrase to not be asked everytime the script runs
export BORG_PASSPHRASE='XYZl0ngandsecurepa_55_phrasea&&123'
# helpers and error handling
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM
info "Starting backup"

# Backup the most important directories into an archive named after
# the machine this script is currently running on
borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
    --exclude-caches                \
    --exclude '/home/*/.cache/*'    \
    --exclude '/var/tmp/*'          \
    ::'{hostname}-{now}'            \
    /etc                            \
    /home                           \
    /root                           \
    /var                            \

backup_exit=$?

info "Pruning repository"
# maintain 7 daily, 4 weekly and 6 monthly archives of THIS machine
# '{hostname}-' prefix limits prune operation to this machine
borg prune                          \
    --list                          \
    --prefix '{hostname}-'          \
    --show-rc                       \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  6               \

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi
exit ${global_exit}
```

Before running, make sure that the repository is initialized as documented in Remote repositories and that the script has the correct permissions to be executable by the root user, but not executable or readable by anyone else, i.e. root:root 0700. To do that modify the script:
```bash
# make root single owner
sudo chown root:root ./backup.sh
# limit access to owner
sudo chmod 700 ./backup.sh
# make file executable
sudo cmmod +x ./backup.sh
# check permissions
ls -l ./backup.sh
```

Do not forget to test your created backups to make sure everything you need is being backed up and that the prune command is keeping and deleting the correct backups.



# Sources and more
[BorgBackup](https://borgbackup.readthedocs.io)