## Create, delete, and modify local groups and group memberships

Use the `groupadd` command to add a new group: `groupadd [options] group_name`

To creaste a system group with the give GID: `$ sudo groupadd -r -g 215 staff`

> Note: By convention, UIDs and GUIDs in the range 0-999 are reserved to system users and groups.

> Note: On many Linux systems, the USERGROUPS_ENAB variable in /etc/login.defs controls whether commands like useradd or userdel automatically add or delete an associated personal group.

Use the `groupmod` command to modify an existing group: `groupmod [options] group_name`

Use `groupdel` to delete the group. You can remove a group even if there are users in the group: `groupdel group_name`

> Note: You can not remove the primary group of an existing user. You must remove the user before removing the group.

Use the gpasswd command to administer the groups: `gpasswd [options] group_name`

To add user test in group student: `gpasswd -a test student`

The `groups` command displays the group the user belongs to:
```
groups <username>
><username> : oinstall dba asm asmdba oper
grep <username> /etc/group
>oinstall:x:5004:<username>
>dba:x:5005:<username>
>asm:x:5006:<username>
>asmdba:x:5007:<username>
>oper:x:5008:<username>
```

The `newgroup` command executes a new shell and changes a user’s real group information:
```
id
>uid=5004(<username>) gid=5004(oinstall) groups=5004(oinstall),5005(dba) ...

ps
>   PID TTY          TIME CMD
>106591 pts/0    00:00:00 bash
>106672 pts/0    00:00:00 ps

newgrp dba
# the gis is changed
id
>uid=5004(<username>) gid=5005(dba) groups=5005(dba),5004(oinstall) ...

# also note that a new shell has been executed
ps
>   PID TTY          TIME CMD
>106591 pts/0    00:00:00 bash
>106231 pts/0    00:00:00 bash
>106672 pts/0    00:00:00 ps
```

> Note: You can only change your real group name to a group that you are member of.