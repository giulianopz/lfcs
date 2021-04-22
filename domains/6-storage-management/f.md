## Create and manage RAID devices

The technology known as *Redundant Array of Independent Disks* (**RAID**) is a storage solution that combines multiple hard disks into a single logical unit to provide redundancy of data and/or improve performance in read/write operations to disk.

Essential features of RAID are:

- mirroring, write the same data to more than one disk
- striping, splitting of data to more than one disk
- parity, extra data is stored to allow fault-tolerance, error detection and repair.

However, the actual fault-tolerance and disk I/O performance lean on how the hard disks are set up to form the disk array. Depending on the available devices and the faulttolerance/performance needs, different RAID levels are defined.

### RAID LEVELS

- RAID 0: uses only striping, it does not allow fault tolerance but it has good performance

> The total array size is n times the size of the smallest partition, where n is the number of independent disks in the array (you will need at least two drives). Run the following command to assemble a RAID 0 array using partitions /dev/sdb1 and /dev/sdc1:
```
mdadm --create --verbose /dev/md0 --level=stripe --raid-devices=2 /dev/sdb1 /dev/sdc1
```

> Common uses: supporting real-time applications where performance is more important than fault-tolerance.

- RAID 1: uses only mirroring, good for recovery, at least 2 disks are required

> The total array size equals the size of the smallest partition (you will need at least two drives). Run the following command to assemble a RAID 1 array using partitions /dev/sdb1 and /dev/sdc1:
```
mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
```

> Common uses: Installation of the operating system or important subdirectories, such as /home.
    
- RAID 5: uses a rotating parity stripe, thus allowing fault tolerance and reliability, at least 3 disks are required

> The total array size will be (n – 1) times the size of the smallest partition. The “lost” space in (n-1) is used for parity (redundancy) calculation (you will need at least three drives). Note that you can specify a spare device (/dev/sde1 in this case) to replace a faulty part when an issue occurs. Run the following command to assemble a RAID 5 array using partitions /dev/sdb1, /dev/sdc1, /dev/sdd1, and /dev/sde1 as spare:
```
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdb1 /dev/sdc1 /dev/sdd1 --spare-devices=1 /dev/sde1
```

> Common uses: Web and file servers.
    
- RAID 6: uses striped disks with dual parity, it is an evolution of RAID 5, allowing fault tolerance and performance, at least 4 disks are required

> The total array size will be (n*s)-2*s, where n is the number of independent disks in the array and s is the size of the smallest disk. Note that you can specify a spare device (/dev/sdf1 in this case) to replace a faulty part when an issue occurs. Run the following command to assemble a RAID 6 array using partitions /dev/sdb1, /dev/sdc1, /dev/sdd1, /dev/sde1, and /dev/sdf1 as spare:
```
mdadm --create --verbose /dev/md0 --level=6 --raid-devices=4 /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde --spare-devices=1 /dev/sdf1
```

> Common uses: File and backup servers with large capacity and high availability requirements.
     
- RAID 10: uses mirroring and striping, thus allowing redundancy and performance, at least 4 disk are required

> The total array size is computed based on the formulas for RAID 0 and RAID 1, since RAID 1+0 is a combination of both. First, calculate the size of each mirror and then the size of the stripe. Note that you can specify a spare device (/dev/sdf1 in this case) to replace a faulty part when an issue occurs. Run the following command to assemble a RAID 1+0 array using partitions /dev/sdb1, /dev/sdc1, /dev/sdd1, /dev/sde1, and /dev/sdf1 as spare:
```
mdadm --create --verbose /dev/md0 --level=10 --raid-devices=4 /dev/sd[b-e]1 --spare-devices=1 /dev/sdf1
```

> Common uses: Database and application servers that require fast I/O operations.

### Assembling Partitions as RAID Devices

1. Create the array using mdadm

RAID disks require *RAID autodetect partitions*. These can be made with fdisk:
```
sudo fdisk /dev/sdb
>d      # until all deleted
>n      # use defaults
>t      # change partition type
>fd     # Linux RAID autodetect type
```

If one of the partitions has been formatted previously, or has been a part of another RAID array previously, you will be prompted to confirm the creation of the new array. Assuming you have taken the necessary precautions to avoid losing important data that may have resided in them, you can safely type `y` and press `Enter`: `mdadm --create --verbose /dev/md0 --level=stripe --raid-devices=2 /dev/sdb1 /dev/sdc1`

2. Check the array creation status

In order to check the array creation status, use the following commands – regardless of the RAID type:
```
cat /proc/mdstat
>Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
>md0 : active raid0 sdb[1] sda[0]
>      209584128 blocks super 1.2 512k chunks
>
>            unused devices: <none>
# or
mdadm --detail /dev/md0   # more detailed summary
```

3. Format the RAID Device

Format the device with a filesystem as per your needs/requirement:
```
sudo mkfs.ext4 /dev/md0
sudo mkdir -p /mnt/myraid
sudo mount /dev/md0 /myraid
```

Check whether the new space is available by typing:
```
df -h -x devtmpfs -x tmpfs
>Output
>Filesystem      Size  Used Avail Use% Mounted on
>/dev/vda1        25G  1.4G   23G   6% /
>/dev/vda15      105M  3.4M  102M   4% /boot/efi
>/dev/md0        196G   61M  186G   1% /mnt/md0
```

