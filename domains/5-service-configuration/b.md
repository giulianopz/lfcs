## Maintain a DNS zone

A **DNS zone** is a distinct part of the domain namespace which is delegated to a legal entity — a person, organization or company, who is responsible for maintaining the DNS zone. A DNS zone is also an administrative function, allowing for granular control of DNS components, such as authoritative name servers.

When a web browser or other network device needs to find the IP address for a hostname such as “example.com”, it performs a **DNS lookup** - essentially a DNS zone check - and is taken to the DNS server that manages the DNS zone for that hostname. This server is called the **authoritative name server** for the domain. The authoritative name server then resolves the DNS lookup by providing the IP address, or other data, for the requested hostname.

The Domain Name System (DNS) defines a domain namespace, which specifies **Top Level Domains** (such as “.com”), second-level domains, (such as “acme.com”) and lower-level domains, also called subdomains (such as “support.acme.com”). Each of these levels can be a DNS zone.

For example, the root domain “acme.com” may be delegated to a Acme Corporation. Acme assumes responsibility for setting up an authoritative DNS server that holds the correct DNS records for the domain.

At each hierarchical level of the DNS system, there is a Name Server containing a **zone file**, which holds the trusted, correct DNS records for that zone.

The **root** of the DNS system, represented by a dot at the end of the domain name — for example, "www.example.com." — is the primary DNS zone. Since 2016, the root zone is overseen by the Internet Corporation for Assigned Names and Numbers (ICANN), which delegates management to a subsidiary acting as the Internet Assigned Numbers Authority (IANA).

The DNS root zone is operated by 13 logical servers, run by organizations like Verisign, the U.S. Army Research Labs and NASA. Any recursive DNS query (more about DNS query types [here](../7-bonus-miscellanea/p.md)) starts by contacting one of these root servers, and requesting details for the next level down the tree — the Top Level Domain (TLD) server.

There is a DNS zone for each Top Level Domain, such as “.com”, “.org” or country codes like “.co.uk”. There are currently over 1500 top level domains. Most top level domains are managed by ICANN/IANA.

**Second-level domains** like the domain “ns1.com”, are defined as separate DNS zones, operated by individuals or organizations. Organizations can run their own DNS name servers, or delegate management to an external provider.

If a domain has subdomains, they can be part of the same zone. Alternatively, if a subdomain is an independent website, and requires separate DNS management, it can be defined as its own DNS zone.

DNS servers can be deployed in a **primary/secondary** topology, where a secondary DNS server holds a read-only copy of the primary DNS server’s DNS records. The primary server holds the primary zone file, and the secondary server constitutes an identical secondary zone; DNS requests are distributed between primary and secondary servers. A **DNS zone transfer** occurs when the primary server zone file is copied, in whole or in part, to the secondary DNS server.

DNS **zone files** are defined in RFC 1035 and RFC 1034. A zone file contains mappings between domain names, IP addresses and other resources, organized in the form of **resource records** (RR).

There are two types of zone files:

- a DNS Primary File which authoritatively describes a zone
- a DNS Cache File which lists the contents of a DNS cache — this is only a copy of the authoritative DNS zone.

In a zone file, each line represents a DNS resource record (RR). A record is made up of the following fields:

- **Name** is an alphanumeric identifier of the DNS record. It can be left blank, and inherits its value from the previous record.
- **TTL** (time to live) specifies how long the record should be kept in the local cache of a DNS client. If not specified, the global TTL value at the top of the zone file is used.
- **Record class** indicates the namespace — typically **IN**, which is the Internet namespace.
- **Record type** is the DNS record type — for example an **A** record maps a hostname to an IPv4 address, and a **CNAME** is an alias which points a hostname to another hostname.
- **Record** data has one or more information elements, depending on the record type, separated by a white space. For example an MX record has two elements — a priority and a domain name for an email server.

DNS Zone files start with two mandatory records:

