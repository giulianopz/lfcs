## Create and configure encrypted storage

The following illustrates how to encrypt a secondary disk ([source](https://dev-notes.eu/2020/12/LUKS-Encrypt-Hard-Drive-with-Cryptsetup-on-Ubuntu-20.04/)). For full-disk encryption, look [here](https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019).

**cryptsetup** is a utility used to conveniently set up disk encryption based on the DMCrypt kernel module. These include plain dm-crypt volumes, LUKS volumes, loop-AES, TrueCrypt (including VeraCrypt extension) and BitLocker formats.

**LUKS** (Linux Unified Key Setup) is a standard for hard disk encryption. It standardizes a partition header, as well as the format of the bulk data. LUKS can manage multiple passwords, that can be revoked effectively and that are protected against dictionary attacks with PBKDF2. 

---
 
Once you have physically connected the disk, find the unmounted disk in the system using `lsblk` (you can spot it by the size which should match the expexted one).

> Note: Once created, the LUKS partition will have the FSTYPE set as "crypto_LUKS".

Double check disk info: `sudo hdparm -i /dev/sdd`

If this checks out, you have the device reference. Alternatively, list all drives in short format: `sudo lshw -short -C disk`

If the disk does not have an existing partition, create one: `sudo fdisk /dev/sdd`

Follow the instructions, hit all defaults to create one large partition: it will be something like "/dev/sdd1".

> Note: If the disk is already partitioned, you can use an existing partition, but all data will be over-written.

Next step is to LUKS encrypt the target partition - in this case, /dev/sdd1: `cryptsetup -y -v luksFormat /dev/sdd1`

> Note: `-y` forces double entry from the user when interactively setting the passphrase - ask for it twice and complain if both inputs do not match.

> Warning: Your kernel may not support the default encryption method used by cryptsetup. In that case, you can examine /proc/crypto to see the methods your system supports, and then you can supply a method, as in: `sudo cryptsetup luksFormat --cipher aes /dev/sdd1`

The encrypted partition is accessed by means of a mapping. To create a mapping for the current session:
```
# open the LUKS partition and create a mapping called "backupSSD"
sudo cryptsetup luksOpen /dev/sdd1 backupSSD
# checks for its presence
ls -l /dev/mapper/backupSSD
lrwxrwxrwx 1 root root 7 Dec 17 15:48 /dev/mapper/backupSSD -> ../dm-6
```

Check mapping status:
```
sudo cryptsetup -v status backupSSD
>[sudo] password for <user>:
>/dev/mapper/backupSSD is active and is in use.
>  type:    LUKS1
>  cipher:  aes-xts-plain64
>  keysize: 256 bits
>  device:  /dev/sdd1
>  offset:  4096 sectors
>  size:    1953519024 sectors
>  mode:    read/write
>Command successful.
```

This mapping is not persistent. If you want to open the disk/partition automatically on boot, you will need to amend /etc/crypttab to set up a mapped device name (see below).

Do not omit this step - or the partition won’t mount (`-L` denotes the partition label): `sudo mkfs.ext4 /dev/mapper/backupSSD -L "Extra SSD 1TB"`

Create a mount point and give the mount point appropriate ownership:
```
sudo mkdir /media/secure-ssd
sudo chown $USER:$USER /media/secure-ssd
```

To mount, you need to reference the mapper, not the partition:
`sudo mount /dev/mapper/backupSSD /media/secure-ssd`

To automount at boot:

1. Edit /etc/fstab to reference the mapper to the decrypted volume:
```
/dev/mapper/backupSSD /media/secure-ssd ext4 defaults 0 2
```

2. Declare a keyfile to decrypt the disk without typing the passphrase.

When you first run luksFormat, the initial password you supply is hashed and stored in key-slot 0 of the LUKS header. You can easily add an additional passphrase, and this can take the form of a keyfile. This means that the volume can be decrypted either with the initial passphrase or the keyfile.

> Warning: To add a password to a LUKS partition, you need an unencrypted copy of the master key - so if the partition is not initialized, you will be prompted for the original passphrase. Because more than one password is possible under LUKS setups, the wording of the password prompt may seem confusing - it says: “Enter any passphrase”. This means enter any valid existing password for the partition.

> Note: If you want multiple encrypted disks, you can use a passphrase only for the first one while decrypting the others with their keyfiles.

Create a keyfile:
```
# make an appropriate directory
sudo mkdir /root/.keyfiles
# make a keyfile of randomly sourced bytes
sudo dd if=/dev/urandom of=/root/.keyfiles/hdd-1.key bs=1024 count=4
# make this read-only by owner (in this case, root):
sudo chmod 0400 /root/.keyfiles/hdd-1.key
```

Set up a keyfile for the LUKS partition:
`sudo cryptsetup luksAddKey /dev/sdd1 /root/.keyfiles/hdd-1.key`

To automatically mount at boot, the mapping in /etc/crypttab should reference the keyfile:
```
backupSSD UUID=4f942e15-ff00-4213-aab1-089448b17850 /root/.keyfiles/hdd-1.key luks,discard
```

---

To unmount the LUKS partition:
```
umount /dev/mapper/backupSSD
cryptsetup luksClose backupSSD
```

To decrypt and remount:
```
cryptsetup luksOpen /dev/sdd1 backupSSD
mount /dev/mapper/backupSSD /media/secure-ssd
```

---

To check the passphrase:
```
sudo cryptsetup luksOpen --test-passphrase /dev/sdX && echo correct
# Prompts for password, echoes "correct" if successful
# Alternatively, specify the intended slot
cryptsetup luksOpen --test-passphrase --key-slot 0 /dev/sdX && echo correct
```