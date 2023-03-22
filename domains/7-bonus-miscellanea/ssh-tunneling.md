## SSH-tunneling

SSH-tunneling (or port forwarding, PF) is a method for creating an encrypted SSH connection between a client and a server machine through which services port can be relayed. There are three types of SSH-tunneling:

- local (**LPF**), allows you to forward a port on the local (ssh client) machine to a port on the remote (ssh server) machine, which is then forwarded to a port on the destination machine, and is mostly used to connect to a service (e.g. a database) available on an internal network
- remote (**RPF**), allows you to forward a port on the remote (ssh server) machine to a port on the local (ssh client) machine, which is then forwarded to a port on the destination machine, and is often used to give access to an internal service to someone from the outside (e.g. to show a preview of a webappp hosted on your local machine to your colleague)
- dynamic (**DPF**), allows you to create a socket on the local (ssh client) machine, which acts as a SOCKS proxy server.

### Local Port-Forwarding (LPF)

To create a LPF:
```
ssh -L [local-ip:]local-port:destination-ip:destination-port [user@]ssh-server
# if local-ip is omitted, it defaults to localhost

# e.g
# ssh -L 3336:db-hostname:3336 user@intermediate-host

# but if the destination host is the same as the ssh server used to access it, simply
# ssh -L 3336:localhost:3336 -N -f user@db-hostname
# -L, specifies that connections to the given TCP port or Unix socket on the local (client) host are to be forwarded to the given host and port, or Unix socket, on the remote side
# -N, disallows execution of remote commands, useful for just forwarding ports
# -f, forks the process to background
```

> Note: Make sure 'AllowTcpForwarding' is **not** set to 'no' in the remote ssh server configuration.

### Remote Port-Forwarding (RPF)

To create a RPF:
```
ssh -R [remote-ip:]remote-port:dest-ip:dest-port [user@]ssh-server
# e.g.
# ssh -R 8080:localhost:3000 -N -f user@ssh-server-ip
# -R, specifies that connections to the given TCP port or Unix socket on the remote (server) host are to be forwarded to the local side
# -N, disallows execution of remote commands, useful for just forwarding ports
# -f, forks the process to background
```

The ssh server will listen on 8080, tunneling all traffic from this port to your local port 3000, so that your colleagues can access your webapp at ssh-server-ip:8080.

> Note: Make sure 'GatewayPorts' is set to 'yes' in the remote ssh server configuration.

### Dynamic Port-Forwarding (DPF)

In this configuration, the SSH server acts as a SOCKS proxy, relaying all relevant traffic (including DNS name resolution) through the SSH connection. This is particularly useful when the client is on a network with limited access to the internet, for example, due to a VPN filtering your traffic (e.g. music streaming services suc as YouTube).

For this to happen, the client (e.g., a browser) needs to be SOCKS-aware.

To create a DPF:
```
ssh -D local-port -q -C -N -f [user@]ssh-server

# e.g.
# ssh -D 1080 -q -C -N -f user@ssh-server-ip
# -D 1080, opens a SOCKS proxy on local port 1080
# -C, compresses data in the tunnel, saves bandwidth
# -q, quiet mode, don’t output anything locally
# -N, disallows execution of remote commands, useful for just forwarding ports
# -f, forks the process to background
```

The you can configure your client to use the SOCKS proxy. For example, you can configure proxy access to the internet in Firefox from the Setting menu as follows:

<img src="https://www.redhat.com/sysadmin/sites/default/files/styles/embed_medium/public/2021-01/firefox-socks-proxy-configuration_0.png?itok=PPO8MGG4"
     alt="Markdown Monster icon"
     style=" display: block; margin-left: auto; margin-right: auto;" 
     width="800" height="900" />

If you need to use this configuration often, you'd better off creating a specific browser profile in the Firefox Settings so that it's not necessary to constantly switch between proxy configurations. A new profile can be created by passing the `-P` flag to the `firefox` command, launching the Profile Manager:
```
$ firefox -P $PROXY_PROFILE_NAME
```

<!--
 TODO add a paragraph for X forwarding: e.g., https://www.baeldung.com/linux/forward-x-over-ssh
-->


--- 

References:
- [Create a SOCKS proxy on a Linux server with SSH to bypass content filters](https://ma.ttias.be/socks-proxy-linux-ssh-bypass-content-filters/)
- [How to set up SSH dynamic port forwarding on Linux](https://www.redhat.com/sysadmin/ssh-dynamic-port-forwarding)