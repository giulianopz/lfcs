## List, create, delete, and modify physical storage partitions

Lists information about all available or the specified block devices (including partitions and mount points): `lsblk`

Lists the partition tables for the specified devices (If no devices are given, those mentioned in /proc/partitions): `sudo fdisk -l`

Lists partitions the OS i uurently aware of: `cat /proc/partitions`

Reports on block devices attributes: `blkid`

Manipulate interactively a partition table according to its format with:
- `fdisk` for MBR
- `gdisk` for GPT 

> Note: gdisk, cgdisk and sgdisk all have the same functionality but provide different user interfaces. gdisk is text-mode interactive, sgdisk is command-line, and cgdisk has a curses-based interface.

To create a new partition on the empty disk, provide it as argument to fdisk:
```
fdisk /dev/sdb

>Welcome to fdisk (util-linux 2.32.1).
>Changes will remain in memory only, until you decide to write them.
>Be careful before using the write command.
```

The fdisk utility awaits our commands. Ccreate a new partition, by typing "n".
```
>Command (m for help): n
```

you are to create a primary partition, so the answer to the next question is "p".
```
>Partition type
>   p   primary (0 primary, 0 extended, 4 free)
>   e   extended (container for logical partitions)
>Select (default p): p
```

The next questions are about partition number, first and last sector, which will determine the actual size of the partition. To create a single partition that will cover the disk, accept the defaults values for partition number, first available sector to start with, and last sector to end with:
```
>Partition number (1-4, default 1): 
>First sector (2048-4194303, default 2048): 
>Last sector, +sectors or +size{K,M,G,T,P} (2048-4194303, default 4194303): 
>
>Created a new partition 1 of type 'Linux' and of size 2 GiB.
```

You are not limited to count in sectors when you define the end of the partition. As the utility hints, you can specify an exact size. For example, if you would like a partition of 1 GB in size, at the last sector you could provide:
```
>Last sector, +sectors or +size{K,M,G,T,P} (34-4194270, default 4194270): +1G
```

The partition is now complete, but as the utility points out on start, the changes are in-memory only until you write them out to the disk. This is on purpose and the warning is in place for a good reason: by writing out the changes to the disk, you destroy anything that resided on the sector range you cover with our new partition. If you are sure there will be no data loss, write the changes to disk:
```
>Command (m for help): w
>The partition table has been altered.
>Calling ioctl() to re-read partition table.
>Syncing disks.
```

Once done, inform the OS of partition table changes: `partprobe`

you can use the fdisk -l feature to be more specific by adding the device name you are interested in.
```
fdisk -l /dev/sdb

>Disk /dev/sdb: 2 GiB, 2147483648 bytes, 4194304 sectors
>Units: sectors of 1 * 512 = 512 bytes
>Sector size (logical/physical): 512 bytes / 512 bytes
>I/O size (minimum/optimal): 512 bytes / 512 bytes
>Disklabel type: dos
>Disk identifier: 0x29ccc11b
>
>Device     Boot Start     End Sectors Size Id Type
>/dev/sdb1        2048 4194303 4192256   2G 83 Linux
```

And in the output you can see that our disk now contains a new /dev/sdb1 partition that is ready to be used. 

---

Deleting partition is basically the same process backwards. The utility is built in a logical way: you specify the device you would like to work on, and when you select partition deletion with the "d" command, it will delete our sole partition without any question, because there is only one on the disk:
```
fdisk /dev/sdb

>Welcome to fdisk (util-linux 2.32.1).
>Changes will remain in memory only, until you decide to write them.
>Be careful before using the write command.
>
>
>Command (m for help): d
>Selected partition 1
>Partition 1 has been deleted.
```

