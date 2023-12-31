## Mapping Hosts and Ports Locally

Add an entry to [`/etc/hosts`](https://linux.die.net/man/5/hosts) mapping a given domain name to `127.0.0.1`: 
```bash
$ head -n3 /etc/hosts
127.0.0.1	localhost
127.0.1.1	yourmachinehostname.homenet.isp.com
127.0.0.1	registry.io
```

Usually this is the first source (it depends on your Name Service Switch ([NSS](https://linux.die.net/man/5/nsswitch.conf)) configuration file, `/etc/nsswitch.conf`) checked by an application that needs to perform name resolution via C library routines such as [getaddrinfo](https://linux.die.net/man/3/getaddrinfo). The next step should be sending DNS queries to the servers listed in the [/etc/resolv.conf](https://linux.die.net/man/5/resolv.conf) file.

> Note: some programming languages as [Go](https://pkg.go.dev/net#hdr-Name_Resolution) can use a custom resolver with their own logic as well. 

This works fine but if you want to redirect the traffic to a specific port, you will also need to setup a reverse proxy: you can configure the Apache HTTP Server (with the [mod_rewrite](https://httpd.apache.org/docs/2.4/mod/mod_rewrite.html) module) or `nginx` (with the [proxy_pass](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/) directive) to proxy the incoming requests to the right destination port.

To configure nginx, you could put the snippet below in `/etc/nginx/conf.d/registry.conf`:
```nginx
server {
    listen 80;

    server_name registry.io;

    location / {
        proxy_pass http://127.0.0.1:5000/;
    }
}
```

And you would be able to redirect `registry.io` to `127.0.0.1:5000`:
```bash
$ curl http://registry.io/v2/_catalog
{"repositories":["debian","alpine"]}
```

---

If all you need is just to make a simple HTTP call for a one-shot test, you can instruct [curl](https://everything.curl.dev/usingcurl/connections/name) to resolve a hostname to specific IP address:
```bash
$ curl --resolve registry.io:5000:127.0.0.1 http://registry.io:5000/v2/_catalog
{"repositories":["debian","alpine"]}
```

In fact, the documentation for the flag says:
```
--resolve <[+]host:port:addr[,addr]...>
    Provide  a  custom  address  for a specific host and port pair. Using this, you can make the curl requests(s) use a specified address and prevent the otherwise normally resolved address to be used. Consider it a sort of /etc/hosts alternative provided on the command line. The port number should be the number used for the specific protocol the host will be used for. It means you need several entries if you want to provide address for the same host but different ports.
```

It even allows you to specify both a replacement name and a port number when a specific name and port number is used to connect:
```bash
curl --connect-to registry.io:80:127.0.0.1:5000 http://registry.io/v2/_catalog
{"repositories":["debian","alpine"]}
```

---

Otherwise if you don't want to clutter your hosts file, you can install on your Linux distribution the [nss-myhostname](https://man7.org/linux/man-pages/man8/nss-myhostname.8.html) package: it automatically resolves any subdomains of localhost to the `127.0.0.1`, so that you can simply refer to a server running locally by adding `.localhost` as a suffix along with its port, e.g.:
```bash
$ curl http://registry.localhost:5000/v2/_catalog
{"repositories":["debian","alpine"]}
```

In this way (almost) everything works with zero configuration on your local environment, and so it's even better than using [dnsmasq](https://www.stevenrombauts.be/2018/01/use-dnsmasq-instead-of-etc-hosts/) which requires a bit of configuration to get the same result.

That said, your are still in need of specifying the target port. You will probably need `iptables` (or `ssh`) to setup a port forwarding if that is crucial for you. 

---

References:
- [Apache Module mod_rewrite](https://httpd.apache.org/docs/2.4/mod/mod_rewrite.html)
- [NGINX Reverse Proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [Iptables Tutorial](https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html)
- [Name resolve tricks (curl)](https://everything.curl.dev/usingcurl/connections/name)
- [nss-myhostname(8)](https://man7.org/linux/man-pages/man8/nss-myhostname.8.html)
- [Use dnsmasq instead of /etc/hosts](https://www.stevenrombauts.be/2018/01/use-dnsmasq-instead-of-etc-hosts/)
