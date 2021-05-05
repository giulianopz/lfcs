## Configure networking and hostname resolution statically or dynamically

### Networking

Networks consist of two or more devices, such as computer systems, printers, and related equipment which are connected by either physical cabling or wireless links for the purpose of sharing and distributing information among the connected devices.

The two protocol components of TCP/IP deal with different aspects of computer networking. Internet Protocol, the “IP” of TCP/IP is a connectionless protocol which deals only with network packet routing using the IP Datagram as the basic unit of networking information. The IP Datagram consists of a header followed by a message. The Transmission Control Protocol is the “TCP” of TCP/IP and enables network hosts to establish connections which may be used to exchange data streams. TCP also guarantees that the data between connections is delivered and that it arrives at one network host in the same order as sent from another network host.

The TCP/IP protocol configuration consists of several elements which must be set by editing the appropriate configuration files, or deploying solutions such as the Dynamic Host Configuration Protocol (DHCP) server which in turn, can be configured to provide the proper TCP/IP configuration settings to network clients automatically. These configuration values must be set correctly in order to facilitate the proper network operation of your Ubuntu system.

The common configuration elements of TCP/IP and their purposes are as follows:

- **IP address**: The IP address is a unique identifying string expressed as four decimal numbers ranging from zero (0) to two-hundred and fifty-five (255), separated by periods, with each of the four numbers representing eight (8) bits of the address for a total length of thirty-two (32) bits for the whole address. This format is called *dotted quad notation*.

- **Netmask**: The Subnet Mask (or simply, netmask) is a local bit mask, or set of flags which separate the portions of an IP address significant to the network from the bits significant to the subnetwork. For example, in a Class C network, the standard netmask is 255.255.255.0 which masks the first three bytes of the IPaddress and allows the last byte of the IP address to remain available for specifying hosts on the subnetwork.

- **Network Address**: The Network Address represents the bytes comprising the network portion of an IP address. For example, the host 12.128.1.2 in a Class A network would use 12.0.0.0 as the network address, where twelve (12) represents the first byte of the IP address, (the network part) and zeroes (0) in all of the remaining three bytes to represent the potential host values. A network host using the private IP address 192.168.1.100 would in turn use a Network Address of 192.168.1.0, which specifies the first three bytes of the Class C 192.168.1 network and a zero (0) for all the possible hosts on the network.

- **Broadcast Address**: The Broadcast Address is an IP address which allows network data to be sent simultaneously to all hosts on a given subnetwork rather than specifying a particular host. The standard general broadcast address for IP networks is 255.255.255.255, but this broadcast address cannot be used to send a broadcast message to every host on the Internet because routers block it. A more appropriate broadcast address is set to match a specific subnetwork. Forexample, on the private Class C IP network, 192.168.1.0, the broadcast address is 192.168.1.255. Broadcast messages are typically produced by network protocols such as the Address Resolution Protocol (ARP) and the Routing Information Protocol (RIP).

- **Gateway Address**: A Gateway Address is the IP address through which a particular network, or host on a network, may be reached. If one network host wishes to communicate with another network host, and that host is not located on the same network, then a gateway must be used. In many cases, the Gateway Address will be that of a router on the same network, which will in turn pass traffic on to other networks or hosts, such as Internet hosts. The value of the Gateway Address setting must be correct, or your system will not be able to reach any hosts beyond those on the same network.

- **Nameserver Address**: Nameserver Addresses represent the IP addresses of Domain Name Service (DNS) systems, which resolve network hostnames into IP addresses. There are three levels of Nameserver Addresses, which may be specified in order of precedence: The Primary Nameserver, the Secondary Nameserver, and the Tertiary Nameserver. In order for your system to be able to resolve network hostnames into their corresponding IP addresses, you must specify valid Nameserver Addresses which you are authorized to use in your system’s TCP/IP configuration. In many cases these addresses can and will be provided by your network service provider,but many free and publicly accessible nameservers are available for use, such as the Level3 (Verizon) servers with IP addresses from 4.2.2.1 to 4.2.2.6.
    
