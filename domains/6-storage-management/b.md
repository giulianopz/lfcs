## Manage and configure LVM storage

*Logical Volumes Management* (also known as **LVM**), which have become a default for the installation of most (if not all) Linux distributions, have numerous advantages over traditional partitioning management. Perhaps the most distinguishing feature of LVM is that it allows logical divisions to be resized (reduced or increased) at will without much hassle.

The structure of the LVM consists of:

- one or more entire hard disks or partitions which are configured as physical volumes (**PVs**)
- a volume group (**VG**) is created using one or more physical volumes
- multiple logical volumes (**LVs**) which can then be created from a volume group. 

Each logical volume is somewhat equivalent to a traditional partition – with the advantage that it can be resized at will as said earlier.

> Note: When combined with RAID, you can enjoy not only scalability (provided by LVM) but also redundancy (offered by RAID). In this type of setup, you will typically find LVM on top of RAID, that is, configure RAID first and then configure LVM on top of it.

---

### Creating Physical Volumes, Volume Groups, and Logical Volumes

To create physical volumes on top of devices or single partitions: `sudo pvcreate /dev/sdb /dev/sdc /dev/sdd`

List the newly created PVs with: `sudo pvs`

Get detailed information about each PV with: `sudo pvdisplay /dev/sd[x]`

If you omit `/dev/sd[x]` as arg, you will get information about all the PVs.

To create a volume group named "vg00" using /dev/sdb and /dev/sdc (we will save /dev/sdd for later to illustrate the possibility of adding other devices to expand storage capacity when needed): `sudo vgcreate vg00 /dev/sdb /dev/sdc`

As it was the case with physical volumes, you can also view information about this volume group by issuing: `sudo vgdisplay vg00`

It is considered good practice to name each logical volume according to its intended use. For example, let’s create two LVs named "vol_projects" (10 GB) and "vol_backups" (remaining space), which we can use later to store project documentation and system backups, respectively.

The `-n` option is used to indicate a name for the LV, whereas `-L` sets a fixed size and `-l` (lowercase L) is used to indicate a percentage of the remaining space in the container VG:
```
sudo lvcreate -n vol_projects -L 10G vg00
sudo lvcreate -n vol_backups -l 100%FREE vg00
```

> Warning: If you see a message like "ext4 signature detected on at offset 1080. wipe it ?" when manipulating partitions, the mentioned signature is basically a sign that there's something there, and it is not empty, so it means: "There is already data here!...are you sure you want to go ahead?".

> Note: LVs will be symlinked in /dev/mapper and /dev/[VG-name].

As before, you can view the list of LVs and basic information with: `sudo lvs`

And detailed information with: `sudo lvdisplay`

To view information about a single LV, use lvdisplay with the VG and LV as parameters, as follows: `sudo lvdisplay vg00/vol_projects`

Before each logical volume can be used, we need to create a filesystem on top of it.

We’ll use ext4 as an example here since it allows us both to increase and reduce the size of each LV (as opposed to xfs that only allows to increase the size):
```
sudo mkfs.ext4 /dev/vg00/vol_projects
sudo mkfs.ext4 /dev/vg00/vol_backups
```

### Resizing Logical Volumes and Extending Volume Groups

Due to the nature of LVM, it's very easy to reduce the size of the two LVs and allocate it for the other, while resizing (`-r`) each filesystem at the same time:
```
sudo lvreduce -L -2.5G -r /dev/vg00/vol_projects
sudo lvextend -l +100%FREE -r /dev/vg00/vol_backups
```

> Note: If you don't use the (-r) switch, the filesytem must be resized apart, e.g for ext4 filesystems: `sudo resize2fs </dev/mapper/myvg-mylv>` 

It is important to include the minus (`-`) or plus (`+`) signs while resizing a logical volume. Otherwise, you’re setting a fixed size for the LV instead of resizing it.

It can happen that you arrive at a point when resizing logical volumes cannot solve your storage needs anymore and you need to buy an extra storage device. Keeping it simple, you will need another disk. We are going to simulate this situation by adding the remaining PV from our initial setup (/dev/sdd).

To add /dev/sdd to vg00: `sudo vgextend vg00 /dev/sdd`

If you run `vgdisplay vg00` before and after the previous command, you will see the increase in the size of the VG.

### Mounting Logical Volumes on Boot and on Demand

Of course there would be no point in creating logical volumes if we are not going to actually use them! To better identify a logical volume we will need to find out what its UUID:
```
blkid /dev/vg00/vol_projects
blkid /dev/vg00/vol_backups
```

Create mount points for each LV:
```
sudo mkdir /home/projects
sudo mkdir /home/backups
```

Insert the corresponding entries in /etc/fstab:
```
UUID=b85df913-580f-461c-844f-546d8cde4646 /home/projects	ext4 defaults 0 0
UUID=e1929239-5087-44b1-9396-53e09db6eb9e /home/backups ext4	defaults 0 0
```

Then save the changes and mount the LVs:
```
sudo mount -a
mount | grep home
```