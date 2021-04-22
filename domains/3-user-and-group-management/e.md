##  Configure user resource limits

Any user can change it's own soft limits, between "zero", and the hard limit (typically enforced by pam_limit).

To print all the resource limits for the current user:
`ulimit -a`

Show the current Soft limit for "memlock":
```
ulimit -S -l
> 64
```

Set the current Soft "memlock" limit to 48KiB:
```
ulimit -S -l 48
```


The system resources are defined in a configuration file located at */etc/security/limits.conf*. *ulimit*, when called, will report these values.

To manually set resource limits for users or groups:
`sudo vim /etc/security/limits.conf`

Each entry has to follow the following structure: [domain] [type] [item] [value].

These are some example lines which might be specified in */etc/security/limits.conf*:
```
*               soft    core            0
root            hard    core            100000
*               hard    rss             10000
@student        hard    nproc           20
@faculty        soft    nproc           20
@faculty        hard    nproc           50
ftp             hard    nproc           0
@student        -       maxlogins       4
```

To find limits for a process:
```
cat /proc/<PID>/limits
```

