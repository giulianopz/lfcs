## Verify the integrity and availability of key processes

Analyze boot time with regard to single processes:
`systemd-analyze blame`

List process sorted per cpu usage in descending order:
`ps aux --sort=-pcpu | head`

List processes in tree format:
`ps -e --forest`

Displays a dynamic real-time view of a running processes and threads:
`top`

List process table sorted by an arbitrary column:
`ps aux | sort -n -k 3 | head`

Get a visual description of process ancestry or multi-threaded applications:
`pstree -aAp <pid>`

Find the process ID of a running process:
`pidof <process>`

Intercept and log the system calls:
`strace -Ff -tt <program> <arg> 2>&1 | tee strace-<program>.log`

Use `-p` for an already running process.