## Create, manage and diagnose advanced file system permissions

POSIX **Access Control Lists** (ACLs) are more fine-grained access rights for files and directories. An ACL consists of entries specifying access permissions on an associated object. ACLs can be configured per user, per group or via the effective rights mask.

These permissions apply to an individual user or a group, and use the same as **rwx** found in regular permissions. 

Before beginning to work with ACLs the file system must be mounted with ACLs turned on. This can be done in /etc/fstab for the changes to be permanent.

0. It may be necessary to install acl utilities from the repositories. In the Server Edition, this must be done, but in the desktop editions acl is installed by default: `sudo apt-get install acl`

1. Add the option acl to the partition(s) on which you want to enable ACL in /etc/fstab:
    ```
    UUID=07aebd28-24e3-cf19-e37d-1af9a23a45d4    /home    ext4   defaults,acl   0   2
    ```

    There is a possibility that the acl option is already active as default mount option on the filesystem. Btrfs does and Ext2/3/4 filesystems do too. Use the following command to check ext* formatted partitions for the option:
    ```
    tune2fs -l /dev/sda1 | grep "Default mount options:"
    >Default mount options:    user_xattr acl
    ```

    You can set the default mount options of a filesystem using the tune2fs -o option partition command, for example:
    `tune2fs -o acl /dev/sda1`

    Using the default mount options instead of an entry in /etc/fstab is very useful for external drives, such partition will be mounted with acl option also on other Linux machines. There is no need to edit /etc/fstab on every machine. 

    > Note: "acl" is specified as default mount option when creating an ext2/3/4 filesystem. This is configured in /etc/mke2fs.conf.

2. If necessary, remount partition(s) on which ACLs were enabled for them to take effect: `sudo mount -o remount /`

3. Verify that ACLs are enabled on the partition(s): `mount | grep acl`

---

ACL entries consist of a user (u), group (g), other (o) and an effective rights mask (m). An effective rights mask defines the most restrictive level of permissions. `setfacl` sets the permissions for a given file or directory. `getfacl` shows the permissions for a given file or directory.

Defaults for a given object can be defined.

ACLs can be applied to users or groups but it is easier to manage groups. Groups scale better than continuously adding or subtracting users. 

You will notice that there is an ACL for a given file because it will exhibit a + (plus sign) after its Unix permissions in the output of `ls -l`:
```
ls -l /dev/audio
>crw-rw----+ 1 root audio 14, 4 nov.   9 12:49 /dev/audio
```

To list the ACLs for a given file or directory: `getfacl <file-or-dir>`

To set permissions for a user (user is either the user name or ID): `setfacl -m "u:user:permissions" <file/dir>`

To set permissions for a group (group is either the group name or ID): `setfacl -m "g:group:permissions" <file/dir>`

To set permissions for others: `setfacl -m "other:permissions" <file/dir>`

Removing a Group from an ACL: `setfacl -x g:green /var/www`

Transfer ACL attributes from a specification file:
```
echo "g:green:rwx" > acl 
setfacl -M acl /path/to/dir
```

Output from getfacl is accepted as input for setfacl with `-M` (`-b` clear ACLs, `-n` do not recalculate effective rights mask, `-` read from stdin): `getfacl dir1 | setfacl -b -n -M - dir2`

To copy the ACL of a file to another: `getfacl file1 | setfacl --set-file=- file2`

Copying the access ACL into the Default ACL of the sam dir: `getfacl --access dir | setfacl -d -M- dir`

To allow all newly created files or directories to inherit entries from the parent directory (this will not affect files which were already present in the directory, use `-R` to modify also these files): `setfacl -d -m "entry" <dir>`

Set ACL permissions recursively: `setfacl -Rm u:foo:r-x dir`

To remove a specific entry: `setfacl -x "entry" <file/dir>`

To remove the default entries: `setfacl -k <file/dir>`

To remove all entries (entries of the owner, group and others are retained): `setfacl -b <file/dir>`

---

### File Attributes

In Linux, file attributes are meta-data properties that describe the file’s behavior. For example, an attribute can indicate whether a file is compressed or specify if the file can be deleted.

Some attributes like immutability can be set or cleared, while others like encryption are read-only and can only be viewed. The support for certain attributes depends on the filesystem being used.

The chattr command takes the following general form:
`chattr <options> <operator> <attributes> file`

The value of the `<operator>` part can be one of the following symbols:

- `+`, to add the specified attributes to the existing ones
- `-`, to remove the specified attributes from the existing ones
- `=`, to set the specified attributes as the only attributes.

The operator is followed by one or more `<attributes>` flags that you want to add or remove from the file attributes:

- `a`, append only
- `c`, compressed
- `d`, no dump
- `e`, extent format
- `i`, immutable
- `j`, data journalling
- `s`, secure deletion
- `t`, no tail-merging
- `u`, undeletable
- `A`, no atime updates
- `C`, no copy on write
- `D`, synchronous directory updates
- `S`, synchronous updates
- `T`, top of directory hierarchy.

> Note: By default, file attributes are not preserved when copying a file with commands like cp or rsync.

For example, if you want to set the immutable bit on some file, use the following command:
`chattr +i /path/to/file`

You can view the file attributes with the lsattr command:
```
lsattr /path/to/file
>--------------e----- file
```

As the ls -l command, the -d option with lsattr will list the attributes of the directory itself instead of the files in that directory:
```
lsattr -d script-test/
>-------------e-- script-test/
```