## Boot, reboot, and shut down a system safely

The `poweroff`, `shutdown (-h) now`, and `halt -p` commands all do the same thing as halt alone, while additionally sending an ACPI command to signal the power supply unit to disconnect the main power.

Generally, one uses the `shutdown command` for system administration of multiuser shell servers, becaus it allows to specify a time delay and a warning message before shutdown or reboot happens: `sudo shutdown -r +30 "Planned software upgrades"`

To reboot the system immediately: `sudo reboot`

> Note: The `reboot` command, on its own, is basically a shortcut to `shutdown -r now`. 

On most modern Linux distributions, **systemd** is the init system, so both rebooting and powering down can be performed through the systemd user interface, **systemctl**. The systemctl command accepts, among many other options, **halt** (halts disk activity but does not cut power) **reboot** (halts disk activity and sends a reset signal to the motherboard) and **poweroff** (halts disk acitivity, and then cut power). These commands are mostly equivalent to starting the target file of the same name. For instance, to trigger a reboot: `sudo systemctl start reboot.target`. Or, simply: `sudo systemctl reboot`

The `telinit` command is the front-end to your init system. 

> Note: Since the concept of SysV runlevels is obsolete the runlevel requests will be transparently translated into systemd unit activation requests.

To power off your computer by sending it into runlevel 0: `sudo telinit 0`

To reboot using the same method: `sudo telinit 6`

### Apply brute force

There’s a provision in the Linux kernel for system requests (**Sysrq** on most keyboards). You can communicate directly with this subsystem using key combinations, ideally regardless of what state your computer is in; it gets complex on some keyboards because the **Sysrq** key can be a special function key that requires a different key to access (such as Fn on many laptops).

An option less likely to fail is using echo to insert information into /proc, manually. First, make sure that the Sysrq system is enabled:
`sudo echo 1 > /proc/sys/kernel/sysrq`

To reboot, you can use either `Alt+Sysrq+B` or type:
`sudo echo b > /proc/sysrq-trigger`

This method is not a graceful way to reboot your machine on a regular basis, but it gets the job done in a pinch.

The magic SysRq key is often used to recover from a frozen state, or to reboot a computer without corrupting the filesystem, especially when switching to a terminal window (Ctrl+Alt+F2) is not possible. In this case, use the following steps to perform a reboot:

- Press Alt+SysRq+**R** to get the keyboard
- If pressing Ctrl+Alt+F2 before failed, try it again now.
- Press Alt+SysRq+**E** to term all processes.
- Press Alt+SysRq+**I** to kill all processes.
- Press Alt+SysRq+**S** to sync your disks.
- Wait for OK or Done message. If you don't see a message, look at your HDD light to see if Sync made a difference.
- Press Alt+SysRq+**U** to umount all disk drives.
- Wait for OK or Done message. If you don't see a message, in 15-30 seconds, assume disks are unmounted (or that an unmount is not posssible) and proceed.
- Press Alt+SysRq+**B** to reboot.

The Letters used spell **REISUB** - use the mnemonic *Reboot Even If System Utterly Broken*.

The final option is, of course, the power button on your computer's physical exterior. Modern PCs have ACPI buttons, which just send the shutdown request to the kernel. If the ACPI daemon is listening and correctly configured, it can signal init and perform a clean shutdown.

If ACPI doesn't work, you will need to cut off electrical power. This is done through a **hard switch** (generally labeled **reset**), possibly using the same button as before but holding it pressed for 5 or so seconds. Taking out the battery (on laptops) and physically disconnecting all power cables is, of course, the only method guaranteed to work. (Make sure no other method listed above works. Even as a last resort, unplugging your computer while it is running is still not recommended.)

Resetting without shutting down can cause problems with the file system. To try and fix this problem, fsck will be run when you next boot up, and journaling filesystems will attempt to complete or rollback files which were changing. 

---

Keyboard schortcuts may vary depending on the desktop environment.
On KDE, you can use these schortcuts to leave you computer:

- `Ctrl+Alt+L`, lock screen
- `Ctrl+Alt+Del`, leave
- `Ctrl+Alt+Shift+Del`, logout without confirmation
- `Ctrl+Alt+Shift+Page Down`, shut down without confirmation
- `Ctrl+Alt+Shift+Page Up`, reboot without confirmation

For other shortcuts available on KDE, look [here](https://docs.kde.org/trunk5/en/applications/fundamentals/kbd.html).