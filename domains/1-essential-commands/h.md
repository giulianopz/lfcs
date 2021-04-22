## Create, delete, copy, and move files and directories

Basic commands: `mkdir`, `rm`, `touch`, `cp` and `mv`.

Move back to your previous directory (`-` is converted to `$OLDPWD`): `cd -`

Create multiple files in a dir at once: `touch /path/to/dir/{a,f,g}.md`

Or, to create them with names in a linear sequence: `touch /path/to/dir/{a..g}.md`

To recursively remove a dir and its content without being prompted: `rm -rf /home/user/somedir`

To list directories themselves, not their contents: `ll -d /home/user/somedir`