## Statically route IP traffic

### IP Routing

IP routing is a means of specifying and discovering paths in a TCP/IP network along which network data may be sent. Routing uses a set of routing tables to direct the forwarding of network data packets from their source to the destination, often via many intermediary network nodes known as routers. There are two primary forms of IP routing: Static Routing and Dynamic Routing.

**Static routing** involves manually adding IP routes to the system’s routing table, and this is usually done by manipulating the routing table with the route command. Static routing enjoys many advantages over dynamic routing, such as simplicity of implementation on smaller networks, predictability (the routing table is always computed in advance, and thus the route is precisely the same each time it is used), and low overhead on other routers and network links due to the lack of a dynamic routing protocol. However, static routing does present some disadvantages as well. For example, static routing is limited to small networks and does not scale well. Static routing also fails completely to adapt to network outages and failures along the route due to the fixed nature of the route.

**Dynamic routing** depends on large networks with multiple possible IP routes from a source to a destination and makes use of special routing protocols, such as the *Router Information Protocol* (**RIP**), which handle the automatic adjustments in routing tables that make dynamic routing possible. Dynamic routing has several advantages over static routing, such as superior scalability and the ability to adapt to failures and outages along network routes. Additionally, there is less manual configuration of the routing tables, since routers learn from one another about their existence and available routes. This trait also eliminates the possibility of introducing mistakes in the routing tables via human error. Dynamic routing is not perfect, however, and presents disadvantages such as heightened complexity and additional network overhead from router communications, which does not immediately benefit the end users, but still consumes network bandwidth.

---

When you need to access network devices located on a different network segment than the one you are on, you need to have a route set up so the networking stack knows how to get to the other network segment. This generally just points to your main gateway, but you may want to set up additional static routes, where you don’t want the traffic going through your main default gateway.

For Ubuntu versions prior to 18.04, you had to manually edit the */etc/network/interfaces* file to set up persistent static routes. With the introduction of Ubuntu 18.04, along came the netplan YAML based network configuration tool.

The netplan configuration files are located in the */etc/netplan* folder (for more info about technical specification, have a look at the [reference](https://netplan.io/reference/)).

First step is to open the main netplan configuration file using administrative privileges: `sudo vi /etc/netplan/01-network-manager-all.yaml`

Find the configuration stanza related to the network interface which you wish to add the static route to. In this example we will add the the static route to the destination network subnet `172.16.0.0/24` via the network gateway `192.168.1.100` on the interface `enp0s3`:
```
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        enp0s3:
            dhcp4: false
            addresses: [192.168.1.202/24]
            gateway4: 192.168.1.1
            nameservers:
              addresses: [8.8.8.8,8.8.4.4,192.168.1.1]
            routes:
            - to: 172.16.0.0/24
              via: 192.168.1.100
    version: 2
```

Once you made all required changes to add the static route all the new netplan configuration using the below command: `sudo netplan apply`

Or, if you want to test it first, and potentially roll back any changes, you can use the following command: `sudo netplan try [config-file]`

This option apply the changes, and provide a 120 timeout where by if you don’t accept the changes, they will revert back. This is useful to prevent you from locking yourself out of the system, if the network change didn’t work the way you were intending.

Check all static routes available on your Ubuntu system:
```
ip route s
> default via 192.168.1.1 dev enp0s3 proto static 
> 172.16.0.0/24 via 192.168.1.100 dev enp0s3 proto static 
> 192.168.1.0/24 dev enp0s3 proto kernel scope link src 192.168.1.202 
```

To add non-persistent routes:
```
sudo ip route add 10.10.10.0/24 via 192.168.1.254           # specific route
sudo ip route add default via 192.168.1.254                 # default route (gw)
```

Example: adding a static route to a different subnet that cannot be accessed through your default gateway

If your computer is on a network and is not directly connected to the internet, it will be configured with what is called a default gateway, which is usually a router. If the computer cannot find the specific IP address on its local network (aka broadcast domain), as defined by its subnet, it will forward any packets headed to that IP address to the default gateway. The gateway will then attempt to forward packets elsewhere, such as the internet, or another broadcast domain.

But what if you have a separate network (i.e. another office department) that is NOT accessible via the default gateway?

For example, your internet router may be located at `10.0.0.1` and it is serving your local network, `10.0.0.0/8`. However, you have a `172.16.5.0/24` network that is accessible only through a secondary router, which has the IP address `10.0.0.101` on the main network. Therefore, you need to point your OS to the secondary router for any IP addresses located in the `172.16.5.0-255` address space. To do this, you need to add a static route.

If you wish to add one temporarily, simply run the `ip route add` command with the right network information:
`ip route add 172.16.5.0/24 via 10.0.0.101 dev eth0`

**172.16.5.0** is the network you wish to access.
**/24** is the subnet mask
**10.0.0.101** is the secondary router to which you are adding a default route
**eth0** is the network interface assigned to your main network (in this case, 10.0.0.0/8)

> Note: *ip route add* command will only persist until the next reboot or interface/network settings restart.