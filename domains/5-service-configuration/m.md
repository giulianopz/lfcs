## Restrict access to a web page

In Apache 2.4 the authorization configuration setup has changed from previous versions. `Satisfy, Order, Deny and Allow` have all been deprecated and replaced with new `Require` directives.

If you wish to restrict access to portions of your site based on the host address of your visitors, this is most easily done using mod_authz_host.

The Require provides a variety of different ways to allow or deny access to resources. In conjunction with the RequireAll, RequireAny, and RequireNone directives, these requirements may be combined in arbitrarily complex ways, to enforce whatever your access policy happens to be.

The Allow, Deny, and Order directives, provided by mod_access_compat, are deprecated and will go away in a future version. You should avoid using them, and avoid outdated tutorials recommending their use.

The usage of these directives is:
```
Require host address
Require ip ip.address
```

In the first form, address is a fully qualified domain name (or a partial domain name); you may provide multiple addresses or domain names, if desired.

In the second form, ip.address is an IP address, a partial IP address, a network/netmask pair, or a network/nnn CIDR specification. Either IPv4 or IPv6 addresses may be used.

You can insert not to negate a particular requirement. Note, that since a not is a negation of a value, it cannot be used by itself to allow or deny a request, as not true does not constitute false. Thus, to deny a visit using a negation, the block must have one element that evaluates as true or false. For example, if you have someone spamming your message board, and you want to keep them out, you could do the following in the virtual host block:
```
<Directory /var/www/html>
    <RequireAll>
        Require all granted
        Require not ip 10.252.46.165
    </RequireAll>
</Directory>
```

Visitors coming from that address (10.252.46.165) will not be able to see the content covered by this directive. If, instead, you have a machine name, rather than an IP address, you can use that:
`Require not host host.example.com`
    

And, if you'd like to block access from an entire domain, you can specify just part of an address or domain name:
```
Require not ip 192.168.205
Require not host phishers.example.com moreidiots.example
Require not host gov
```

Use of the RequireAll, RequireAny, and RequireNone directives may be used to enforce more complex sets of requirements.

To enforce basic authentication, have a look at the [documentaion](https://httpd.apache.org/docs/2.4/howto/auth.html).