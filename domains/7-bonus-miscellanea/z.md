## Tips & tricks

1. When entering a password in a terminal, if you realize there's a typo, type `ctrl + u` to undo the password just entered and enter it again.

2. Escaping strings in bash using `!:q` (TODO)

3. reverse search (TODO)

4. Hiding passwords in scripts (TODO)

5. Create a simple chat with `netcat` (TODO)

6. Bash allows you to ignore history entries that begin with a space if you set the `HISTCONTROL` variable to `ignorespace`. Type a space before a command before running it in the bash shell and the command will run normally, but won’t appear in your history if you have this variable enabled. This allows you to keep your history a bit cleaner, choosing to run commands without them appearing in your history. Bash also allows you to ignore duplicate commands that can clutter your history. To do so, set `HISTCONTROL` to `ignoredups`. To use both the ignorespace and ignoredups feature, set the `HISTCONTROL` variable to `ignoreboth`.