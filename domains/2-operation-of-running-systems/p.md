## List and identify SELinux/AppArmor file and process contexts

### 1. SELinux

Security-Enhanced Linux (SELinux) is a Linux kernel security module that provides a mechanism for supporting access control security policies, including mandatory access controls, which restricts ability of processes to access or perform other operations on system objects (files, dirs, network ports, etc). Mostly used in CentOS.

Modes: **enforcing**, **permissive** (i.e. logging mode), **disabled**.

To install it on Ubuntu:
```
sudo apt install policycoreutils selinux-utils selinux-basics
sudo selinux-activate
sudo selinux-config-enforcing
sudo reboot                       
# The relabelling will be triggered after you reboot your system. When finished the system will reboot one more time automatically
sestatus
```

To disable SELinux open up the /etc/selinux/config configuration file and change the following line:
```
#SELINUX=enforcing
SELINUX=disabled
```

Another way of permanently disabling the SELinux is to edit the kernel boot parameters. Edit the grub configuration at boot and add the `selinux=0` option to the kernel options.

Get current mode: `getenforce`

Set current mode (non-persistent): `setenforce [Enforcing|Permissive|1|0]`

> Note: `1` is for enforcing, `0` is for permissive mode.

To set a mode persistently, manually edit `/etc/selinux/config` and set the `SELINUX` variable to either `enforcing`, `permissive`, or `disabled` in order to achieve persistence across reboots.

To get SELinux man pages:
```
yum install selinux-policy-devel
mandb                                                               # update man pages database
apropos selinux                                                     # see man pages
```

See security context for file/dir and processes:
```
ls -lZ <dir>
> drwxrwxr-x. vagrant vagrant unconfined_u:object_r:user_home_t:s0 cheat
ps auZ
```

Check audit logs for SELinux related files:
```
cat /var/log/audit/audit.log | grep AVC | tail -f
```

> Note: SELinux log messages include the word “AVC” so that they might be easily identified from other messages.

Main commands: `semanage` and `sepolicy`.

Get SELinux policy:
```
sepolicy -a                                                         # see all policies with descriptions
getsebool -a                                                        # see state of all policies
```

Change file SELinux security context: 
```
chcon -t etc_t somefile                                             # set type TYPE in the target security context 
chcon --reference RFILE file                                        # use RFILE's security context rather than specifying a CONTEXT value  
```

Use `getselbool` and `setselbool` to configure SEL policy behaviour at runtime without rewriting the policy itself.

Two classic cases where we will most likely have to deal with SELinux are:

- changing the default port where a daemon listens on
- setting the DocumentRoot directive for a virtual host outside of /var/www/html.

If you tried to change the default ssh port to 9999, taking a look at /var/log/audit/audit.log, you would see that sshd can be prevented from starting on port 9999 by SELinux because that is a reserved port for the JBoss Management service.To modify the existing SELinux rule and assign that port to SSH instead:
```
semanage port -l | grep ssh                                         # find ssh policy
semanage port -m -t ssh_port_t -p tcp 9999                          # -m for modiy, -a for add, -d for delete
```

If you need to set up a Apache virtual host using a directory other than /var/www/html as DocumentRoot. Apache will refuse to serve the content because the index.html has been labeled with the `default_t` SELinux type, which Apache can’t access. To add apache read-only access to dir:
```
semanage fcontext -a -t httpd_sys_content_t "/custom_dir(/.*)?"     #  -a add, -t type
restorecon -R -v /custom_dir                                        # remember to run restorecon after you set the file context
```

### 2. AppArmor

AppArmor (AA) is a Linux kernel security module that allows the system administrator to restrict programs' capabilities with per-program profiles. Profiles can allow capabilities like network access, raw socket access, and the permission to read, write, or execute files on matching paths. AppArmor is installed and loaded by default in Ubuntu.

The optional apparmor-utils package contains command line utilities that you can use to change the AppArmor execution mode, find the status of a profile, create new profiles, etc: `sudo apt-get install apparmor-utils`

Programs can run in:

- encforce mode (default) 
- complain mode.

The /etc/apparmor.d directory is where the AppArmor profiles are located. It can be used to manipulate the mode of all profiles. The files are named after the full path to the executable they profile replacing the “/” with “.”. For example /etc/apparmor.d/bin.ping is the AppArmor profile for the /bin/ping command. There are two main type of rules used in profiles:

- path entries: detail which files an application can access in the file system
- capability entries: determine what privileges a confined process is allowed to use.


It comes with a list of utilities whose name always starts with "aa-".

Find out if AppArmor is enabled (returns `Y` if true):
```
cat /sys/module/apparmor/parameters/enabled
```

To view the current status of AppArmor profiles: `sudo apparmor_status`

Put a profile in complain mode: `sudo aa-complain </path/to/bin>`

Put a profile in enforce mode: `sudo aa-enforce </path/to/bin>`

Enter the following to place all profiles into complain mode: `sudo aa-complain /etc/apparmor.d/*`

You can generate a profile for a program while it is running, AA will scan /var/log/syslog for errors:
```
aa-genprof <executable>
# once done, reload the policies
sudo systemctl reload apparmor
```

When the program is misbehaving, audit messages are sent to the log files. The program aa-logprof can be used to scan log files for AppArmor audit messages, review them and update the profiles. From a terminal: `sudo aa-logprof`

List all loaded AppArmor profiles for applications and processes and detail their status (enforced, complain, unconfined):
```
sudo aa-status
``` 

List running executables which are currently confined by an AppArmor profile:
```
ps auxZ | grep -v '^unconfined'
```

List of processes with tcp or udp ports that do not have AppArmor profiles loaded:
```
sudo aa-unconfined
```

To reload a currently loaded profile after modifying it to have the changes take effect:
`sudo apparmor_parser -r /etc/apparmor.d/profile.name`

To disable one profile:
```
sudo ln -s /etc/apparmor.d/profile.name /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/profile.name
```

To re-enable a disabled profile remove the symbolic link to the profile in /etc/apparmor.d/disable/, then load the profile using the `-a` option:
```
sudo rm /etc/apparmor.d/disable/profile.name
cat /etc/apparmor.d/profile.name | sudo apparmor_parser -a
```

The AppArmor Linux Security Modules (LSM) must be enabled from the linux kernel command line in the bootloader:
```
sudo mkdir -p /etc/default/grub.d
echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT apparmor=1 security=apparmor"' | sudo tee /etc/default/grub.d/apparmor.cfg
sudo update-grub
sudo reboot
```

If AppArmor must be disabled (e.g. to use SELinux instead), users can:
`sudo systemctl disable --now apparmor`

To disable AppArmor at the kernel level:
```
sudo mkdir -p /etc/default/grub.d
echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT apparmor=0"' | sudo tee /etc/default/grub.d/apparmor.cfg
sudo update-grub
sudo reboot
```

AppArmor is enabled by default. If you used the above procedures, to disable it, you can re-enable it by:

- ensuring that AppArmor is not disabled in */etc/default/grub* if using Ubuntu kernels, or if using non-Ubuntu kernels, that /etc/default/grub has *apparmor=1* and *security=apparmor*
- ensuring that the *apparmor* package is installed
- enabling the systemd unit: `sudo systemctl enable --now apparmor`