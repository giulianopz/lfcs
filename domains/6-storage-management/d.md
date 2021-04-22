## Configure systems to mount file systems at or during boot

There are broadly two aproaches:

- per-user mounting (usually under /media)
- systemwide mounting (anywhere, often under /mnt) 

### 1. Per-user mounting

Per-user mounting does not require root access, it's just automating the desktop interface. Systemwide mounts (/etc/fstab) can allow access from before login, and are therefore much more suitable for access through a network, or by system services.

When you mount a disc normally with the file browser (e.g. Nautilus) it mounts disks by interacting with **udisks** behind the scenes. You can do the same thing on the command line with the udisks tool.

### 2. Systemwide mounting

Unlike DOS or Windows (where this is done by assigning a drive letter to each partition), Linux uses a unified directory tree where each partition is mounted at a mount point in that tree.

A **mount point** is a directory that is used as a way to access the filesystem on the partition, and mounting the filesystem is the process of associating a certain filesystem with a specific directory in the directory tree.

When providing just one parameter (either mout point or device) to the **mount** command, it will read the content of the /etc/fstab configuration file to check whether the specified file system is listed or not.

Usually when mounting a device with a common file system such as ext4 or xfs the mount command will auto-detect the file system type. However, some file systems are not recognized and need to be explicitly specified.

Use the -t option to specify the file system type: `mount -t <fs-type> <device> <mount-point>`

To specify additional mount options , use the -o option: `mount -o <options> <device> <mount-point>`

Multiple options can be provided as a comma-separated list.

The /etc/fstab file contains lines of the form `<device> <location> <Linux type> <options> <dump> <pass>`. Every element in this line is separated by whitespace (spaces and tabs):
```
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda2 during installation
UUID=a2db89ed-d599-4138-8838-0b950b6c3fbb /               ext4    errors=remount-ro 0       1
# /boot/efi was on /dev/sda1 during installation
UUID=AEF0-9F26  /boot/efi       vfat    defaults        0       1
# swap was on /dev/sda3 during installation
UUID=df17fdb9-57a4-4302-856e-3cd656848355 none            swap    sw              0       0
```

The first three fields are quite self-explanatory, while the others deserve a lenghtier explanation:

- **options**: the fourth field, (fs_mntops), describes the mount options associated with the filesystem.

    It is formatted as a comma separated list of options. It contains at least the type of mount plus any additional options appropriate to the filesystem type. For documentation on the available options for non-nfs file systems, see mount(8). For documention on all nfs-specific options have a look at nfs(5). Common for all types of file system are the options `noauto` (do not mount when `mount -a` is given, e.g., at boot time), `user` (allow a user to mount), and `owner` (allow device owner to mount), and `comment` (e.g., for use by fstab-maintaining programs). The `owner` and `comment` options are Linux-specific. For more details, see mount(8).

    Most frequently used mount options include:

    - `async`: allows asynchronous I/O operations on the file system being mounted
    - `auto`: marks the file system as enabled to be mounted automatically using `mount -a`. It is the opposite of noauto
    - `defaults`: this option is an alias for `async,auto,dev,exec,nouser,rw,suid`

    >  Note: Multiple options must be separated by a comma without any spaces. If by accident you type a space between options, mount will interpret the subsequent text string as another argument

    - `loop`: mounts an image (an .iso file, for example) as a loop device

    > Tip: This option can be used to simulate the presence of the disk’s contents in an optical media reader

    - `noexec`: prevents the execution of executable files on the particular filesystem (the opposite of `exec`)
    - `nouser`: prevents any users (other than root) to mount and unmount the filesystem (the opposite of `user`)
    - `remount`: mounts the filesystem again in case it is already mounted
    - `ro`: mounts the filesystem as read only
    - `rw`: mounts the file system with read and write capabilities
    - `relatime`: makes access time to files be updated only if atime is earlier than mtime
    - `user_xattr`: allow users to set and remote extended filesystem attributes

- **dump**: the fifth field, (fs_freq), is used for these filesystems by the dump(8) command to determine which filesystems need to be dumped. If the fifth field is not present, a value of zero is returned and dump will assume that the filesystem does not need to be dumped.

- **pass**: the sixth field, (fs_passno), is used by the fsck(8) program to determine the order in which filesystem checks are done at reboot time. The root filesystem should be specified with a fs_passno of 1, and other filesystems should have a fs_passno of 2. Filesystems within a drive will be checked sequentially, but filesystems on different drives will be checked at the same time to utilize parallelism available in the hardware. If the sixth field is not present or zero, a value of zero is returned and fsck will assume that the filesystem does not need to be checked.

So, to mount a filesystem/partition at boot, a common configuration is:
`UUID=<uuid> <mount-point> <fs-type> defaults 0 0`


Before you reboot the machine, you need to test your new fstab entry. Issue the following command to mount all filesystems mentioned in fstab:
`sudo mount -a`

Check if your filesystem was properly mounted:
`mount | grep <mount-point>`

If you see no errors, the fstab entry is correct and you're safe to reboot. 

---

### Mounting ISO Files

You can mount an ISO file using the loop device which is a special pseudo-device that makes a file accessible as a block device.

Start by creating the mount point, it can be any location you want: `sudo mkdir /media/iso`

Mount the ISO file to the mount point by typing the following command:
`sudo mount /path/to/image.iso /media/iso -o loop`

A common use case is when you want to use a loopback file in place of a fresh new partition for testing purposes:
```
sudo dd if=/dev/zero of=/imagefile bs=1M count=250
sudo mkfs -t ext4 -b 4096 -v /imagefile
sudo mkdir /mnt/tempdir
sudo mount -o loop /imagefile /mnt/tempdir 
mount | grep tempdir
>/dev/loopX on /mnt/tempdir type ext4 (rw,relatime,seclabel,data=ordered)
```