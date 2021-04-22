## Use input-output redirection

When bash starts it opens the three standard file descriptors (/dev/fd/*): **stdin** (file descriptor 0), **stdout** (file descriptor 1), and **stderr** (file descriptor 2). A **file descriptor** (fd) is a number which refers to an open file. Each process has its own private set of fds, but fds are inherited by child processes from the parent process.

File descriptors always point to some file (unless they're closed). Usually when bash starts all three file descriptors, stdin, stdout, and stderr, point to your terminal. The input is read from what you type in the terminal and both outputs are sent to the terminal.

In fact, an open terminal in a Unix-based operating system is usually itself a file, commonly stored in /dev/tty0. When a new session is opened in parallel with an existing one, the new terminal will be /dev/tty1 and so on. Therefore, initially the three file descriptor all point to the file representing the terminal in which they are executed.

---

Redirect the standard output of a command to a file: `command >file`

Writing `command >file` is the same as writing `command 1>file`. The number 1 stands for stdout, which is the file descriptor number for standard output.

Redirect the standard error of a command to a file: `command 2>file`

Redirect both standard output and standard error to a file: `command &>file`

This is bash's shortcut for quickly redirecting both streams to the same destination. There are several ways to redirect both streams to the same destination. You can redirect each stream one after another: `command >file 2>&1`

This is a much more common way to redirect both streams to a file. First stdout is redirected to file, and then stderr is duplicated to be the same as stdout. So both streams end up pointing to file.

> Warning: This is not the same as writing: `command 2>&1 >file`. The order of redirects matters in bash! This command redirects only the standard output to the file. The stderr will still be printed to the terminal.

Discard the standard output of a command: `command > /dev/null`

Similarly, by combining the previous one-liners, we can discard both stdout and stderr by doing: `command >/dev/null 2>&1`

Or just simply: `command &>/dev/null`

Redirect the contents of a file to the stdin of a command: `grep [pattern] < [file]`

Redirect a bunch of text to the stdin of a command with the **here-document** redirection operator **<<EOF** ('EOF' can be any placeholder of your choice):
```
grep 'ciao' <<EOF  
hello
halo
ciao
EOF
```

This operator instructs bash to read the input from stdin until a line containing only 'EOF' is found. At this point bash passes the all the input read so far to the stdin of the command.

Redirect a single line of text to the stdin of a command: `grep ciao <<< $'hello\nhalo\nciao'`

> Note: `$'[text]'` allows to replace `\n` with a newline before passing the whole string to the command, `$"[text]"` won't do it.

> Note: This is equivalent to pipe the result of a command to the another one: `echo "some text here" | grep "a pattern"`

> Note: It's also possible to pass text instead of a file by means of 'process substitution': `find . | grep -f <(echo "somefile")`

Send stdout and stderr of one process to stdin of another process: `command1 |& command2`

This works on bash versions starting 4.0. As the new features of bash 4.0 aren't widely used, the old, and more portable way to do the same is:
`command1 2>&1 | command2`

Use `exec` to manipulate channels over ranges of commands:
```
exec < file # STDIN has become file
exec > file # STDOUT has become file
```

You may wish to save STDIN and STDOUT to restore them later:
```
exec 7<&0 # saved STDIN as channel 7
exec 6>&1 # saved STDOUT as channel 6
```

If you want to log all output from a segment of a script, you can combine these together:
```
exec 6>&1       # saved STDOUT as channel 6
exec > LOGFILE  # all further output goes to LOGFILE
# put commands here
exec 1>&6       # restores STDOUT; output to console again
```

A more detailed explanation [here](https://catonmat.net/bash-one-liners-explained-part-three).