## Diagnose and manage processes

### Processes

`ps`: reports a snapshot of the current processes
```
ps # processes of which I'm owner

ps aux # all processes
```

It will print:

- `user`, user owning the process
- `pid`, process ID of the process (it is set when process start, this means that implicitly provides info on starting order of processes)
- `%cpu`, the CPU time used divided by the time the process has been running
- `%mem`, ratio of the process’s resident set size to the physical memory on the machine
- `VSZ` (virtual memory), virtual memory usage of entire process (in KiB)
- `RSS` (resident memory), resident set size, the non-swapped physical memory that a task has used (in KiB)
- `tty`, terminal the process is running on (`?` means that isn't attached to a tty)
- `stat`, process state
- `start`, starting time or date of the process
- `time`, cumulative CPU time
- `command`, command with all its arguments (those within `[ ]` are system processes or kernel thread)

Examples:
```
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu
```
where: 
- `-e`, shows same result of `-A`
- `-o`, specifies columns to show
- `--sort`, sorts by provided parameter

```
ps -e -o pid,args --forest # the last arg shows a graphical view of processes tree
```

In /proc/[pid] there is a numerical subdirectory for each running process; the subdirectory is named by the process ID. The subdirectory /proc/[pid]/fd contains one entry for each file which the process has open, named by its file descriptor, and which is a symbolic link to the actual file. Thus, 0 is standard input, 1 standard output, 2 standard error, and so on.

Lists open files associated with process id of pid: `lsof -p pid`

Find a parent PID (PPID) from a child's process ID (PID): `pstree -s -p <PID>`

### Background processes

Suffix command with `&` executes a process in background:
```
sleep 600 &
jobs    # lists processes in background
>[1]+  Running                 sleep 600 &
kill %1 # kills by job number
>[1]+  Terminated              sleep 600
```

To return a process in foreground: `fg <PID>`

### Process priority

List "nice" value of processes: `ps -e -o pid,nice,command`
**Niceness** (NI) value is a user-space concept, while **priority** (PR) is the process's actual priority that use by Linux kernel. In a Linux system priorities are 0 to 139 in which 0 to 99 for real time and 100 to 139 for users. Nice value range is -20 to +19 where -20 is highest, 0 default and +19 is lowest. A negative nice value means higher priority, whereas a positive nice value means lower priority.The exact relation between nice value and priority is:
```
PR = 20 + NI
```
so, the value of PR = 20 + (-20 to +19) is 0 to 39 that maps 100 to 139.

> Note: Only root can assign negative values.

Execute a command in background with a given nice value to be added to the current one: `nice -n <value> <command> &`

> Note: In case you want to associate a negative nice value to the process, then you'll have to use double hyphen: 
```
nice --10 wall <<end
System reboots in 5 minutes for Ubuntu Linux kernel update! 
Save all your work!!!
-- Sysadmin
end
```

Riassign priority to a process: `renice -n <value> <pid>`

### Signals

Send a SIGTERM (15) signal to process: `kill <pid>`

Send a SIGKILL signal to process: `kill -9 <pid>`

Send a signal that correspond to number to process: `kill -<number> <pid>`

List all available signal and corresponding number: `kill -l`

Kill all child processes: `pkill -P <ppid>`    

Kill all processes whose name matches a regex pattern: `pkill -9 <pattern>` 

Kill by exact name (safer than pkill), unless -r is specified: `killall <name>`