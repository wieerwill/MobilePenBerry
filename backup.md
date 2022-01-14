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


# Backup Safety: RAID
Having a backup is great but always keep in mind, that every disk can failure even your backup drive. In order to prevent loss of data, you can choose to use a RAID (Redundant Array of Inexpensive Disks). RAIDs are available as Software or Hardware RAID:
- Software RAID: 
  - no special hardware needed (low cost)
  - needs more computation power (and energy) of your system
  - often less disk space
- Hardware RAID
  - RAID Controller Cards required (costs from mid budget to high budget)
  - takes up to no computation power of your system (as just using only a single drive that automatically backups itself in the background)
  - many Controllers enable more disks, e.g. one mid-cost controller can use 8 disks at once; more high-end controllers can even support up to 32 disks at once

Next to that there are different RAID options
- **0**: data are split up into blocks that get written across all the drives in the array. By using multiple disks (at least 2) at the same time, this offers fast read and write speeds. All storage capacity can be fully used with no overhead. The downside to RAID 0 is that it is NOT redundant, the loss of any individual disk will cause complete data loss
- **1**: a setup of at least two drives that contain the exact same data. If a drive fails, the others will still work. It is recommended for those who need high reliability. An additional benefit of RAID 1 is the high read performance, as data can be read off any of the drives in the array
- **5**: equires the use of at least 3 drives, striping the data across multiple drives like RAID 0, but also has a “parity” distributed across the drives. In the event of a single drive failure, data is pieced together using the parity information stored on the other drives
- **6**: is like RAID 5, but the parity data are written to two drives. That means it requires at least 4 drives and can withstand 2 drives dying simultaneously
- **10**: consists of a minimum for four drives and combine the advantages of RAID 0 and RAID 1 in one single system. It provides security by mirroring all data on secondary drives while using striping across each set of drives to speed up data transfers
- **50**: combines the straight block-level striping of RAID 0 with the distributed parity of RAID 5. This is a RAID 0 array striped across RAID 5 elements. It requires at least 6 drives
- **60**: combines the straight block-level striping of RAID 0 with the distributed double parity of RAID 6. That is, a RAID 0 array striped across RAID 6 elements. It requires at least eight drives

Creating a hardware RAID is just following the instructions of your Card manufactur.

## Creating a software RAID 1
Before you start, install the disks, boot up and list all your installed disks.
```bash
lsblk
```
This will present you all installed block devices with their corresponding name and size. Look for the devices you want to use for your RAID. Warning: the content of your RAID disks will be wiped in the next steps!!! Make sure to have no important data on that disk that isn't backuped elsewhere.

Prepare and create disk mirror, in this example disk `/dev/sdb`, change that to your disk.
```
sudo fdsik /dev/sdb
```
Follow the command line with those steps:
1. `g`: Create GPT disklabel
2. `n`: Create a partition on the disk. Use default partition number, first/last sector or change it as you like
3. `t`: select the first partition
4. `29`: choose parition type `Linux RAID`
5. `p`: print the new diskinfo and check label and size to be correct
6. `w`: write all changes to disk

Repeat those steps for each disk you want to use in your RAID. Check your new partitions with `lsblk`.

One of the most popular option to perform software RAID is to use MDADM. Install it on your system:
```bash
sudo apt install mdadm
```

With MDADM you can create disk arrays very easy, here an example with two disks:
```bash
sudo mdadm --create /dev/md0 --level=mirror --raid-devices=2 /dev/sdb /dev/sdc
```
After that a new block device `dev/md0` got created. To make sure the array is reassembled automatically each time the system (re)boots, save the configuration to `/etc/mdadm/mdadm.conf`:
```bash
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
```
Depending from RAID level and disk size it can take a while for MDADM to sync the data of both disks. Check your RAID status and health:
```bash
sudo mdadm --detail /dev/md0
```

Now this new block device has no filesystem. Create one and mount it to your system:
```bash
sudo mkfs.ext4 /dev/md0
sudo mkdir /mnt/raid
sudo mount /dev/md0 /mnt/raid
sudo chown -R <username>:<group> /mnt/raid  % set permissions to your user
```
Check your new RAID. If everything is working fine, you can add it to fstab to mount the device on boot:
```bash
echo '/dev/md0 /mnt/raid ext4 defaults,nofail 0 0' | sudo tee -a /etc/fstab
```


# Sources and more
[BorgBackup](https://borgbackup.readthedocs.io)

[dataplugs](https://www.dataplugs.com/en/raid-level-comparison-raid-0-raid-1-raid-5-raid-6-raid-10/)

[jensd.be](https://jensd.be/913/linux/build-configure-a-linux-based-nas)