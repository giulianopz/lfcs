## Read, and use system documentation

To learn more about system utilities, you can use:

- `man <command>`, to read man pages (UNIX way of distributiing documentation) stored in /usr/share/man and /usr/local/share/man
- `info <command>`, similarly (GNU project meant to replace man)
- `help <command>`, for shel built-in commands only.

You can use the `apropos` command (for example, with a keyword such as "partition") to find commands related to something:
```
apropos partition
```
> Note: This equivalent to: `man -k <keyword>`

> Note: Man pages are grouped into sections (`man man-pages`) and the section number can be passed to man command:
```
man 1 passwd    # display passwd command doc 
man 5 passwd    # display passwd file format doc 
```

Use this simple script to quickly find what a command argument stands for:
```
#!/bin/bash
# Usage: mans <command> <arg>
# e.g. mans cp -R

CMD=$1
OP=$2

if [[ -z "$1" || -z "$2" ]]; then
    echo "No arguments supplied: you mast pass an entry in the man and an option"
    exit 1
fi

echo $(man ${CMD} | awk '/^ *-*'${OP}'[ |,]+.*$/,/^$/{print}')
exit 0
```