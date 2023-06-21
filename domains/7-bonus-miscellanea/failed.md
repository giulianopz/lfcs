## Recover from a failed installation

For some reasons the installation process may fail unexpectedly leaving the system in an inconsistent state.

At reboot you will be presented with the [GRUB shell](https://wiki.archlinux.org/title/GRUB#Using_the_command_shell).

To rebooting from the USB stick and retry the installation you will have to manually locate the GRUB EFI binary (grubx64.efi) and boot from this file.

In order to do so, type `ls` to list all the devices in the system:
```
grub> ls
(hd0) (hd0,msdos1) (hd1) (hd1,gpt2) (hd1,gpt1) (cd0,msdos1)
```

> Note: The keyboard layout may be different from the usual one (default is US English). You will need to guess where is the character you need.

Inspect every device to find the EFI path (i.e. /efi/boot/grubx64.efi):
```
grub> ls (cd0,msdos1)/
efi
grub> ls (cd0,msdos1)/EFI
boot
grub> ls (cd0,msdos1)/EFI/boot
grubx64.efi
```

Once done, [chain-load](https://www.gnu.org/software/grub/manual/grub/html_node/Chain_002dloading.html) the bootloader at this path:
```
grub> chainloader /efi/boot/grubx64.efi
```

Then, simply boot into it:
```
grub> boot
```

The installer will opens up once again and you will be able to restart the installation from scratch.
