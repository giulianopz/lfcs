## Create and manage hard and soft links

A **file** is a named collection of related data that appears to the user as a single, contiguous block of information and that is retained in storage. 

Whereas users identify files by their names, Unix-like operating systems identify them by their **inodes**. An inode is a data structure that stores everything about a file apart from its name and actual content. A **filename** in a Unix-like operating system is just an entry in an inode table. Inode numbers are unique per filesystem, which means that an inode with a same number can exist on another filesystem in the same computer. 

> Note: Saying that "on a UNIX system, everything is a file; if something is not a file, it is a process" is just an acceptable generalization.

There are two types of links in UNIX-like systems:

- **hard** links: you can think a hard link as an additional name for an existing file. Hard links are associating two or more file names with the same inode. You can create one or more hard links for a single file. Hard links cannot be created for directories and files on a different filesystem or partition.
- **soft** links: a soft link is something like a shortcut in Windows. It is an indirect pointer to a file or directory. Unlike a hard link, a symbolic link can point to a file or a directory on a different filesystem or partition.

In case you delete a file, the hard link will survive while the soft link will be broken.

To create a hard link: `ln source target`

To create a soft link: `ln -s source target`

To overwrite the destination path of the symlink, use the `-f` (`--force`) option: `ln -sf source target`

To delete/remove symbolic links use either the `rm` or `unlink`: `unlink symlink_to_remove`

To find all hardlinks in a folder:
```
find /some/dir -type f -links +1 -printf '%i %n %p\n'
>129978 2 ./book.pdf
>129978 2 ./hard-linked-book.pdf
```

If the other file in the same dir, this will be apparent since they have the same inode. Otherwise, this command will only show all regular files that have more than one link (name) to them, not telling you which names are linked to the same file, for that you could use `-samefile` or `-inum`, e.g.: `find -samefile "$somefile"`