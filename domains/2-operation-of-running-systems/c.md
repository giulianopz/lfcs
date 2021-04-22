## Install, configure and troubleshoot bootloaders

The Linux boot process from the time you press the power button of your computer until you get a fully-functional system follows this high-level sequence:

1. A process known as **POST** (*Power-On Self Test*) performs an overall check on the hardware components of your computer
2. When POST completes, it passes the control over to the **boot loader**, which in turn loads the Linux kernel in memory (along with **initramfs**) and executes it. The most used boot loader in Linux is the *GRand Unified Boot loader*, or **GRUB** for short
3. The kernel checks and accesses the hardware, and then runs the initial process (mostly known by its generic name **init**) which in turn completes the system boot by starting services.

Two major GRUB versions (*v1*, sometimes called *GRUB Legacy*, and *v2*) can be found in modern systems, although most distributions use v2 by default in their latest versions. Only Red Hat Enterprise Linux 6 and its derivatives still use v1 today.

Regardless of the GRUB version, a boot loader allows the user to:

1. modify the way the system behaves by specifying different kernels to use,
2. choose between alternate operating systems to boot, and
3. add or edit configuration stanzas to change boot options, among other things.

When the system boots you are presented with the GRUB menu if you repeatedly press ESC. Initially, you are prompted to choose between alternate kernels (by default, the system will boot using the latest kernel) and are allowed to enter a GRUB command line (with `c`) or edit the boot options (by pressing the `e` key).

The GRUB v2 configuration is read on boot from `/boot/grub/grub.cfg` or `/boot/grub2/grub.cfg`, `whereas /boot/grub/grub.conf` or `/boot/grub/menu.lst` are used in v1. These files are NOT to be edited by hand, but are modified based on the contents of `/etc/default/grub` and the files found inside `/etc/grub.d`.

If you’re interested specifically in the options available for /etc/default/grub, you can invoke the configuration section directly:
`info -f grub -n 'Simple configuration'`

When multiple operating systems or kernels are installed in the same machine, `GRUB_DEFAULT` requires an integer value that indicates which OS or kernel entry in the GRUB initial screen should be selected to boot by default. The list of entries can be viewed using the following command:
`awk -F\' '$1=="menuentry " {print $2}' /boot/grub/grub.cfg`

One final GRUB configuration variable that is of special interest is `GRUB_CMDLINE_LINUX`, which is used to pass options to the kernel. The options that can be passed through GRUB to the kernel are well documented in `man 7 kernel-command-line` and in `man 7 bootparam`.

To bring the system to single-user mode to perform maintenance tasks, you can append the word `single` to GRUB_CMDLINE_LINUX and rebooting.
After editing /etc/defalt/grub, you will need to run `update-grub` (Ubuntu) afterwards, to update `grub.cfg` (otherwise, changes will be lost upon boot).

### Fixing the GRUB

If you install a second operating system or if your GRUB configuration file gets corrupted due to a human error, there are ways you can get your system back on its feet and be able to boot again.

In the initial screen, press `c` to get a GRUB command line (remember that you can also press `e` to edit the default boot options), and use `help` to bring the available commands in the GRUB prompt.

Use `ls` to list the installed devices and filesystems. Find the drive containg the grub to boot Linux and there use other high level tools to repair the configuration file or reinstall GRUB altogether if it is needed:
```
ls (hd0,msdos1)/
```

Once sure that GRUB resides in a certain partition (e.g. hd0,msdos1), tell GRUB where to find its configuration file and then instruct it to attempt to launch its menu:
```
set prefix=(hd0,msdos1)/grub2
set root=(hd0,msdos1)
insmod normal
normal
```

Then in the GRUB menu, choose an entry and press Enter to boot using it. Once the system has booted you can issue the `grub2-install /dev/sdX` command (change `sdX` with the device you want to install GRUB on). This will rewrite the MBR information to point to the current installation and rewrite some GRUB 2 files (which are already working). Since it isn't done during execution of the previous command, running `sudo update-grub` after the install will ensure GRUB 2's menu is up-to-date. 

Other more complex scenarios are documented, along with their suggested fixes, in the [Ubuntu GRUB2 Troubleshooting guide](https://help.ubuntu.com/community/Grub2/Troubleshooting). 