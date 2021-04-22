## Configure a caching DNS server

Domain Name Service (DNS) is an Internet service that maps IP addresses and fully qualified domain names (FQDN) to one another. In this way, DNS alleviates the need to remember IP addresses. Computers that run DNS are called **name servers**. Ubuntu ships with **BIND** (Berkley Internet Naming Daemon), the most common program used for maintaining a name server on Linux.

The following is meant to show you how to set up a local DNS resolver on Ubuntu (20.04), with the widely-used BIND9 DNS software. A DNS resolver is known by many names, some of which are listed below. They all refer to the same thing:

- full resolver (in contrast to stub resolver)
- DNS recursor
- recursive DNS server
- recursive resolver

Also, be aware that a DNS server can also be called a name server, as said before. Examples of DNS resolver are `8.8.8.8` (Google public DNS server) and `1.1.1.1` (Cloudflare public DNS server). The OS on your computer also has a resolver, although it’s called *stub resolver* due to its limited capability. A stub resolver is a small DNS client on the end user’s computer that receives DNS requests from applications such as Firefox and forward requests to a recursive resolver. Almost every resolver can cache DNS response to improve performance, so they are also called caching DNS server.

There are many ways to configure BIND9. Some of the most common configurations are a caching nameserver, primary server, and secondary server:

- when configured as a **caching nameserver** BIND9 will find the answer to name queries and remember the answer when the domain is queried again
- as a **primary server**, BIND9 reads the data for a zone from a file on its host and is authoritative for that zone
- as a **secondary server**, BIND9 gets the zone data from another nameserver that is authoritative for the zone.

Run the following command to install BIND 9 on Ubuntu (20.04), from the default repository (BIND 9 is the current version and BIND 10 is a dead project):
```
sudo apt update
sudo apt install bind9 bind9utils bind9-doc bind9-host
```

The BIND server will run as the **bind** user, which is created during installation, and listens on TCP and UDP port 53. The BIND daemon is called **named**. The **rndc** binary is used to reload/stop and control other aspects of the BIND daemon. Communication is done over TCP port 953. 

The DNS configuration files are stored in the /etc/bind directory. The primary configuration file is /etc/bind/named.conf, which in the layout provided by the package just includes these files:

- /etc/bind/named.conf.options: global DNS options
- /etc/bind/named.conf.local: for your zones
- /etc/bind/named.conf.default-zones: default zones such as localhost, its reverse, and the root hints.

The root nameservers used to be described in the file /etc/bind/db.root. This is now provided instead by the /usr/share/dns/root.hints file shipped with the dns-root-data package, and is referenced in the named.conf.default-zones configuration file above.

It is possible to configure the same server to be a caching name server, primary, and secondary: it all depends on the zones it is serving. A server can be the Start of Authority (SOA) for one zone, while providing secondary service for another zone. All the while providing caching services for hosts on the local LAN.

## Caching Nameserver

The default configuration acts as a caching server. Simply uncomment and edit /etc/bind/named.conf.options to set the IP addresses of your ISP’s DNS servers:
```
forwarders {
    1.2.3.4;
    5.6.7.8;
};
```
Replace *1.2.3.4* and *5.6.7.8* with the IP Addresses of actual nameservers (e.g 8.8.8.8, 8.8.4.4).

Save and close the file. Then test the config file syntax: `sudo named-checkconf`

If the test is successful (indicated by a silent output), then restart BIND9: `sudo systemctl restart named`

If you have UFW firewall running on the BIND server, then you need to open port 53 to allow LAN clients to send DNS queries: `sudo ufw allow domain`

To turn query logging on, run: `sudo rndc querylog on`

This will open TCP and UDP port 53 to the private network 192.168.0.0/24. Then from another computer in the same LAN, we can run the following command to query the A record of `google.com`. Replace 192.168.0.102 with the IP address of your BIND resolver: `dig A google.com @192.168.0.102`

Now on the BIND resolver, check the query log with the following command: `sudo journalctl -eu named`

This will show the latest log message of the bind9 service unit. You should fine something like the following line in the log, which indicates that a DNS query for google.com’s A record has been received from port 57806 of 192.168.0.103:
```
named[1162]: client @0x7f4d2406f0f0 192.168.0.103#57806 (google.com): query: google.com IN A +E(0)K (192.168.0.102)
```

Another way of testing your configuration is to use dig against the loopback interface to make sure it is listening on port 53. From a terminal prompt:
`dig -x 127.0.0.1`

You should see lines similar to the following in the command output:
```
;; Query time: 1 msec
;; SERVER: 192.168.1.10#53(192.168.1.10)
```

If you have configured BIND9 as a Caching nameserver “dig” an outside domain to check the query time: `dig ubuntu.com`

Note the query time towards the end of the command output: `;; Query time: 49 msec`

After a second dig there should be improvement: `;; Query time: 1 msec`

---

## Setting the Default DNS Resolver on Ubuntu 20.04 Server

**systemd-resolved** provides the stub resolver on Ubuntu 20.04. As mentioned in the beginning of this article, a stub resolver is a small DNS client on the end-user’s computer that receives DNS requests from applications such as Firefox and forward requests to a recursive resolver.

The default recursive resolver can be seen with this command: `systemd-resolve --status`

If you don'find `127.0.0.1` as your current DNS Server, BIND isn’t the default. If your are testing it on your laptop, chances are that your current DNS server is your home router. 

If you run the following command on the BIND server, the related DNS query won’t be found in BIND log: `dig A facebook.com`

Instead, you need to explicitly tell dig to use BIND: `dig A facebook.com @127.0.0.1`

To set BIND as the default resolver, open the systemd-resolved configuration file: `sudo vi /etc/systemd/resolved.conf`

In the `[Resolve]` section, add the following line. This will set a global DNS server for your server: `DNS=127.0.0.1`

Save and close the file. Then restart systemd-resolved service: `sudo systemctl restart systemd-resolved`

Now run the following command to check the default DNS resolver: `systemd-resolve --status`

Now perform a DNS query without specifying 127.0.0.1: `dig A facebook.com`

You will see the DNS query in BIND log, which means BIND is now the default recursive resolver. If you don’t see any queries in the BIND log, you might need to configure per-link DNS server.