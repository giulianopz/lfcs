## Tips & tricks

1. When entering a password in a terminal, if you realize there's a typo, type `ctrl + u` to undo the password just entered and enter it again.

2. Escaping strings in bash using `!:q` (TODO)

3. reverse search (TODO)

4. Hiding passwords in scripts (TODO)

5. Create a simple chat with `netcat` (TODO)

6. Bash allows you to ignore history entries that begin with a space if you set the `HISTCONTROL` variable to `ignorespace`. Type a space before a command before running it in the bash shell and the command will run normally, but won’t appear in your history if you have this variable enabled. This allows you to keep your history a bit cleaner, choosing to run commands without them appearing in your history. Bash also allows you to ignore duplicate commands that can clutter your history. To do so, set `HISTCONTROL` to `ignoredups`. To use both the ignorespace and ignoredups feature, set the `HISTCONTROL` variable to `ignoreboth`.

7. Always check if a piece of hardware is compatible with Linux, before buying it. For printers, have a look at this [list](https://haydenjames.io/finding-linux-compatible-printers/) or che the [OpenPrinting](https://www.openprinting.org/printers/) database.

8. [More on Using Bash's Built-in /dev/tcp File (TCP/IP)](https://www.linuxjournal.com/content/more-using-bashs-built-devtcp-file-tcpip).

9. Find out neighbours in your local network: `sudo nmap -sn 192.168.1.0/24`

10. [Learn the networking basics every sysadmin needs to know](https://www.redhat.com/sysadmin/sysadmin-essentials-networking-basics)

11. Use floating-point arithmetich in bash: `bc <<< 'scale=2; 61/14'`

12. Encrypt your emails with [GnuPG](https://emailselfdefense.fsf.org/en/) to protect yourself from mass surveillance.

13. [Check the physical health of a USB stick](https://www.cyberciti.biz/faq/linux-check-the-physical-health-of-a-usb-stick-flash-drive/)

14. [Micro BGP Suite: The Swiss Army Knife of Routing Analysis](https://labs.ripe.net/author/lorenzo_cogotti/micro-bgp-suite-the-swiss-army-knife-of-routing-analysis/)

15. Playgrounds to fiddle around with:
    1.  [systemd by example](https://systemd-by-example.com/)
    2.  [mess with dns](https://messwithdns.net/)
    3.  [a simple DNS lookup tool](https://dns-lookup.jvns.ca/)
    4.  [nginx](https://nginx-playground.wizardzines.com/)
