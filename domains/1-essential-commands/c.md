## Evaluate and compare the basic file system features and options

Print out disk free space in a human readable format:
`df -h`

See which file system type each partition is:
`df -T`

See more details with `file` command about individual devices:
`file -sL /dev/sda1`

Or: `sudo fdisk -l /dev/sda1`

File system fatures:

- **ext**, "Extended Filesystem", old, deprecated
- **ext2**, no journaling, max file size 2TB, lower writes to disk = good for USB sticks etc
- **ext3**, journaling (journal, ordered, writeback), max file size 2TB; journaling, i.e. file changes and metadata are written to a journal before being committed; if a system crashes during an operation, the journal can be used to bring back the system files quicker with lower likeliness of corrupted files
- **ext4**, from 2008, supports up to 16TB file size, can turn off journaling optionally
- **fat**, from Microsoft, no journaling, max file size 4 GB
- **tmpfs**, temporary file system used on many Unix-like filesystems, mounted and structured like a disk-based filesystem, but resides in volatile memory space, similar to a RAM disk
- **xfs**, excels at parallel I/O, data consistency, and overall filesystem performance, well suited for real-time applications, due to a unique feature which allows it to maintain guaranteed data I/O bandwidth, originally created to support extremely large filesystems with sizes of up to 16 exabytes and file sizes of up to 8 exabytes
- **btrfs**, a copy-on-write filesystem for Linux aimed at implementing advanced features while focusing on fault tolerance, repair, and easy administration, although it has some features that make it [unstable](https://btrfs.wiki.kernel.org/index.php/FAQ#Is_btrfs_stable.3F).