- **Global Time to Live** (TTL), which specifies how long records should be kept in local DNS cache.
- **Start of Authority** (SOA) record—specifies the primary authoritative name server for the DNS Zone.

After these two records, the zone file can contain any number of resource records, which can include:

- **Name Server records** (NS) — specifies that a specific DNS Zone, such as “example.com” is delegated to a specific authoritative name server
- **IPv4 Address Mapping records** (A) — a hostname and its IPv4 address.
- **IPv6 Address records** (AAAA) — a hostname and its IPv6 address.
- **Canonical Name records** (CNAME) — points a hostname to an alias. This is another hostname, which the DNS client is redirected to
- **Mail exchanger record** (MX) — specifies an SMTP email server for the domain.

Zone File Tips:

- when adding a record for a hostname, the hostname must end with a period (.)
- hostnames which do not end with a period are considered relative to the main domain name — for example, when specifying a "www" or “ftp” record, there is no need for a period
- you can add comments in a zone file by adding a semicolon (`;`) after a resource record
- many admins like to use the last date edited as the serial of a zone, such as 2020012100 which is yyyymmddss (where `ss` is the Serial Number)

---

## Primary Server maintaining a Forward Zone

To add a DNS zone to BIND9, turning BIND9 into a Primary server, first edit `/etc/bind/named.conf.local`:
```
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
};
```

Now use an existing zone file as a template to create the **/etc/bind/db.example.com** file: `sudo cp /etc/bind/db.local /etc/bind/db.example.com`

Edit the new zone file `/etc/bind/db.example.com` and change `localhost.` to the FQDN of your server, leaving the additional `.` at the end. Change `127.0.0.1` to the nameserver’s IP Address and `root.localhost` to a valid email address, but with a `.` instead of the usual `@` symbol, again leaving the `.` at the end. Change the comment to indicate the domain this file is for.

Create an A record for the base domain, **example.com**. Also, create an A record for **ns.example.com**, the name server in this example:
```
;
; BIND data file for example.com
;
$TTL    604800
@       IN      SOA     example.com. root.example.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

@       IN      NS      ns.example.com.
@       IN      A       192.168.1.10
@       IN      AAAA    ::1
ns      IN      A       192.168.1.10
```

You must increment the Serial Number every time you make changes to the zone file. If you make multiple changes before restarting BIND9, simply increment the Serial once.

Once you have made changes to the zone file BIND9 needs to be restarted for the changes to take effect: `sudo systemctl restart bind9.service`

## Reverse Zone

Now that the zone is setup and resolving names to IP addresses, a reverse zone needs to be added to allows DNS to resolve an address to a name.

Edit **/etc/bind/named.conf.local** and add the following:
```
zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192";
};
``` 
> Note: Replace 1.168.192 with the first three octets of whatever network you are using. Also, name the zone file /etc/bind/db.192 appropriately. It should match the first octet of your network. Reverse DNS lookups for IPv4 addresses use the special domain `in-addr.arpa`. In this domain, an IPv4 address is represented as a concatenated sequence of four decimal numbers, separated by dots, to which is appended the second level domain suffix `.in-addr.arpa`. The four decimal numbers are obtained by splitting the 32-bit IPv4 address into four octets and converting each octet into a decimal number. These decimal numbers are then concatenated in the order: least significant octet first (leftmost), to most significant octet last (rightmost). It is important to note that this is the reverse order to the usual dotted-decimal convention for writing IPv4 addresses in textual form. For example, to do a reverse lookup of the IP address `8.8.4.4` the PTR record for the domain name `4.4.8.8.in-addr.arpa` would be looked up, and found to point to `google-public-dns-b.google.com`. 

Now create the **/etc/bind/db.192** file from template: `sudo cp /etc/bind/db.127 /etc/bind/db.192`

Next edit /etc/bind/db.192 changing the same options as **/etc/bind/db.example.com**:
```
;
; BIND reverse data file for local 192.168.1.XXX net
;
$TTL    604800
@       IN      SOA     ns.example.com. root.example.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.
10      IN      PTR     ns.example.com.
```

