## Locate and analyze system log files

In Linux, logs come from different sources, mainly:

- **systemd journal**: most Linux distros have **systemd** to manage services (like SSH above), systemd catches the output of these services (i.e., logs like the one above) and writes them to the **journal**, the journal is written in a binary format, so you’ll use `journalctl` to explore it, like:
    ```
    journalctl
    >-- Logs begin at Tue 2021-01-05 15:47:18 CET, end at Sat 2021-04-03 10:14:41 CEST. --
    >Jan 05 15:47:18 user@hostname kernel: microcode: microcode updated early to revision 0xd6, date = 2020-04-27
    >Jan 05 15:47:18 user@hostname kernel: Linux version 5.4.0-59-generic (buildd@lcy01-amd64-028) (gcc version 9.3.0 (Ubuntu 9.3.0-17ubuntu1~20.>04)) #65-Ubuntu SMP Thu Dec 10 12>
    >Jan 05 15:47:18 user@hostname kernel: Command line: BOOT_IMAGE=/boot/vmlinuz-5.4.0-59-generic root=UUID=1c568adb-6778-42a6-93e0-a3cab4f81e8f ro quiet splash vt.handoff=7
    ```

- **syslog**: when there’s no systemd, processes like SSH can write to a UNIX socket (e.g., /dev/log) in the syslog message format. A syslog daemon (e.g., **rsyslog**) then picks the message, parses it and writes it to various destinations. By default, it writes to files in **/var/log**

- the Linux kernel writes its own logs to a **ring buffer**. Systemd or the syslog daemon can read logs from this buffer, then write to the journal or flat files (typically /var/log/kern.log). You can also see kernel logs directly via dmesg:
    ```
    dmesg -T
    >...
    >[Tue May 5 08:41:31 2020] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
    >...
    ```
- **application logs**: non-system applications tend to write to /var/log as well.

These sources can interact with each other: journald can forward all its messages to syslog. Applications can write to syslog or the journal. 

Typically, you’ll find Linux server logs in the /var/log directory and sub-directory. This is where syslog daemons are normally configured to write. It’s also where most applications (e.g Apache httpd) write by default. For systemd journal, the default location is /var/log/journal, but you can’t view the files directly because they’re binary. 

If your Linux distro uses systemd (and most modern distros do), then all your system logs are in the journal. To inspect the journal for logs related to a given unit, type: `journalctl -eu <unit-name>`

By default, journalctl pages data through less, but if you want to filter through grep you’ll need to disable paging: `journalctl --no-pager | grep "ufw"`

If your distribution writes to local files via syslog, you can view them with standard text processing tools: `grep "error" /var/log/syslog | tail`. /var/log/syslog is the “catch-all” log file of rsyslod and contains much everything /var/log/messages used to contain in previous versions of Ubuntu, as this line from /etc/rsyslog.conf suggests: `*.* /var/log/syslog`. Each entry in this configuration file consists of two fields, the selector and the action. Each log message is associated with an application subsystem (called “facility” in the documentation) and each message is also associated with a priority level.

Some distributions have both: journald is set up to forward to syslog. This is done by setting `ForwardToSyslog=Yes` in /etc/systemd/journald.conf.

Kernel logs go by default to /var/log/dmesg and /var/log/kern.log.

To wait for new messages from the kernel ring buffer: `dmesg -w`

A neat utility to place messages into the System Log arbitrarily is the `logger` tool: `logger "Hello World"`

To send instead messages to the systemd journal: `echo 'hello' | systemd-cat [-t <someapp>] [-p <logging-level>]`

Show only the most recent journal entries, and continuously print new entries as they are appended to the journal: `journalctl -f`

To learn more about journactl options to view and manipulate systemd logs, look [here](https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs).