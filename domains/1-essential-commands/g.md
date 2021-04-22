## Archive, backup, compress, unpack, and uncompress files

The idea of “archiving” data generally means backing it up and saving it to a secure location, often in a compressed format. An “archive” on a Linux server in general has a slightly different meaning. Usually it refers to a `tar` file.

Historically, data from servers was often backed up onto tape archives, which are magnetic tape devices that can be used to store sequential data. This is still the preferred backup method for some industries. In order to do this efficiently, the tar program was created so that you can address and manipulate many files in a filesystem, with intact permissions and metadata, as one file. You can then extract a file or the entire filesystem from the archive.

Basically, a tar file (or a **tarball**) is a file format that creates a convenient way to distribute, store, back up, and manipulate groups of related files. Tar is normally used with a compression tool such as `gzip`, `bzip2`, or `xz` to produce a compressed tarball.

**gzip** is the oldest compression tool and provides the least compression, while **bzip2** provides improved compression. In addition, **xz** is the newest but (usually) provides the best compression. This advantage comes at a price: the time it takes to complete the operation, and system resources used during the process. Normally, tar files compressed with these utilities have **.gz**, **.bz2**, or **.xz** extensions, respectively.

| Long option | Abbreviation | Description |
| ----------- | ----------- | ----------- |
| –create |	c |	 Creates a tar archive |
| –concatenate | A | Appends tar files to an archive |
| –append |	r |	Appends files to the end of an archive |
| –update |	u |	Appends files newer than copy in archive |
| –diff or –compare | d | Find differences between archive and file system |
| –file [archive] | f | Use archive file or device *archive* |
| –list | t | Lists the contents of a tarball |
| –extract or –get | x | Extracts files from an archive |
| –directory [dir] | C | Changes to directory dir before performing operations |
| –same-permissions | p | Preserves original permissions |
| –verbose | v | Lists all files read or extracted. When this flag is used along with –list, the file sizes, ownership, and time stamps are displayed. |
| –verify | W |	Verifies the archive after writing it |
| –exclude [file] | — | Excludes file from the archive |
| –exclude=pattern | X | Exclude files, given as a *pattern* |
| –gzip or –gunzip | z | Processes an archive through gzip |
| –bzip2 | j | Processes an archive through bzip2 |
| –xz | J |	Processes an archive through xz |

List the contents of a tarball : `tar tvf [tarball]`

Update or append operations cannot be applied to compressed files directly:
```
gzip -d <myfiles.tar.gz>
tar --delete --file <myfiles.tar> <file4>       # deletes the file inside the tarball
tar --update --file <myfiles.tar> <file4>       # adds the updated file
gzip myfiles.tar
```

Exclude files from backup depending on file type (e.g. mpeg):
`tar X <(for i in $DIR/*; do file $i | grep -i mpeg; if [ $? -eq 0 ]; then echo $i; fi; done) -cjf backupfile.tar.bz2 $DIR/*`

Restore backups preserving permissions: `tar xjf backupfile.tar.bz2 --directory user_restore --same-permissions`

Only store files newer than a given date (i.e. *differential backup*): `tar --create --newer '2011-12-1' -vf backup1.tar /var/tmp`

> Note: If [date] starts with `/` or `.` it is taken to be a filename and the ctime of that file is used as the date.

> Note: A differential backup backs up only the files that changed since the last full back. Incremental backups also back up only the changed data, but they only back up the data that has changed since the last backup — be it a full or incremental backup.

> Note: Each instance of `--verbose` on the command line increases the verbosity level by one, so if you need more details on the output, specify it twice. 

To create incremental backups:
```
mkdir data
echo "File1 Data" > data/file1
echo "File2 Data" > data/file2
tar --create --listed-incremental=data.snar --verbose --verbose --file=data.tar data
>tar: data: Directory is new
>drwxrwxr-x ubuntu/ubuntu     0 2018-04-03 14:00 data/
>-rw-rw-r-- ubuntu/ubuntu     5 2018-04-03 14:00 data/file1
>-rw-rw-r-- ubuntu/ubuntu     5 2018-04-03 14:00 data/file2

echo "File3 Data" > data/file3
tar --create --listed-incremental=data.snar --verbose --verbose --file=data1.tar data
>drwxrwxr-x ubuntu/ubuntu     0 2018-04-03 14:41 data/
>-rw-rw-r-- ubuntu/ubuntu    11 2018-04-03 14:41 data/file3

echo "more data" >> data/file2
tar --create --listed-incremental=data.snar --verbose --verbose --file=data2.tar data
>drwxrwxr-x ubuntu/ubuntu     0 2018-04-03 14:41 data/
>-rw-rw-r-- ubuntu/ubuntu    15 2018-04-03 14:47 data/file2

rm data/file1
tar --create --listed-incremental=data.snar --verbose --verbose --file=data3.tar data
>drwxrwxr-x ubuntu/ubuntu     0 2018-04-03 14:55 data/

tar --list --verbose --verbose --listed-incremental=data.snar --file=data3.tar
>drwxrwxr-x ubuntu/ubuntu    15 2018-04-03 14:55 data/
>N file2
>N file3

# restore the dir one backup at a time

tar --extract --verbose --verbose --listed-incremental=/dev/null --file=data.tar
>drwxrwxr-x ubuntu/ubuntu    15 2018-04-03 14:00 data/
>-rw-rw-r-- ubuntu/ubuntu     5 2018-04-03 14:00 data/file1
>-rw-rw-r-- ubuntu/ubuntu     5 2018-04-03 14:00 data/file2
cat data/file1 data/file2
>File1 Data
>File2 Data

tar --extract --verbose --verbose --listed-incremental=/dev/null --file=data1.tar
>drwxrwxr-x ubuntu/ubuntu    22 2018-04-03 14:41 data/
>-rw-rw-r-- ubuntu/ubuntu    11 2018-04-03 14:41 data/file3

tar --extract --verbose --verbose --listed-incremental=/dev/null --file=data2.tar
>drwxrwxr-x ubuntu/ubuntu    22 2018-04-03 14:41 data/
>-rw-rw-r-- ubuntu/ubuntu    15 2018-04-03 14:47 data/file2
cat data/file2
>File2 Data
>more data

tar --extract --verbose --verbose --listed-incremental=/dev/null --file=data3.tar
>drwxrwxr-x ubuntu/ubuntu    15 2018-04-03 14:55 data/
>tar: Deleting ‘data/file1’

# the dir is now up-to-date to the last backup
```

