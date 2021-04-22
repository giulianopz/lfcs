## Boot or change system into different operating modes

On modern systemd-based systems, **targets** are special unit files that describe a system state or synchronization point. Like other units, the files that define targets can be identified by their suffix, which in this case is `.target`. Targets do not do much themselves, but are instead used to group other units together. These can be used in order to bring the system to certain states, much like other init systems use **runlevels**.

To find the default target for your system, type: `systemctl get-default`

If you wish to set a different default target, you can use the set-default: `sudo systemctl set-default graphical.target`

You can get a list of the available targets on your system by typing: `systemctl list-unit-files --type=target`

It is possible to start all of the units associated with a target and stop all units that are not part of the dependency tree. This is similar to changing the runlevel in other init systems: `sudo systemctl isolate multi-user.target`

You may wish to take a look at the dependencies of the target you are isolating before performing this procedure to ensure that you are not stopping vital services: `systemctl list-dependencies multi-user.target`

There are targets defined for important events like powering off or rebooting. However, systemctl also has some shortcuts that add a bit of additional functionality.

For instance, to put the system into **rescue** (i.e. **single-user**) mode, you can just use the rescue command instead of isolate rescue.target: `sudo systemctl rescue`

This will provide the additional functionality of alerting all logged in users about the event.

To change target at boot time:

- during boot press ESC/F2 right after the BIOS logo disappears
- the grub menu prompt will be showed
- choose the entry corrisponding to your system
- type 'e' to edit the boot loader configuration
- navigate to your prefered Linux kernel line and append either `rescue` or `systemd.unit=emergency.target`

> Note: The changes are not persistent.

> Note: In this modality disk is mounted read only, to remount it read/write, after boot execute: `mount -o remount,rw /`.

- then press either Ctrl-x or F10 to boot with the modified entry and the system will enter the rescue mode. 

> Note: The **rescue mode** is equivalent to single user mode in Linux distributions that uses SysV as the default service manager. In rescue mode, all local filesystems will be mounted, only some important services will be started. However, no normal services (E.g network services) won't be started. The rescue mode is helpful in situations where the system can't boot normally. Also, we can perform some important rescue operations, such as reset root password, in rescue mode. In contrast to the rescue mode, nothing is started in the **emergency mode**. No services are started, no mount points are mounted, no sockets are established, nothing. All you will have is just a raw shell. Emergency mode is suitable for debugging purposes.

For a "visual" guidance on the topic, look [here](https://ostechnix.com/how-to-boot-into-rescue-mode-or-emergency-mode-in-ubuntu-18-04/).