While this is quite convenient, note that this tooling makes it really easy to wipe data from disk with a single keypress. This is why all the warnings are in place, you have to know what you are doing. Safeguards are still in place, nothing changes on disk until you write it out:
```
>Command (m for help): w
>The partition table has been altered.
>Calling ioctl() to re-read partition table.
>Syncing disks.

partprobe 

fdisk -l /dev/sdb
>Disk /dev/sdb: 2 GiB, 2147483648 bytes, 4194304 sectors
>Units: sectors of 1 * 512 = 512 bytes
>Sector size (logical/physical): 512 bytes / 512 bytes
>I/O size (minimum/optimal): 512 bytes / 512 bytes
>Disklabel type: dos
>Disk identifier: 0x29ccc11b
```

---

To create a GPT based partition layout, you'll use the gdisk (GPT fdisk) utility:
```
gdisk /dev/sdb   

>GPT fdisk (gdisk) version 1.0.3
>
>Partition table scan:
>  MBR: MBR only
>  BSD: not present
>  APM: not present
>  GPT: not present
>
>
>***************************************************************
>Found invalid GPT and valid MBR; converting MBR to GPT format
>in memory. THIS OPERATION IS POTENTIALLY DESTRUCTIVE! Exit by
>typing 'q' if you don't want to convert your MBR partitions
>to GPT format!
>***************************************************************
>
>
>Command (? for help): n
>Partition number (1-128, default 1): 
>First sector (34-4194270, default = 2048) or {+-}size{KMGTP}: 
>Last sector (2048-4194270, default = 4194270) or {+-}size{KMGTP}: 
>Current type is 'Linux filesystem'
>Hex code or GUID (L to show codes, Enter = 8300): 
>Changed type of partition to 'Linux filesystem'
>
>Command (? for help): w
>
>Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
>PARTITIONS!!
>
>Do you want to proceed? (Y/N): Y
>OK; writing new GUID partition table (GPT) to /dev/sdb.
>The operation has completed successfully.
```

From the point of commands you did the same, initiated creating a new partition with "n", accepted the defaults that cover the whole disk with the new partition, then written the changes to disk. Two new warnings appear, the first is there only because you partitioned the same disk with fdisk earlier, which was detected by gdisk. The last one is an additional "are you sure?" type of question, before you are allowed to finally overwrite that poor disk.

> Note: Listing GPT partitions requires the same switch to gdisk: gdisk -l </dev/sdb>

Deleting the GPT partition you created is done similar as in the MBR case, with the additional sanity check added:
```
gdisk /dev/sdb

>GPT fdisk (gdisk) version 1.0.3
>
>Partition table scan:
>  MBR: protective
>  BSD: not present
>  APM: not present
>  GPT: present
>
>Found valid GPT with protective MBR; using GPT.
>
>Command (? for help): d
>Using 1
>
>Command (? for help): w
>
>Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
>PARTITIONS!!
>
>Do you want to proceed? (Y/N): Y
>OK; writing new GUID partition table (GPT) to /dev/sdb.
>The operation has completed successfully.
```

Listing the disk now shows that we indeed deleted the GPT partition from the disk:
```
gdisk -l /dev/sdb

>GPT fdisk (gdisk) version 1.0.3
>
>Partition table scan:
>  MBR: protective
>  BSD: not present
>  APM: not present
>  GPT: present
>
>Found valid GPT with protective MBR; using GPT.
>Disk /dev/sdb: 4194304 sectors, 2.0 GiB
>Sector size (logical/physical): 512/512 bytes
>Disk identifier (GUID): 3AA3331F-8056-4C3E-82F3-A67254343A05
>Partition table holds up to 128 entries
>Main partition table begins at sector 2 and ends at sector 33
>First usable sector is 34, last usable sector is 4194270
>Partitions will be aligned on 2048-sector boundaries
>Total free space is 4194237 sectors (2.0 GiB)
>
>Number  Start (sector)    End (sector)  Size       Code  Name
```

---

Common partition type codes for Linux (specified as MBR/GPT):

- 82/8200: Linux swap
- 83/8300: Linux native partition
- ef/ef00: EFI System partition
- 8e/8e00: Linux Logical Volume Manager (LVM) partition
- fd/fd00: Linux raid partition with autodetect using persistent superblock