4. Save and Monitor the RAID Array

To make sure that the array is reassembled automatically at boot: `sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf`

Afterwards, you can update the initramfs, or initial RAM file system, so that the array will be available during the early boot process: `sudo update-initramfs -u`

Once the configuration file has been updated the array can be assembled: `mdadm --assemble --scan`

> Note: This will assemble and start all arrays listed in the standard config file. This command will typically go in a system startup file.

`mdadm` provides the systemd service `mdmonitor.service` which can be useful for monitoring the health of your raid arrays and notifying you via email if anything goes wrong.

This service is special in that it cannot be manually activated like a regular service; mdadm will take care of activating it via udev upon assembling your arrays on system startup, but it will only do so if an email address has been configured for its notifications:
`echo "MAILADDR user@domain" | sudo tee -a /etc/mdadm/mdadm.conf`

> Warning: Failure to configure an email address will result in the monitoring service silently failing to start.

> Note: In order to send emails, a properly configured mail transfer agent is required.

Then, to verify that everything is working as it should, run the following command: `mdadm --monitor --scan --oneshot --test`

If the test is successful and the email is delivered, then you are done; the next time your arrays are reassembled, mdmonitor.service will begin monitoring them for errors. 

Finally, add the new filesystem mount options to the /etc/fstab file for automatic mounting at boot:
`echo '/dev/md0 /mnt/myraid ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab`

### Recover from RAID Disk Failure

In RAID levels that support redundancy, replace failed drives when needed. When a device in the disk array becomes faulty, a rebuild automatically starts only if there was a spare device added when we first created the array.

Otherwise, we need to manually attach an extra physical drive to our system and run:  `mdadm /dev/md0 --add /dev/sdX1`

> Note: `</dev/md0>` is the array that experienced the issue and `</dev/sdX1>` is the new device.

Depending on the type of RAID (for example, with RAID1), mdadm may add the device as a spare without syncing data to it. You can increase the number of disks the RAID uses by using `--grow` with the `--raid-devices` option. For example, to increase an array to four disks: `mdadm --grow /dev/md0 --raid-devices=4`

You can check the progress with: `cat /proc/mdstat`

Check that the device has been added with the command: `mdadm --misc --detail /dev/md0`

> Note: For RAID0 arrays you may get the following error message: "mdadm: add new device failed for /dev/sdc1 as 2: Invalid argument". This is because the above commands will add the new disk as a "spare" but RAID0 does not have spares. If you want to add a device to a RAID0 array, you need to "grow" and "add" in the same command, as demonstrated here: `mdadm --grow /dev/md0 --raid-devices=3 --add /dev/sdX1`

---

One can remove a device from the array after marking it as faulty:
`mdadm --fail /dev/md0 /dev/sdX0`

Now remove it from the array:
`mdadm --remove /dev/md0 /dev/sdX0`

To remove device permanently (for example, to use it individually from now on), see next session.

### Disassemble a working array

You may have to do this if you need to create a new array using the devices.

Find the active arrays in the /proc/mdstat file by typing: 
```
cat /proc/mdstat
>Output
>Personalities : [raid0] [linear] [multipath] [raid1] [raid6] [raid5] [raid4] [raid10] 
>md0 : active raid0 sdc[1] sdd[0]
>      209584128 blocks super 1.2 512k chunks
>
>            unused devices: <none>
```

Unmount the array from the filesystem: `sudo umount /dev/md0`

Then, stop and remove the array by typing: `sudo mdadm --stop /dev/md0`

Find the devices that were used to build the array with the following command:

> Warning: Keep in mind that the /dev/sd* names can change any time you reboot! Check them every time to make sure you are operating on the correct devices.

```
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
>Output
>NAME     SIZE FSTYPE            TYPE MOUNTPOINT
>sda      100G                   disk 
>sdb      100G                   disk 
>sdc      100G linux_raid_member disk   # here it is
>sdd      100G linux_raid_member disk   # and this is the second one
>vda       25G                   disk 
>├─vda1  24.9G ext4              part /
>├─vda14    4M                   part 
>└─vda15  106M vfat              part /boot/efi
```

After discovering the devices used to create an array, zero their superblock to remove the RAID metadata and reset them to normal:
```
sudo mdadm --zero-superblock /dev/sdc
sudo mdadm --zero-superblock /dev/sdd
```

> Warning: Do not issue this command on linear or RAID0 arrays or data loss will occur!

> Warning: For the other RAID levels, reusing the removed disk without zeroing the superblock will cause loss of all data on the next boot. (After mdadm will try to use it as the part of the raid array).
 
You should remove any of the persistent references to the array. Edit the /etc/fstab file and comment out or remove the reference to your array:
`sudo sed -i '/\/dev\/md0/d' /etc/fstab`

Also, comment out or remove from the /etc/mdadm/mdadm.conf file the array definition:
```
ARRAY /dev/md0 metadata=1.2 name=mdadmwrite:0 UUID=7261fb9c:976d0d97:30bc63ce:85e76e91
```

Finally, update the initramfs again so that the early boot process does not try to bring an unavailable array online:
```
sudo update-initramfs -u
```
 
At this point, you should be ready to reuse the storage devices individually, or as components of a different array.