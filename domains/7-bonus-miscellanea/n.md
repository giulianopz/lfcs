## How DNS Works

DNS is a global system for translating IP addresses to human-readable domain names. When a user tries to access a web address like “example.com”, their web browser or application performs a DNS Query against a DNS server, supplying the hostname. The DNS server takes the hostname and resolves it into a numeric IP address, which the web browser can connect to.

A component called a DNS Resolver is responsible for checking if the hostname is available in local cache, and if not, contacts a series of DNS Name Servers, until eventually it receives the IP of the service the user is trying to reach, and returns it to the browser or application. This usually takes less than a second.

## DNS Types: 3 DNS Query Types

There are three types of queries in the DNS system:

- Recursive Query

> In a recursive query, a DNS client provides a hostname, and the DNS Resolver “must” provide an answer—it responds with either a relevant resource record, or an error message if it can't be found. The resolver starts a recursive query process, starting from the DNS Root Server, until it finds the Authoritative Name Server (for more on Authoritative Name Servers see DNS Server Types below) that holds the IP address and other information for the requested hostname.

- Iterative Query

>In an iterative query, a DNS client provides a hostname, and the DNS Resolver returns the best answer it can. If the DNS resolver has the relevant DNS records in its cache, it returns them. If not, it refers the DNS client to the Root Server, or another Authoritative Name Server which is nearest to the required DNS zone. The DNS client must then repeat the query directly against the DNS server it was referred to.

- Non-Recursive Query

> A non-recursive query is a query in which the DNS Resolver already knows the answer. It either immediately returns a DNS record because it already stores it in local cache, or queries a DNS Name Server which is authoritative for the record, meaning it definitely holds the correct IP for that hostname. In both cases, there is no need for additional rounds of queries (like in recursive or iterative queries). Rather, a response is immediately returned to the client.

## DNS Types: 3 Types of DNS Servers

The following are the most common DNS server types that are used to resolve hostnames into IP addresses:

- DNS Resolver

> A DNS resolver (recursive resolver), is designed to receive DNS queries, which include a human-readable hostname such as “www.example.com”, and is responsible for tracking the IP address for that hostname.

- DNS Root Server

> The root server is the first step in the journey from hostname to IP address. The DNS Root Server extracts the Top Level Domain (TLD) from the user’s query — for example, www.example.com —... provides details for the .com TLD Name Server. In turn, that server will provide details for domains with the .com DNS zone, including “example.com”.

>There are 13 root servers worldwide, indicated by the letters A through M, operated by organizations like the Internet Systems Consortium, Verisign, ICANN, the University of Maryland, and the U.S. Army Research Lab.

- Authoritative DNS Server

> Higher level servers in the DNS hierarchy define which DNS server is the “authoritative” name server for a specific hostname, meaning that it holds the up-to-date information for that hostname.

> The Authoritative Name Server is the last stop in the name server query—it takes the hostname and returns the correct IP address to the DNS Resolver (or if it cannot find the domain, returns the message NXDOMAIN).

## DNS Types: 10 Top DNS Record Types

DNS servers create a DNS record to provide important information about a domain or hostname, particularly its current IP address. The most common DNS record types are:

- Address Mapping record (A Record)—also known as a DNS host record, stores a hostname and its corresponding IPv4 address.
- IP Version 6 Address record (AAAA Record)—stores a hostname and its corresponding IPv6 address.
- Canonical Name record (CNAME Record)—can be used to alias a hostname to another hostname. When a DNS client requests a record that contains a CNAME, which points- to another hostname, the DNS resolution process is repeated with the new hostname.
- Mail exchanger record (MX Record)—specifies an SMTP email server for the domain, used to route outgoing emails to an email server.
- Name Server records (NS Record)—specifies that a DNS Zone, such as “example.com” is delegated to a specific Authoritative Name Server, and provides the address- of the name server.
- Reverse-lookup Pointer records (PTR Record)—allows a DNS resolver to provide an IP address and receive a hostname (reverse DNS lookup).
- Certificate record (CERT Record)—stores encryption certificates—PKIX, SPKI, PGP, and so on.
- Service Location (SRV Record)—a service location record, like MX but for other communication protocols.
- Text Record (TXT Record)—typically carries machine-readable data such as opportunistic encryption, sender policy framework, DKIM, DMARC, etc.
- Start of Authority (SOA Record)—this record appears at the beginning of a DNS zone file, and indicates the Authoritative Name Server for the current DNS zone,- contact details for the domain administrator, domain serial number, and information on how frequently DNS information for this zone should be refreshed.

## DNS Can Do Much More

Now that’s we’ve covered the major types of traditional DNS infrastructure, you should know that DNS can be more than just the “plumbing” of the Internet. Advanced DNS solutions can help do some amazing things, including:

- Global server load balancing (GSLB): fast routing of connections between globally distributed data centers
- Multi CDN: routing users to the CDN that will provide the best experience
- Geographical routing: identifying the physical location of each user and ensuring they are routed to the nearest possible resource
- Data center and cloud migration: moving traffic in a controlled manner from on-premise resources to cloud resources
- Internet traffic management: reducing network congestion and ensuring traffic flows to the appropriate resource in an optimal manner

## DNS search domains

A search domain is a domain used as part of a domain search list. The domain search list, as well as the local domain name, is used by a resolver to create a fully qualified domain name (FQDN) from a relative name. For this purpose, the local domain name functions as a single-item search list. 

DNS search domains are used to go from a machine name to a Fully Qualified Domain Name.

DNS searches can only look at a Fully Qualified Domain Name, such as *mymachine.example.com*. But, it's a pain to type out *mymachine.example.com*, you want to be able to just type mymachine.

Using Search Domains is the mechanism to do this. If you type a name that does not end with a period, it knows it needs to add the search domains for the lookup. So, lets say your Search Domains list was: *example.org, example.com*.

With *mymachine* it would try first *mymachine.example.org*, not find it, then try *mymachine.example.com*, found it, now done.

With *mymachine.example.com* it would try *mymachine.example.com.example.org* (remember, it doesn't end with a period, still adds domains), fail, then *mymachine.example.com.example.com*, not find it, fall back to *mymachine.example.com*, found it, now done.

*mymachine.example.com.* ends with a period, no searching, just do *mymachine.example.com*.

So, if you have your own DNS domain such as *example.com*, put it there. If not, ignore it. It really is more corporate than a home setting.