## Implement packet filtering

The Linux kernel includes the *Netfilter* subsystem, which is used to manipulate or decide the fate of network traffic headed into or through your server. All modern Linux firewall solutions use this system for packet filtering.

The kernel’s packet filtering system would be of little use to administrators without a userspace interface to manage it. This is the purpose of *iptables*: when a packet reaches your server, it will be handed off to the Netfilter subsystem for acceptance, manipulation, or rejection based on the rules supplied to it from userspace via iptables. Thus, iptables is all you need to manage your firewall, if you’re familiar with it, but many frontends are available to simplify the task.

Starting with CentOS 7, *firewall-d* replaced iptables as the default firewall management tool. The default firewall configuration tool for Ubuntu is *ufw*. By default, ufw is set to deny all incoming connections and allow all outgoing connections. This means anyone trying to reach your server would not be able to connect, while any application within the server would be able to reach the outside world.

Basic ufw management: `sudo ufw [enable|disable|reset|status]`

To open a port (SSH in this example): `sudo ufw allow 22`

> Note: If the port you want to open or close is defined in `/etc/services`, you can use the port name instead of the number. In the above examples, replace `22` with `ssh`.

Rules can also be added using a numbered format: `sudo ufw insert 1 allow 80`

Similarly, to close an opened port: `sudo ufw deny 22`

To remove a rule, use delete followed by the rule: `sudo ufw delete deny 22`

It is also possible to allow access from specific hosts or networks to a port. The following example allows SSH access from host 192.168.0.2 to any IP address on this host: `sudo ufw allow proto tcp from 192.168.0.2 to any port 22`

Replace `192.168.0.2` with `192.168.0.0/24` to allow SSH access from the entire subnet.

Adding the `–dry-run` option to a ufw command will output the resulting rules, but not apply them. For example, the following is what would be applied if opening the HTTP port: `sudo ufw --dry-run allow http`

For more verbose status information use: `sudo ufw status verbose`

To view the numbered format: `sudo ufw status numbered`

Applications that open ports can include an ufw profile, which details the ports needed for the application to function properly. The profiles are kept in `/etc/ufw/applications.d`, and can be edited if the default ports have been changed.

To view which applications have installed a profile, enter the following in a terminal: `sudo ufw app list`

Similar to allowing traffic to a port, using an application profile is accomplished by entering: `sudo ufw allow Samba`

An extended syntax is available as well: `ufw allow from 192.168.0.0/24 to any app Samba`

Replace `Samba` and `192.168.0.0/24` with the application profile you are using and the IP range for your network. There is no need to specify the protocol for the application, because that information is detailed in the profile. Also, note that the app name replaces the port number.

To view details about which ports, protocols, etc., are defined for an application, enter: `sudo ufw app info Samba`