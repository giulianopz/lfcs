## Change kernel runtime parameters, persistent and non-persistent

The latest specification of the Filesystem Hierarchy Standard indicates that /proc represents the default method for handling process and system information as well as other kernel and memory information. Particularly, `/proc/sys` is where you can find all the information about devices, drivers, and some kernel features.

If you want to view the complete list of Kernel parameters, just type:
```
sysctl -a 
```

It's possible to view the value of a particular Linux kernel parameter using either `sysctl` followed by the name of the parameter or reading the associated file:
```
sysctl dev.cdrom.autoclose
cat /proc/sys/dev/cdrom/autoclose
sysctl net.ipv4.ip_forward
cat /proc/sys/net/ipv4/ip_forward
```

To set the value for a kernel parameter we can use `sysctl`, but using the `-w` option and followed by the parameter’s name, the equal sign, and the desired value.

Another method consists of using echo to overwrite the file associated with the parameter. In other words, the following methods are equivalent to disable the packet forwarding functionality in our system (which, by the way, should be the default value when a box is not supposed to pass traffic between networks):
```
echo 0 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=0
```

It is important to note that kernel parameters that are set using sysctl will only be enforced during the current session and will disappear when the system is rebooted. To set these values permanently, edit /etc/sysctl.conf with the desired values. For example, to disable packet forwarding in /etc/sysctl.conf make sure this line appears in the file:
`net.ipv4.ip_forward=0`

Then run following command to apply the changes to the running configuration.
`sysctl -p`

Other examples of important kernel runtime parameters are:

- `fs.file-max` specifies the maximum number of file handles the kernel can allocate for the system. Depending on the intended use of your system (web / database / file server, to name a few examples), you may want to change this value to meet the system’s needs. Otherwise, you will receive a “Too many open files” error message at best, and may prevent the operating system to boot at the worst. If due to an innocent mistake you find yourself in this last situation, boot in single user mode and edit /etc/sysctl.conf as instructed earlier. To set the same restriction on a per-user basis, use `ulimit`.

- `kernel.sysrq` is used to enable the SysRq key in your keyboard (also known as the print screen key) so as to allow certain key combinations to invoke emergency actions when the system has become unresponsive. The default value (16) indicates that the system will honor the Alt+SysRq+key combination and perform the actions listed in the sysrq.c documentation found in kernel.org (where key is one letter in the b-z range). For example, Alt+SysRq+b will reboot the system forcefully (use this as a last resort if your server is unresponsive).

> Warning: Do not attempt to press this key combination on a virtual machine because it may force your host system to reboot!

- when set to 1, `net.ipv4.icmp_echo_ignore_all` will ignore ping requests and drop them at the kernel level.

A better and easier way to set individual runtime parameters is using .conf files inside /etc/sysctl.d, grouping them by categories.

For example, instead of setting net.ipv4.ip_forward=0 and net.ipv4.icmp_echo_ignore_all=1 in /etc/sysctl.conf, we can create a new file named net.conf inside /etc/sysctl.d:
```
echo "net.ipv4.ip_forward=0" > /etc/sysctl.d/net.conf
echo "net.ipv4.icmp_echo_ignore_all=1" >> /etc/sysctl.d/net.conf
```

Again, type `sysctl -p ` toreload permanent configuration. Alternatively, reboot the system.