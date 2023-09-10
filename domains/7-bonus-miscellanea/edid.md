## How to fix low screen resolution

Sometimes when you connect a device to a monitor (external or integrated), you may experience an unexpected low resolution that you cannot change via system setting GUI of your desktop environment: only lower resolutions could be available. 

This can happen especially if you are using a VGA-to-HDMI converter to connect an old pc to a newer monitor. If the comunication is unidirectional, from input (e.g., a mini pc supporting only VGA) to output (e.g. an external monitor supporting only HDMI), the monitor won't be able to send [EDID](https://en.wikipedia.org/wiki/Extended_Display_Identification_Data) data packets which containts info regarding its capabilities.

In such cases, you can have to grab the EDID data from another pc connected to this monitor or online, if you are lucky enough to find it.

Firstly, you should verify that the graphic card(s) of your pc can match the recommended resolution of your monitor: typically, 1920x1080 at 60 refresh rate (a standard also know as 1080p, Full HD or FHD,). For Intel cards, see [here](https://www.intel.com/content/www/us/en/support/articles/000023781/graphics.html).

Once this is verified, you may try to just add the the intended resolution (let's tick to the default scenario, i.e. 1920x1080) with [xrandr](https://www.x.org/releases/X11R7.5/doc/man/man1/xrandr.1.html):
```
# show available resolutions for common display types (VGA, HDMI, etc.)
xrandr
# generate correct params for the target resolution
cvt 1920 1080 60
# pass the above params to the next command
xrandr --newmode "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
# make available the new resolution for the intended display type
xrandr --addmode VGA-1 "1920x1080_60.00"
xrandr --output VGA-1 --mode "1920x1080_60.00"
# go to the system settings GUI and select the resolution you have just configured if it's not still active after last command is executed
```

If this solved your problem, you have just to put these commands in an executable file sourced when the X session starts. Put this file in one of the following directories:
- `~/.profile`
- `/etc/profile.d`

If this did not solve the problem for you, some extra work is needed: you will have to manually retrieve the EDID file and set it in a Xorg config file or append it to the kernel parameters in the boot loader's boot selection menu.

To parse EDID info, install the [read-edid](https://manpages.ubuntu.com/manpages/jammy/man1/get-edid.1.html) package: `apt install read-edid`

To retrieve the EDID file, you have two options:
- find it in the [EDID repository](https://github.com/linuxhw/EDID) of the The Linux Hardware Project by searching for the model name of your monitor
- grab it from another pc connected to the monitor by running the following command (substitute `card1-HDMI-A-1` with the [DRM](https://en.wikipedia.org/wiki/Direct_Rendering_Manager) device found on this second pc):
    ```
    :~$ edid-decode </sys/class/drm/card1-HDMI-A-1/edid
    edid-decode (hex):

    00 ff ff ff ff ff ff 00 09 d1 51 79 45 54 00 00
    1f 1d 01 03 80 35 1e 78 2a 05 61 a7 56 52 9c 27
    0f 50 54 a5 6b 80 d1 c0 81 c0 81 00 81 80 a9 c0
    b3 00 d1 cf 01 01 02 3a 80 18 71 38 2d 40 58 2c
    45 00 0f 28 21 00 00 1e 00 00 00 ff 00 31 38 4b
    30 30 30 33 33 30 31 51 0a 20 00 00 00 fd 00 30
    4b 1e 53 15 00 0a 20 20 20 20 20 20 00 00 00 fc
    00 42 65 6e 51 20 45 57 32 34 38 30 0a 20 01 ba

    02 03 44 f1 4f 90 1f 05 14 04 13 03 12 07 16 15
    01 06 11 02 23 09 07 07 83 01 00 00 e2 00 d5 68
    03 0c 00 30 00 38 44 00 67 d8 5d c4 01 78 80 00
    68 1a 00 00 01 01 30 4b e6 e3 05 c3 01 e6 06 05
    01 61 5a 26 02 3a 80 18 71 38 2d 40 58 2c 45 00
    0f 28 21 00 00 1e 01 1d 00 72 51 d0 1e 20 6e 28
    55 00 0f 28 21 00 00 1e 8c 0a d0 8a 20 e0 2d 10
    10 3e 96 00 0f 28 21 00 00 18 00 00 00 00 00 e8

    ----------------

    Block 0, Base EDID:
    EDID Structure Version & Revision: 1.3
    Vendor & Product Identification:
        Manufacturer: BNQ
        Model: 31057
        Serial Number: 21573
        Made in: week 31 of 2019
    [...]
    ```

Once you have it, use the first hexadecimal block at the beginning of the output of the command to generate the binary file:
```
$ HEXSTR="\
00 ff ff ff ff ff ff 00 09 d1 51 79 45 54 00 00\
1f 1d 01 03 80 35 1e 78 2a 05 61 a7 56 52 9c 27\
0f 50 54 a5 6b 80 d1 c0 81 c0 81 00 81 80 a9 c0\
b3 00 d1 cf 01 01 02 3a 80 18 71 38 2d 40 58 2c\
45 00 0f 28 21 00 00 1e 00 00 00 ff 00 31 38 4b\
30 30 30 33 33 30 31 51 0a 20 00 00 00 fd 00 30\
4b 1e 53 15 00 0a 20 20 20 20 20 20 00 00 00 fc\
00 42 65 6e 51 20 45 57 32 34 38 30 0a 20 01 ba";

$ echo -en $(echo "$HEXSTR" | sed -E 's/([0-9abcdef][0-9abcdef])[[:space:]]?/\\x\1/g') > edid.bin
# check that the file is readable
$ edid-decode edid.bin
```

In order to apply it only to a specific connector with a specific resolution, [force](https://wiki.archlinux.org/title/kernel_mode_setting#Forcing_modes_and_EDID) this kernel mode setting (KMS) by naming the file (`edid.bin` in the example) according to the following pattern (as in the code snippet above): `CONNECTOR:edid/RESOLUTION.bin` (e.g. `VGA-1:edid/1920x1080.bin`).

After having prepared your EDID, place it in a directory, e.g. called `edid` under `/usr/lib/firmware` and copy your binary into it.

You now have two options to make this file available to the display manager (e.g. [SDDM](https://en.wikipedia.org/wiki/Simple_Desktop_Display_Manager)):
- adding a config file to the `xorg.conf.d` directory with the relevant info, as described [here](https://gist.github.com/hinell/0ebaad01b771a70844204f295aaf03b7#via-xorgconf)
- modifying the Linux Kernel parameters to include a directive for reading the EDID file at boot time. 

The first option is lengthy and required you to understand how to properly configure [Xorg](https://wiki.archlinux.org/title/xorg#Configuration).

The second is quicker but error-prone, so be extra-careful if going through the following steps:
- reboot the system, wait for the system to restart and then press and hold `Esc` key until the GRUB menu appears
- if it doesn't appear at all after multiple retries, chanches are that you must set a longer [timeout](https://linuxhint.com/change-grub-timeout-linux/) for the GRUB
- press `e` when the menu appears and add the `drm.edid_firmware` argument to the end of the line starting with `linux`:
```
linux /boot/vmlinuz-linux root=UUID=0a3407de-014b-458b-b5c1-848e92a327a3 rw [...] drm.edid_firmware=VGA-1:edid/1920x1080.bin
```
Boot the system to verify if the change had the desired effect.

If so, make the change permanent by editing the `/etc/default/grub` to set `GRUB_CMDLINE_LINUX_DEFAULT` option to the new parameter (e.g. `GRUB_CMDLINE_LINUX_DEFAULT="drm.edid_firmware=VGA-1:edid/your_edid.bin"`) and then regenerating the GRUB config with: `grub-mkconfig -o /boot/grub/grub.cfg`.

Reboot to verify that the change works across system restarts.

---
References:
- [Unable to set my screen resolution higher](https://askubuntu.com/questions/1075157/unable-to-set-my-screen-resolution-higher)
- [Fix Broken EDID Guide](https://gist.github.com/hinell/0ebaad01b771a70844204f295aaf03b7#via-xorgconf)
- [RepairEDID](https://wiki.debian.org/RepairEDID)
- [Kernel parameters](https://wiki.archlinux.org/title/Kernel_parameters)
- [Kernel mode setting](https://wiki.archlinux.org/title/kernel_mode_setting#Forcing_modes_and_EDID)