> Note: Each backup uses the same meta file (.sar) but its own archive. 

---

`rsync` is a fast and versatile command-line utility for synchronizing files and directories between two locations over a remote shell, or from/to a remote rsync daemon. It provides fast incremental file transfer by transferring only the differences between the source and the destination. It finds files that need to be transferred using a "quick check" algorithm (by default) that looks for files that have changed in size or in last-modified time.

`sync` can be used for mirroring data, incremental backups, copying files between systems, and as a replacement for `scp`, `sftp`, and `cp` commands.

rsync provides a number of options that control how the command behaves. The most widely used options are:

- `-a`, `--archive`, archive mode, equivalent to `-rlptgoD`, this option tells rsync to syncs directories recursively, transfer special and block devices, preserve symbolic links, modification times, groups, ownership, and permissions
- `-n`, `--dry-run`, perform a trial run with no changes made
- `-z`, `--compress`, this option forces rsync to compresses the data as it is sent to the destination machine
> Tip: Use this option only if the connection to the remote machine is slow.
- `-P`, equivalent to `--partial --progress`, when this option is used, rsync shows a progress bar during the transfer and keeps the partially transferred files. 
> Tip: Useful when transferring large files over slow or unstable network connections.
- `--delete`, when this option is used, rsync deletes extraneous files from the destination location, it is useful for mirroring
- `-q`, `--quiet`, use this option if you want to suppress non-error messages
- `-e`, this option allows you to choose a different remote shell, by default, rsync is configured to use ssh.

### Basic Rsync Usage 

The most basic use case of rsync is to copy a single file from one to another local location: `rsync -a /opt/filename.zip /tmp/`

> Note: The user running the command must have read permissions on the source location and write permissions on the destination.

Omitting the filename from the destination location copies the file with the current name. If you want to save the file under a different name, specify the new name on the destination part: `rsync -a /opt/filename.zip /tmp/newfilename.zip`

The real power of rsync comes when synchronizing directories. The example below shows how to create a local backup of website files:
`rsync -a /var/www/domain.com/public_html/ /var/www/domain.com/public_html_backup/`

> Note: If the destination directory doesn’t exist, rsync will create it.

> Note: It is worth mentioning that rsync gives different treatment to the source directories with a trailing slash (`/`). If the source directory has a trailing slash, the command will copy only the directory contents to the destination directory. When the trailing slash is omitted, rsync copies the source directory inside the destination directory.

### Using rsync to sync data from/to a remote machine

When using rsync to transfer data remotely, it must be installed on both the source and the destination machine. The new versions of rsync are configured to use SSH as default remote shell.

In the following example, we are transferring a directory from a local to a remote machine: 
`rsync -a /opt/media/ remote_user@remote_host_or_ip:/opt/media/`

> Note: If we run the command again, we will get a shorter output, because no changes have been made. This illustrates rsync’s ability to use modification times to determine if changes have been made.

To transfer data from a remote to a local machine, use the remote location as a source:
`rsync -a remote_user@remote_host_or_ip:/opt/media/ /opt/media/`

If SSH on the remote host is listening on a port other than the default 22, specify the port using the `-e` option:
`rsync -a -e "ssh -p 2322" /opt/media/ remote_user@remote_host_or_ip:/opt/media/`

When transferring large amounts of data it is recommended to run the rsync command inside a screen session or to use the `-P` option:
`rsync -a -P remote_user@remote_host_or_ip:/opt/media/ /opt/media/`

### Exclude Files and Directories

There are two options to exclude files and directories. The first option is to use the `--exclude` argument and specify the files and directories you want to exclude on the command line. When excluding files or directories, you need to use their relative paths to the source location.

In the following example shows how exclude the node_modules and tmp directories:
`rsync -a --exclude=node_modules --exclude=tmp /src_directory/ /dst_directory/`

The second option is to use the `--exclude-from` option and specify the files and directories you want to exclude in a file:
`rsync -a --exclude-from='/exclude-file.txt' /src_directory/ /dst_directory/`

The content of `/exclude-file.txt` can be something like:
```
node_modules
tmp
```

---

To make a full raw device backup: `sudo dd if=/dev/sda of=/dev/sdb1 bs=64K conv=noerror,sync status=progress`

To create a compressed image: `sudo dd if=/dev/sda conv=sync,noerror bs=64K | gzip -c  > /PATH/TO/DRIVE/backup_image.img.gz`

To restore it: `gunzip -c /PATH/TO/DRIVE/backup_image.img.gz | dd of=/dev/sda`