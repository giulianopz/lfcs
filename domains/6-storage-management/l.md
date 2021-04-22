## Create and configure file systems

### 1. Create a Partition

Before creating a file system, make sure you have enough unallocated disk space (or free cylinders).

Check disk space: `sudo fdisk -l`

Create a partition on the hard drive which has enough free space:
```
sudo fdisk /dev/sda
>Press n
>Press p
>Press “Enter” for default starting cylinder”
>Enter 100MB+
>Now Change the partition type to 83 and finally reboot the system.
```

### 2. Set Disk Label on the partition

Set a disk label named **datafiles** for the disk partition: 
```
sudo e2label /dev/sda3 datafiles
# or, equally
tune2fs -L datafiles /dev/sda3
```

### 3. Create a filesystem

In Linux, you can create filesystem using `mkfs`, `mkfs.ext2`, `mkfs.ext3`, `mkfs.ext4`, `mke4fs` or `mkfs.xfs` commands. 

Create an ext4 filesystem on the '/dev/sda3' disk partition: `sudo mkfs.ext4 /dev/sda3`

### 4. Mounting a Filesystem

The most commonly used method for mounting the filesystem is either manually using `mount` command or by adding entries in `/etc/fstab` file, so that filesystem gets mounted during boot time: `sudo mount /dev/sda3 /data`

You can verify by executing the following command:
```
sudo mount | grep -i sda3
>/dev/sda3 on /data type ext4 (rw)
```

You can run `df -h` or `lsblk` command to get mounted device information such as mount point, filesystem size, etc.

### 5. Configure a filesystem

> Note: It is not recommend to run tune2fs on a mounted file system. 

To convert an ext2 file system to ext3, enter: `tune2fs -j <block_device>`

The most commonly used options to tune2fs are:

- `-c` (max-mount-counts), to adjust the maximum mount count between two file system checks
- `-C` (mount-count), to set the number of times the file system has been mounted
- `-i n[d|m|w]` (interval-between-checks), to adjust the maximum time between two file system checks
- `-m` (reserved-blocks-percentage), to set the percentage of reserved file system blocks
- `-r` (reserved-blocks-count) to set the number of reserved file system blocks
- `-L` (volume-label), to set the volume label of the filesystem.

Use the tune2fs command to adjust various tunable file system parameters on ext2, ext3, and ext4 file systems. Current values are displayed by using the -l option: `tune2fs –l /dev/xvda1`

Alternatively, use the dumpe2fs command to display file system parameters: `dumpe2fs /dev/xvda1`

> Note: The xfs_admin command is the rough equivalent of tune2fs for XFS file systems.