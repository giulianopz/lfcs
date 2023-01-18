## Repair the GRUB from live CD or USB stick 

1. Insert the bootable device and boot into *Try Ubuntu* mode

2. Find out you root partition by typing: `sudo fdisk -l` or `sudo blkid`

3. Mount you main partition: `sudo mount [/dev/sda2] /mnt`

> Note: If you have separate partitions for /boo, /var and /usr, repeat steps 2 and 3 to mount them to /mnt/boot, /mnt/var and /mnt/usr respectively 

4. Bind-mount pseudo-filesystems: `for i in /sys /proc /run /dev; do sudo mount --bind "$i" "/mnt/"$i"; done`

> Note: A **bind mount** is an alternate view of a directory tree. Classically, mounting creates a view of a storage device as a directory tree. A bind mount instead takes an existing directory tree and replicates it under a different point. The directories and files in the bind mount are the same as the original.

5. If Ubuntu was installed in EFI mode, use `sudo fdisk -l | grep -i efi` to find your EFI partition and then mount it: `sudo mount [/dev/sda1] /mnt/boot/efi`

6. `sudo chroot /mnt`

7. `update-grub`

If this doesnt't fix the GRUB, go on:

8. `grub-install /dev/sda; update-grub`

9. I fthe EFI partition ha changed, you may need to update it in /etc/fstab accordingly

10. `sudo reboot`

11. At this point, you should be able to boot normally (remember to unplug the bootable media).