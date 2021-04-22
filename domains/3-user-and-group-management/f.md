## Manage user privileges

A user with administrative privileges is sometimes called a `super user`. This is simply because that user has more privileges than normal users. Commands like `su` and `sudo` are programs for temporarily giving you “super user” (administrative) privileges.

`Administrative privileges` are associated with your user account. Administrator users are allowed to have these privileges while Standard users are not. Without administrative privileges you will not be able to install software. Some user accounts (e.g `root`) have permanent administrative privileges. You should not use administrative privileges all of the time, because you might accidentally change something you did not intend to (like delete a needed system file, for example).

These privileges are gained by adding the user to the `sudo` group. Users in the "sudo" group can use sudo to gain administrative privileges after supplying their password. 

> Note: Up until Ubuntu 11.10, administrator access using the sudo tool was granted via the "admin" Unix group. Starting with Ubuntu 12.04, administrator access are granted via the "sudo"group. This makes Ubuntu more consistent with the upstream implementation and Debian. For compatibility purposes, the admin group is still available to provide sudo/administrator access.

If you want a new user to be able to perform administrative tasks, you need to add the user to the `sudo` group:
`sudo usermod -aG sudo <username>`

As an alternative to putting your user in the sudo group, you can use the `visudo` command, which opens a configuration file called `/etc/sudoers` in the system’s default editor, and explicitly specify privileges on a per-user basis: `sudo visudo`

> Note: Typically, visudo uses vim to open the /etc/sudoers. If you don’t have experience with vim and you want to edit the file with nano , change the default editor by running: sudo EDITOR=nano visudo

Use the arrow keys to move the cursor, search for the line that defines root previleges and use the same syntax for this user:
```
#       HOSTS=(USERS:GROUPS) COMMANDS
root    ALL=(ALL:ALL) ALL
newuser ALL=(ALL:ALL) ALL
```

Another typical example is to allow the user to run only specific commands via sudo (and without password). For example, to allow only the `mkdir` and `rmdir` commands, you would use:
`username ALL=(ALL) NOPASSWD:/bin/mkdir,/bin/rmdir`

To remove the sudo privileges from a specific user: `sudo deluser <username> sudo`