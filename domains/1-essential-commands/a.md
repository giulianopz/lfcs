## Log into local & remote graphical and text mode consoles

Console and terminal are closely related. Originally, they meant a piece of equipment through which you could interact with a computer: in the early days of unix, that meant a teleprinter-style device resembling a typewriter, sometimes called a teletypewriter, or **tty** in shorthand. The name *terminal* came from the electronic point of view, and the name *console* from the furniture point of view. 

For a quick historical overview look [here](https://www.computernetworkingnotes.com/linux-tutorials/linux-virtual-console-and-terminal-explained.html) and [here](https://askubuntu.com/questions/506510/what-is-the-difference-between-terminal-console-shell-and-command-line).

Long story short, in modern terminology:

- a **terminal** is in Unix a textual input/output handling device, but the term is more often used for pseudo-terminals (pts) that allows us to access and use the shell (e.g. terminal emulators Konsole on KDE)
- a **console** was originally a physical terminal device connected with Linux system on serial port via serial cable physically, but now by *virtual console* is meant an app which simulates a physical terminal (on Unix-like systems, such as Linux and FreeBSD, the console appears as several terminals (ttys) accessed via spacial keys combinations)
- a **shell** is a command line interpreter (e.g. bash) invoked when a user logs in, whose primary purpose is to start other programs.

---

To log into:

- a local environment in GUI mode you must provide, when prompted, username and password

- a local environment in text/console mode (tty), start your computer and immediately after the BIOS/UEFI splash screen, press and hold the `Shift` (BIOS), or press the `Esc` (UEFI) key repeatedly, to access the GRUB menu. Once you see the GNU GRUB screen, with the first entry from the menu selected, press the `e` key. This allows you to edit the kernel parameters before booting. Look for the line that begins with `linux` (use the Up / Down / Left / Right arrow keys to navigate); `vmlinuz` should also be on the same line. At the end of this line (you can place the cursor using the arrow keys at the beginning of the line, then press the `End` key to move the cursor to the end of that line) add a space followed by the number `3`. Don't change anything else. This `3` represents the **multi-user.target** systemd target which is mapped to the old, now obsolete runlevel 2, 3 and 4 (used to start and stop groups of services). For example the old runlevel 5 is mapped to the systemd **graphical.target** and using this starts the graphical (GUI) target. After doing this, press `Ctrl+x` or `F10` to boot to console (text) mode. To reboot your system while in console mode, use the reboot command (`sudo reboot now`).

> This is how the line beginning with "linux" looks like for Ubuntu 18.04 LTS:
`linux      /boot/vmlinuz-4.18.0-15-generic root=UUID=1438eb20-da3d-4880-bb3a-414e+++0a929 ro quiet splash $vt_handoff 3`

- a remote text environment as a full login session you can use **ssh**:
`ssh -i <*rsa.pub> -p <9199> username@host -t "exec bash"`

- a remote environment in GUI mode you can use `ssh -X` to enable X11 forwarding or a remote desktop client for a full graphical interface (by default, Ubuntu comes with **Remmina** remote desktop client with support for VNC and RDP protocols).

---

Once logged command `w` can be used to show who is logged and what they are doing:
```
[root@localhost ~]# w
23:41:16 up 2 min,  2 users,  load average: 0.02, 0.02, 0.01
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     tty1                      23:40   60.00s  0.01s  0.01s -bash
root     pts/0    192.168.0.34     23:41    1.00s  0.02s  0.00s w
```

The first column shows which user is logged into system and the second one to which terminal.
In the second column:
- for virtual consoles in terminal is showed `tty1`, `tty2` etc.
- for ssh remote sessions (pseudo-terminal salve) in terminal is showed `pts/0`, `pts/1` etc.
- `:0` is for a X11 server namely used for graphical login sessions.

The usual method of command-line access in Ubuntu is to start a terminal (with `Ctrl+t` usually, or `F12` if you are using a Guake-like drop-down terminal emulator, such as Yakuake on KDE), however sometimes it's useful to switch to the real console:

- use the `Ctrl-Alt-F1` shortcut keys to switch to the first console.
- to switch back to Desktop mode, use the `Ctrl-Alt-F7` shortcut keys.

There are six consoles available. Each one is accessible with the shortcut keys `Ctrl-Alt-F1` to `Ctrl-Alt-F6`.