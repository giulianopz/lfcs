# Configure PAM

PAM is a powerful suite of shared libraries used to dynamically authenticate a user to applications (or services) in a Linux system. It integrates multiple low-level authentication modules into a high-level API that provides dynamic authentication support for applications. 

To employ PAM, an application/program needs to be “PAM-aware“; it needs to have been written and compiled specifically to use PAM. To find out if a program is “PAM-aware” or not, check if it has been compiled with the PAM library using the *ldd* command:
```
sudo ldd /usr/sbin/sshd | grep libpam.so
> libpam.so.0 => /lib/x86_64-linux-gnu/libpam.so.0 (0x00007effddbe2000)
```

The main configuration file for PAM is */etc/pam.conf* and the */etc/pam.d/* directory contains the PAM configuration files for each PAM-aware application/services. 

The syntax for the main configuration file is as follows: the file is made up of a list of rules written on a single line (you can extend rules using the “\” escape character) and comments are preceded with “#” marks and extend to the next end of line.

The format of each rule is a space separated collection of tokens (the first three are case-insensitive):
`service type control-flag module module-arguments`; where:

- service: actual application name
- type: module type/context/interface
- control-flag: indicates the behavior of the PAM-API should the module fail to succeed in its authentication task
- module: the absolute filename or relative pathname of the PAM
- module-arguments: space separated list of tokens for controlling module behavior.

The syntax of each file in /etc/pam.d/ is similar to that of the main file and is made up of lines of the following form:
`type control-flag module module-arguments`

A module is associated to one these management group types:

- account: provide services for account verification
- authentication: authenticate a user and set up user credentials
- password: are responsible for updating user passwords and work together with authentication modules
- session: manage actions performed at the beginning of a session and end of a session.

PAM loadable object files (i.e. the modules) are to be located in the following directory: /lib/security/ or /lib64/security depending on the architecture.

The supported control-flags are:

- requisite: failure instantly returns control to the application indicating the nature of the first module failure
- required: all these modules are required to succeed for libpam to return success to the application
- sufficient: given that all preceding modules have succeeded, the success of this module leads to an immediate and successful return to the application (failure of this module is ignored)
- optional: the success or failure of this module is generally not recorded.

In addition to the above keywords, there are two other valid control flags:

- include: include all lines of given type from the configuration file specified as an argument to this control
- substack: this differs from the previous one in that evaluation of the done and die actions in a substack does not cause skipping the rest of the complete module stack, but only of the substack..

Example: how to use PAM to disable root user access to a system via SSH and login.

We can use the */lib/security/pam_listfile.so* module which offers great flexibility in limiting the privileges of specific accounts. Open and edit the file for the target service in the */etc/pam.d/* directory as shown.
```
sudo vim /etc/pam.d/sshd
sudo vim /etc/pam.d/login
```

Add this rule in both files:
```
auth    required       pam_listfile.so \
    onerr=succeed  item=user  sense=deny  file=/etc/ssh/deniedusers
```

Explaining the tokens in the above rule:

- auth: is the module type (or context)
- required: is a control-flag that means if the module is used, it must pass or the overall result will be fail, regardless of the status of other modules
- pam_listfile.so: is a module which provides a way to deny or allow services based on an arbitrary file
- onerr=succeed: module argument
- item=user: module argument which specifies what is listed in the file and should be checked for
- sense=deny: module argument which specifies action to take if found in file, if the item is NOT found in the file, then the opposite action is requested
- file=/etc/ssh/deniedusers: module argument which specifies file containing one item per line.

Next, we need to create the file /etc/ssh/deniedusers and add the name root in it:
`sudo vim /etc/ssh/deniedusers`

Save the changes and close the file, then set the required permissions on it:
`sudo chmod 600 /etc/ssh/deniedusers`

From now on, the above rule will tell PAM to consult the /etc/ssh/deniedusers file and deny access to the SSH and login services for any listed user.

Another good example of PAM configuration is showed in **pam_tally2** module man page: it explains how to configure login to lock the account after 4 failed logins.