> Tip: The IP address, Netmask, Network Address, Broadcast Address, Gateway Address, and Nameserver Addresses are typically specified via the appropriate directives in the file /etc/network/interfaces (before Ubuntu 18.04, see below). For more information, view the system manual page for interfaces: `man interfaces`

### Netplan

Ubuntu 18.04 (LTS) has switched from **ifupdown** to **Netplan** for configuring network interfaces. Netplan is based on YAML config files that makes configuration process very simple. Netplan has replaced the old configuration file` /etc/network/interface`s that was previously used for configuring network interfaces in Ubuntu.

During early boot, the Netplan *networkd renderer* runs, reads /{lib,etc,run}/netplan/*.yaml and writes configuration to /run to hand off control of devices to the specified networking daemon:

- configured devices get handled by` systemd-network`d by default, unless explicitly marked as managed by a specific renderer (**NetworkManager**)
- devices not covered by the network config do not get touched at all.

If you are not on an Ubuntu Server, but on Desktop, chances are that the network is driven by the NetworkManager.

Netplan supports both networkd and NetworkManager as backends. You can specify which network backend should be used to configure particular devices by using the renderer key. You can also delegate all configuration of the network to NetworkManager itself by specifying only the renderer key:
```
network:
    version: 2
    renderer: NetworkManager
```

---

### Ethernet Interfaces

Ethernet interfaces are identified by the system using predictable network interface names. These names can appear as *eno1* or *enp0s25*. However, in some cases an interface may still use the kernel *eth#* style of naming.

To quickly identify all available Ethernet interfaces, you can use the `ip` command as shown below:
```
ip a
>1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
>    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>    inet 127.0.0.1/8 scope host lo
>       valid_lft forever preferred_lft forever
>    inet6 ::1/128 scope host
>       valid_lft forever preferred_lft forever
>2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
>    link/ether 00:16:3e:e2:52:42 brd ff:ff:ff:ff:ff:ff link-netnsid 0
>    inet 10.102.66.200/24 brd 10.102.66.255 scope global dynamic eth0
>       valid_lft 3257sec preferred_lft 3257sec
>    inet6 fe80::216:3eff:fee2:5242/64 scope link
>       valid_lft forever preferred_lft forever
```

Another application that can help identify all network interfaces available to your system is the `lshw` command. This command provides greater details around the hardware capabilities of specific adapters. In the example below, `lshw` shows a single Ethernet interface with the logical name of `eth4` along with bus information, driver details and all supported capabilities:
```
sudo lshw -class network
  *-network
       description: Ethernet interface
       product: MT26448 [ConnectX EN 10GigE, PCIe 2.0 5GT/s]
       vendor: Mellanox Technologies
       physical id: 0
       bus info: pci@0004:01:00.0
       logical name: eth4
       version: b0
       serial: e4:1d:2d:67:83:56
       slot: U78CB.001.WZS09KB-P1-C6-T1
       size: 10Gbit/s
       capacity: 10Gbit/s
       width: 64 bits
       clock: 33MHz
       capabilities: pm vpd msix pciexpress bus_master cap_list ethernet physical fibre 10000bt-fd
       configuration: autonegotiation=off broadcast=yes driver=mlx4_en driverversion=4.0-0 duplex=full firmware=2.9.1326 ip=192.168.1.1 latency=0 link=yes multicast=yes port=fibre speed=10Gbit/s
       resources: iomemory:24000-23fff irq:481 memory:3fe200000000-3fe2000fffff memory:240000000000-240007ffffff
```

### Ethernet Interface Logical Names

Interface logical names can also be configured via a netplan configuration. If you would like control which interface receives a particular logical name use the `match` and `set-name` keys. The `match` key is used to find an adapter based on some criteria like MAC address, driver, etc. Then the `set-name` key can be used to change the device to the desired logial name:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    eth_lan0:
      dhcp4: true
      match:
        macaddress: 00:11:22:33:44:55
      set-name: eth_lan0
```

### Ethernet Interface Settings

`ethtool` is a program that displays and changes ethernet card settings such as auto-negotiation, port speed, duplex mode, and Wake-on-LAN. The following is an example of how to view supported features and configured settings of an ethernet interface.
```
sudo ethtool eth4
>Settings for eth4:
>    Supported ports: [ FIBRE ]
>    Supported link modes:   10000baseT/Full
>    Supported pause frame use: No
>    Supports auto-negotiation: No
>    Supported FEC modes: Not reported
>    Advertised link modes:  10000baseT/Full
>    Advertised pause frame use: No
>    Advertised auto-negotiation: No
>    Advertised FEC modes: Not reported
>    Speed: 10000Mb/s
>    Duplex: Full
>    Port: FIBRE
>    PHYAD: 0
>    Transceiver: internal
>    Auto-negotiation: off
>    Supports Wake-on: d
>    Wake-on: d
>    Current message level: 0x00000014 (20)
>                   link ifdown
>    Link detected: yes
```

### Temporary IP Address Assignment

For temporary network configurations, you can use the ip command which is also found on most other GNU/Linux operating systems. The ip command allows you to configure settings which take effect immediately, however they are not persistent and will be lost after a reboot.

To temporarily configure an IP address, you can use the ip command in the following manner. Modify the IP address and subnet mask to match your network requirements:
`sudo ip addr add 10.102.66.200/24 dev enp0s25`

The ip can then be used to set the **link** (i.e. network device) up or down:
```
ip link set dev enp0s25 up
ip link set dev enp0s25 down
```

To verify the IP address configuration of enp0s25, you can use the ip command in the following manner:
```
ip address show dev enp0s25
>10: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
>    link/ether 00:16:3e:e2:52:42 brd ff:ff:ff:ff:ff:ff link-netnsid 0
>    inet 10.102.66.200/24 brd 10.102.66.255 scope global dynamic eth0
>       valid_lft 2857sec preferred_lft 2857sec
>    inet6 fe80::216:3eff:fee2:5242/64 scope link
>       valid_lft forever preferred_lft forever6
```

To configure a default gateway, you can use the ip command in the following manner. Modify the default gateway address to match your network requirements:
`sudo ip route add default via 10.102.66.1`

To verify your default gateway configuration, you can use the ip command in the following manner:
```
ip route show
>default via 10.102.66.1 dev eth0 proto dhcp src 10.102.66.200 metric 100
>10.102.66.0/24 dev eth0 proto kernel scope link src 10.102.66.200
>10.102.66.1 dev eth0 proto dhcp scope link src 10.102.66.200 metric 100 
```

If you require DNS for your temporary network configuration, you can add DNS server IP addresses in the file /etc/resolv.conf. In general, editing `/etc/resolv.conf` directly is not recommanded, but this is a temporary and non-persistent configuration. The example below shows how to enter two DNS servers to `/etc/resolv.conf`, which should be changed to servers appropriate for your network:
```
nameserver 8.8.8.8
nameserver 8.8.4.4
```

If you no longer need this configuration and wish to purge all IP configuration from an interface, you can use the ip command with the flush option as shown below.
`ip addr flush eth0`

> Note: Flushing the IP configuration using the ip command does not clear the contents of /etc/resolv.conf. You must remove or modify those entries manually, or reboot which should also cause /etc/resolv.conf, which is a symlink to /run/systemd/resolve/stub-resolv.conf, to be re-written.

### Dynamic IP Address Assignment (DHCP Client)

To configure your server to use DHCP for dynamic address assignment, create a netplan configuration in the file `/etc/netplan/99_config.yaml`. The example below assumes you are configuring your first ethernet interface identified as `enp3s0`:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp3s0:
      dhcp4: true
```

The configuration can then be applied using the netplan command: `sudo netplan apply`

In case you see any error, try debugging to investigate the problem. To run debug, use the following command as sudo: `sudo netplan –d apply`

Once all the configurations are successfully applied, restart the Network-Manager service by running the following command: `sudo systemctl restart network-manager`

If you are using a Ubuntu Server, use the following command instead: `sudo systemctl restart system-networkd`

### Static IP Address Assignment

To configure your system to use static address assignment, create a netplan configuration in the file `/etc/netplan/99_config.yaml`. The example below assumes you are configuring your first ethernet interface identified as `eth0`. Change the addresses, gateway4, and nameservers values to meet the requirements of your network:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 10.10.10.2/24
      gateway4: 10.10.10.1
      nameservers:
          search: [mydomain, otherdomain]
          addresses: [10.10.10.1, 1.1.1.1]
```

The configuration can then be applied using the netplan command: `sudo netplan apply`

[Here](https://netplan.io/examples/) is a a collection of example netplan configurations for common scenarios.

---

### Name Resolution

Name resolution as it relates to IP networking is the process of mapping IP addresses to hostnames, making it easier to identify resources on a network. The following section will explain how to properly configure your system for name resolution using DNS and static hostname records.

### DNS Client Configuration

Traditionally, the file /etc/resolv.conf was a static configuration file that rarely needed to be changed or automatically changed via DCHP client hooks. systemd-resolved handles name server configuration, and it should be interacted with through the `systemd-resolve` command. Netplan configures systemd-resolved to generate a list of nameservers and domains to put in /etc/resolv.conf, which is a symlink:
`/etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf`

To configure the resolver, add the IP addresses of the nameservers that are appropriate for your network to the netplan configuration file. You can also add a list of search domains (DNS suffixes), which are used when a non-fully qualified hostname is given. The resulting file might look like the following:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s25:
      addresses:
        - 192.168.0.100/24
      gateway4: 192.168.0.1
      nameservers:
          search: [mydomain, otherdomain]
          addresses: [1.1.1.1, 8.8.8.8, 4.4.4.4]
```

The `search` option can also be used with multiple domain names so that DNS queries will be appended in the order in which they are entered. For example, your network may have multiple sub-domains to search; a parent domain of example.com, and two sub-domains, sales.example.com and dev.example.com.

If you have multiple domains you wish to search, your configuration might look like the following:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s25:
      addresses:
        - 192.168.0.100/24
      gateway4: 192.168.0.1
      nameservers:
          search: [example.com, sales.example.com, dev.example.com]
          addresses: [1.1.1.1, 8.8.8.8, 4.4.4.4]
```

If you try to ping a host with the name of server1, your system will automatically query DNS for its Fully Qualified Domain Name (FQDN) in the following order:
```
server1.example.com
server1.sales.example.com
server1.dev.example.com
```

If no matches are found, the DNS server will provide a result of notfound and the DNS query will fail.

---

If you are using NetworkManager in a desktop version of Ubuntu, editing /etc/netplan/*.yaml could not be enough.

If your current DNS server still points to your router (i.e. 192.168.1.1), there are at least two ways to solve this problem:

1. You may configure these settings using the already mentioned GUI:

  a. Choose a connection (from the *Wired* or *Wireless* tab) and click *Edit*
  b. Click on the IPv4 Settings tab
  c. Choose **Automatic (DHCP) addresses only** instead of just *Automatic (DHCP)*
  d. Enter the DNS servers in the *DNS servers* field, separated by spaces (e.g. 208.67.222.222 for OpenDNS)
  e. Click on *Apply*.

> Note: 'Automatic (DHCP) addresses only' means that the network you are connecting to uses a DHCP server to assign IP addresses but you want to assign DNS servers manually.

> Note: NetworkManager saves these settings in /etc/NetworkManager/system-connections/[name-of-your-connection].

2) or, if your DNS settigs are messed up by multiple programs trying to update it, you can use `resolvconf`:
```
sudo apt install resolvconf 
sudo systemctl enable --now resolvconf.service
```

Then, edit /etc/resolvconf/resolv.conf.d/head and insert the nameservers youu want as:
```
nameserver 8.8.8.8 
nameserver 8.8.4.4
```

Finally, to update /etc/resolv.conf by typing: `sudo resolvconf -u`

The /etc/resolv.conf file will be replaced by a symbolic link to /etc/resolvconf/run/resolv.conf, so that the system resolver will use this file instead of the previously symlinked /run/systemd/resolve/stub-resolv.conf. 

### Static Hostnames

Static hostnames are locally defined hostname-to-IP mappings located in the file `/etc/hosts`. Entries in the hosts file will have precedence over DNS by default. This means that if your system tries to resolve a hostname and it matches an entry in /etc/hosts, it will not attempt to look up the record in DNS. In some configurations, especially when Internet access is not required, servers that communicate with a limited number of resources can be conveniently set to use static hostnames instead of DNS.

The following is an example of a hosts file where a number of local servers have been identified by simple hostnames, aliases and their equivalent Fully Qualified Domain Names (FQDNs):
```
127.0.0.1   localhost
127.0.1.1   ubuntu-server
10.0.0.11   server1 server1.example.com vpn
10.0.0.12   server2 server2.example.com mail
10.0.0.13   server3 server3.example.com www
10.0.0.14   server4 server4.example.com file
```

> Note: In the above example, notice that each of the servers have been given aliases in addition to their proper names and FQDN’s. Server1 has been mapped to the name vpn, server2 is referred to as mail, server3 as www, and server4 as file.

To block ads and tracking sites, append to /etc/hosts the MVPS HOSTS [file](https://winhelp2002.mvps.org/hosts.txt).

### Name Service Switch Configuration

The order in which your system selects a method of resolving hostnames to IP addresses is controlled by the *Name Service Switch* (**NSS**) configuration file `/etc/nsswitch.conf`. As mentioned in the previous section, typically static hostnames defined in the systems /etc/hosts file have precedence over names resolved from DNS. The following is an example of the line responsible for this order of hostname lookups in the file /etc/nsswitch.conf:
`hosts:          files mdns4_minimal [NOTFOUND=return] dns mdns4`

The entries listed are:

- `files` first tries to resolve static hostnames located in /etc/hosts

- `mdns4_minimal` attempts to resolve the name using Multicast DNS

- `[NOTFOUND=return]` means that any response of notfound by the preceding mdns4_minimal process should be treated as authoritative and that the system should not try to continue hunting for an answer

- `dns` represents a legacy unicast DNS query

- `mdns4` represents a Multicast DNS query.

To modify the order of the above mentioned name resolution methods, you can simply change the `hosts:` string to the value of your choosing. For example, if you prefer to use legacy Unicast DNS versus Multicast DNS, you can change the string in /etc/nsswitch.conf as shown below:
`hosts:          files dns [NOTFOUND=return] mdns4_minimal mdns4`

### Bridging

Bridging multiple interfaces is a more advanced configuration, but is very useful in multiple scenarios. One scenario is setting up a bridge with multiple network interfaces, then using a firewall to filter traffic between two network segments. Another scenario is using bridge on a system with one interface to allow virtual machines direct access to the outside network. The following example covers the latter scenario.

Configure the bridge by editing your netplan configuration found in /etc/netplan/:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp3s0:
      dhcp4: no
  bridges:
    br0:
      dhcp4: yes
      interfaces:
        - enp3s0
```

> Note: Enter the appropriate values for your physical interface and network.

Now apply the configuration to enable the bridge: `sudo netplan apply`

The new bridge interface should now be up and running. The `brctl` command provides useful information about the state of the bridge, controls which interfaces are part of the bridge, etc.

---

Resolve a hostname to an ip address: `dig +short google.com`

Resolve a hostname with another DNS server:
```
nslookup
> server 8.8.8.8
> some.hostname.com
# or
dig some.hostname.com @8.8.8.8
```