## List, set, and change standard file permissions

To see user standard (**UGO**) permissions use `ls -l`. Permissions are in the 1st column. Each file/directory has an owner and is associated to a group: the former is in the 3rd columns, the latter in the 4th.

The permissions for each file/directory are given for each of this category:

- owner (u)
- group (g)
- others (o) (all other users that are not the owner and are not member of group).

For each category the following permissions can be set:

| Name | String value | Octal Value |
| ----------- | ----------- | ----------- |
| read | r | 4 |
| write | w | 2 |
| exec | x | 1 |


The right that each permission provide are different and depends if target is a file or a directory:

| Permission | File | Directory |
| ----------- | ----------- | ----------- |
| read | read |	list |
| write | modify | 	create/delete |
| exec | run | cd |

> Note: When the exec bit is set for other (also said the "world"), the file will be executed with the identity of the user who is executing the command (his user ID and group ID).

There are two modes for declare permissions using `chmod` command:

- absolute mode, uses numbers for each permission, that must be added if more than a permission is set:
```
chmod 760 file
# owner: granted read, write and exec
# group: granted read and write
# other: no permissions set
```

- relative mode:
```
chmod +x file   # adds exec to owner, group and other
chmod g+w file  #adds write to group
chmod o-rw file #remove read and write to others
```

There are other special permissions that can be granted to file/directories:

| Permission | File | Directory |
| ----------- | ----------- | ----------- |
| suid (4, -s/-S) | run as user owner | subfiles inherit user of parent dir, while subdirs inherit suid |
| sgid (2, -s/-S) | run as group owner | subfiles inherit group of parent dir, while subdirs inherit sgid |
| sticky bit (1, -t/-T) | N/A | files inside dir can be deleted only by the owner |

> Note: Since the special bits appear in the third position as exec bit, "-lowercase" means only the special bit is active, whereas "-uppercase" means that both special bit and exec bit are set.  

Special bits can be set with:

- absolute mode:
```
chmod 4760 file 
```
- relative mode:
```
chmod u+s file  # sets suid
chmod g+s file  # sets guid
chmod +t dir    # sets sticky bit
```

> Note: When a file with setuid is executed, the resulting process will assume the effective user ID given to the owner: if the owner is root, this could represents a potential security risk (privilege escalation). It is a good practice to monitor a system for any suspicious usages of the setuid bits to gain superuser privileges: `find / -user root -perm -4000 -exec ls -ldb {} \;`

> Note: Linux ignores the setuid bit on all interpreted executables for security reasons. If we want our shell script to have the setuid permission, we can use the sudo command to gain privileges of the owner of the script file.