The Serial Number in the Reverse zone needs to be incremented on each change as well. For each A record you configure in /etc/bind/db.example.com, that is for a different address, you need to create a PTR record in /etc/bind/db.192.

After creating the reverse zone file restart BIND9: `sudo systemctl restart bind9.service`

## Secondary Server

Once a Primary Server has been configured a secondary server is highly recommended in order to maintain the availability of the domain should the Primary become unavailable.

First, on the primary server, the zone transfer needs to be allowed. Add the `allow-transfer` option to the example forward and reverse zone definitions in /etc/bind/named.conf.local:
```
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
    allow-transfer { 192.168.1.11; };
};
    
zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192";
    allow-transfer { 192.168.1.11; };
};
``` 
> Note: Replace 192.168.1.11 with the IP address of your secondary nameserver.

Restart BIND9 on the Primary server: `sudo systemctl restart bind9.service`

Next, on the scondary server, install the bind9 package the same way as on the primary. Then edit the /etc/bind/named.conf.local and add the following declarations for the forward and reverse zones:
```
zone "example.com" {
    type slave;
    file "db.example.com";
    masters { 192.168.1.10; };
};        
          
zone "1.168.192.in-addr.arpa" {
    type slave;
    file "db.192";
    masters { 192.168.1.10; };
};
```
> Note: Replace 192.168.1.10 with the IP address of your primary nameserver.

Restart BIND9 on the secondary server: `sudo systemctl restart bind9.service`

In /var/log/syslog you should see something similar to the following (some lines have been split to fit the format of this document):
```
client 192.168.1.10#39448: received notify for zone '1.168.192.in-addr.arpa'
zone 1.168.192.in-addr.arpa/IN: Transfer started.
transfer of '100.18.172.in-addr.arpa/IN' from 192.168.1.10#53:
 connected using 192.168.1.11#37531
zone 1.168.192.in-addr.arpa/IN: transferred serial 5
transfer of '100.18.172.in-addr.arpa/IN' from 192.168.1.10#53:
 Transfer completed: 1 messages, 
6 records, 212 bytes, 0.002 secs (106000 bytes/sec)
zone 1.168.192.in-addr.arpa/IN: sending notifies (serial 5)

client 192.168.1.10#20329: received notify for zone 'example.com'
zone example.com/IN: Transfer started.
transfer of 'example.com/IN' from 192.168.1.10#53: connected using 192.168.1.11#38577
zone example.com/IN: transferred serial 5
transfer of 'example.com/IN' from 192.168.1.10#53: Transfer completed: 1 messages, 
8 records, 225 bytes, 0.002 secs (112500 bytes/sec)
``` 

> Note: A zone is only transferred if the Serial Number on the primary is larger than the one on the secondary. If you want to have your primary DNS notifying other secondary DNS servers of zone changes, you can add `also-notify { ipaddress; };` to /etc/bind/named.conf.local as shown in the example below:
```
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
    allow-transfer { 192.168.1.11; };
    also-notify { 192.168.1.11; }; 
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192";
    allow-transfer { 192.168.1.11; };
    also-notify { 192.168.1.11; }; 
};
```
> Note: The default directory for non-authoritative zone files is /var/cache/bind/. This directory is also configured in AppArmor to allow the named daemon to write to it.

## Testing

A good way to test your zone files is by using the **named-checkzone** utility installed with the bind9 package. This utility allows you to make sure the configuration is correct before restarting BIND9 and making the changes live.

To test our example forward zone file enter the following from a command prompt: `named-checkzone example.com /etc/bind/db.example.com`

If everything is configured correctly you should see output similar to:
```
zone example.com/IN: loaded serial 6
OK
```

Similarly, to test the reverse zone file enter the following: `named-checkzone 1.168.192.in-addr.arpa /etc/bind/db.192`

The output should be similar to:
```
zone 1.168.192.in-addr.arpa/IN: loaded serial 3
OK
```