## Manage system-wide environment profiles

In order to set a value to an existing **environment variable**, we use an assignment expression. For instance, to set the value of the "LANG" variable to "he_IL.UTF-8", we use the following command: `LANG=he_IL.UTF-8`

If we use an assignment expression for a variable that doesn't exist, the shell will create a **shell variable**, which is similar to an environment variable but does not influence the behaviour of other applications.

A shell variable can be exported to become an environment variable with the export command. To create the "EDITOR" environment variable and assign the value "nano" to it, you can do:
```
EDITOR=nano
export EDITOR
```

> Note: Use 'export -f FUN', to make a function available to all child processes.

The bash shell provides a shortcut for creating environment variables. The previous example could be performed with the following single command:
`export EDITOR=nano`

The printenv command prints the names and values of all currently defined environment variables: `printenv` 

> Note: This command is equivalent to 'export -p' and 'env', while 'set' prints all shell variables and functions.

To examine the value of a particular variable, we can specify its name to the printenv command: `printenv TERM`

Another way to achieve that is to use the dollar sign ($), as used in the following example: `echo $TERM`

The dollar sign can actually be used to combine the values of environment variables in many shell commands. For example, the following command can be used to list the contents of the "Desktop" directory within the current user's home directory: `ls $HOME/Desktop`

For the sake of completeness: If you want to print the names and values also of the non-exported shell variables, i.e. not only the environment variables, this is one way: `( set -o posix ; set ) | less`

The `source` command reads and executes commands from the file specified as its argument in the current shell environment. It is useful to load functions, variables, and configuration files into shell scripts.

### Session-wide environment variables

A suitable file for environment variable settings that should affect just a particular user (rather than the system as a whole) is ~/.profile.

Shell config files such as `~/.bashrc`, `~/.bash_profile`, and `~/.bash_login` are often suggested for setting environment variables. 

> Warning: While this may work on Bash shells for programs started from the shell, variables set in those files are not available by default to programs started from the graphical environment in a desktop session. 

### System-wide environment variables

A suitable file for environment variable settings that affect the system as a whole (rather than just a particular user) is `/etc/environment`. An alternative is to create a file for the purpose in the `/etc/profile.d` directory. 

The `/etc/environment` file is specifically meant for system-wide environment variable settings. It is not a script file, but rather consists of assignment expressions, one per line: `FOO=bar`

> Warning: Variable expansion does not work in /etc/environment. 

iles with the .sh extension in the `/etc/profile.d` directory get executed whenever a bash login shell is entered (e.g. when logging in from the console or over ssh), as well as by the DisplayManager when the desktop session loads.

You can for instance create the file /etc/profile.d/myenvvars.sh and set variables like this:
```
export JAVA_HOME=/usr/lib/jvm/jdk1.7.0
export PATH=$PATH:$JAVA_HOME/bin
```

While `/etc/profile` is often suggested for setting environment variables system-wide, it is a configuration file of the base-files package, so it's not appropriate to edit that file directly. Use a file in /etc/profile.d instead.

`/etc/default/locale` is specifically meant for system-wide locale environment variable settings. It's written to by the installer and when you use Language Support to set the language or regional formats system-wide. On a desktop system there is normally no reason to edit this file manually. 

The `/etc/security/pam_env.conf` file specifies the environment variables to be set, unset or modified by pam_env(8). When someone logs in, this file is read and the environment variables are set according.

> Note: Any variables added to these locations will not be reflected when invoking them with a sudo command, as sudo has a default policy of resetting the Environment and setting a secure path (this behavior is defined in /etc/sudoers). As a workaround, you can use "sudo su" that will provide a shell with root privileges but retaining any modified PATH variables. Alternatively you can setup sudo not to reset certain environment variables by adding some explicit environment settings to keep in /etc/sudoers: Defaults env_keep += "http_proxy SOMEOTHERVARIABLES ANOTHERVARIABLE ETC"