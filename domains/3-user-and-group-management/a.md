## Create, delete, and modify local user accounts

### Add a User

In Ubuntu, there are two command-line tools that you can use to create a new user account: 

- `useradd`, a low-level utility
- `adduser`, a script written in Perl that acts as a friendly interactive frontend for `useradd`.

Adding a new user is quick and easy, simply invoke `adduser <username>` command followed by the username and aswer all the questions when propted.

When invoked, `useradd` creates a new user account according to the options specified on the command line and the default values set in the `/etc/default/useradd` file. `useradd` also reads the content of the /etc/login.defs file. This file contains configuration for the shadow password suite such as password expiration policy, ranges of user IDs used when creating system and regular users, and more.

To create a user modifying some default values:
`sudo useradd -s /usr/bin/zsh -d "/home/students/moose" -m -k /etc/skel -c "Bullwinkle J Moose" bmoose`

To be able to log in as the newly created user, you need to set the user password. To do that run the passwd command followed by the username:
`sudo passwd <username>`

You to specify a list of supplementary groups which the user will be a member of with the -G (--groups) option:
`sudo useradd -g users -G wheel,developers <username>`

You can check the user groups by typing:
```
id username
>uid=1002(username) gid=100(users) groups=100(users),10(wheel),993(docker)
```

To define a time at which the new user accounts will expire, use the -e (--expiredate) option. This is useful for creating temporary accounts.

> Note: The date must be specified using the YYYY-MM-DD format.

For example to create a new user account named username with an expiry time set to January 22 2019 you would run:
`sudo useradd -e 2019-01-22 <username>`

Use the chage command to verify the user account expiry date:
`sudo chage -l <username>`

The default useradd options can be viewed and changed using the `-D`, `--defaults` option, or by manually editing the values in the /etc/default/useradd file.
To view the current default options type:
```
useradd -D
>GROUP=100
>HOME=/home
>INACTIVE=-1
>EXPIRE=
>SHELL=/bin/sh
>SKEL=/etc/skel
>CREATE_MAIL_SPOOL=no
```

Let’s say you want to change the default login shell from /bin/sh to /bin/bash. To do that, specify the new shell as shown below:
```
sudo useradd -D -s /bin/bash
sudo useradd -D | grep -i shell
>SHELL=/bin/bash
```

### Modify a User

To modify a user, you can use the `usermod` command which allows you to specify the same set of flags as `useradd`.

To add a user to a group: `sudo usermod -aG dialout <username>`

> Note: In general (for the GUI, or for already running processes, etc.), the user will need to log out and log back in to see their new group added. For the current shell session, you can use newgrp: `newgrp <groupname>`. This command adds the group to the current shell session.

Although not very often, sometimes you may want to change the name of an existing user. The -l option is used to change the username:
`sudo usermod -l <new-username> <username>`

To set the min and max number of days between password changes: `sudo chage -m 14 -M 30 <username>`

### Block a user

To force immediate expiration of a user account: `sudo chage -d 0 <username>`

To disable the expiration of an account, set an empty expiry date: `sudo usermod -e "" <username>`

The `-L` option allows you to lock a user account: `sudo usermod -L <username>`

The commands will insert an exclamation point (!) mark in front of the encrypted password. When the password field in the /etc/shadow file contains an exclamation point, the user will not be able to login to the system using password authentication. Other login methods, like key-based authentication (SSH Login) or switching to the user (su) are still allowed. If you want to lock the account and disable all login methods, you also need to set the expiration date to 1. The following examples shows how to lock a user: `sudo usermod -L -e 1 <username>`

To unlock a user, run usermod with the `-U` option: `usermod -U <username>`

If your system also encounters some problem(s) and you are forced to put it down to fix the problem(s), create the `/etc/nologin` file to disallow user logins and notify users: if a user attempts to log in to a system where this file exists, the contents of the nologin file is displayed, and the user login is terminated. Superuser logins are not affected. 

To block a specific user from accessing a shell: `chsh -s /bin/nologin <username>`

> Note: A user could still log on to the system via programs such as ftp that do not necessarily require a shell to connect to a system.

Use a restricted shell to limit what a user can do:
```
# assign to the the user rbash as login shell
sudo useradd <username> -s /bin/rbash
sudo passwd <username>
sudo mkdir -p /home/<username>/bin

# restrict the path to a bin dir in his home
sudo <username> /home/<username>/.bash_profile
echo "PATH=$HOME/bin" > /home/<username>/.bash_profile
sudo chown root:root /home/<username>/.bash_profile
sudo chmod 755 /home/<username>/.bash_profile

# copy into bin the only commands you want the user to access to
sudo ln -s /bin/ls /home/<username>/bin
sudo ln -s /bin/top /home/<username>/bin
sudo ln -s /bin/uptime /home/<username>/bin
sudo ln -s /bin/pinky /home/<username>/bin
```

> Note: On some distributions, rbash may not exist, so just create it as a symlink to bash: sudo ln -s /bin/bash /bin/rbash 

### Remove a User

In Ubuntu, you can use two commands to delete a user account: `userdel` and its interactive frontend `deluser`.

To delete the user and its home directory and mail spool: `sudo userdel -r <username>`

If the user you want to remove is still logged in, or if there are running processes that belong to this user, the userdel command does not allow to remove the user.

In this situation, it is recommended to log out the user and kill all user’s running processes with the killall command:
`sudo killall -u <username>`

Once done, you can remove the user.

Another option is to use the -f (--force) option that tells userdel to forcefully remove the user account, even if the user is still logged in or if there are running processes that belong to the user: `userdel -f <username>`