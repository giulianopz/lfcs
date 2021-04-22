## Verify the integrity and availability of resources

Display amount of free and used memory in the system:
`free -h`

Report virtual memory statistics:
`vmstat 1 5`

Report Central Processing Unit (CPU) statistics and input/output statistics for devices and partitions:
`iostat 1 2`

Display a periodically updated table of I/O usage:
`sudo iotop`

Collect, report and save system activity information in a binary file:
`sar 2 5 -o report.file`

Find which process lock a file:
```
less .vimrc
# put in background (ctrl+Z)
fuser .vimrc
.vimrc:              28135
```
or:
`lsof | grep .vimrc`

See currently used swap areas:
`cat /proc/swaps`

Examine filesystem capacity and usage:
`df -hT`

Find what is eating up disk space:
`sudo du -x -d1 -h / | sort -h`

> Note: The flag -h makes `sort` command to compare numbers in human readable format.

See if a piece of hardware is detected:
`lspci`

or:
`lsusb`

Find open ports on your machine:
`sudo netstat -nlptu`

Find laptop battery charge state and percentage:
`upower -i $(upower -e | grep _BAT) | grep -P "(state|percentage)"`