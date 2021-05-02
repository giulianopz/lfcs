## SSH-tunneling

SSH-tunneling (or port forwarding, PF) is a method for creating an encrypted SSH connection between a client and a server machine through which services port can be relayed. There are three types of SSH-tunneling:

- local (LPF), allows you to forward a port on the local (ssh client) machine to a port on the remote (ssh server) machine, which is then forwarded to a port on the destination machine, and is mostly used to connect to a service (e.g. a database) available on an internal network
- remote (RPF), allows you to forward a port on the remote (ssh server) machine to a port on the local (ssh client) machine, which is then forwarded to a port on the destination machine, and is often used to give access to an internal service to someone from the outside (e.g. to show a preview of a webappp hosted on your local machine to tour colleague)
- dynamic (DPF), allows you to create a socket on the local (ssh client) machine, which acts as a SOCKS proxy server.

### LPF

To create a LPF:
```
ssh -L [local-ip:]local-port:destination-ip:destination-port [user@]ssh-server
# if local-ip is omitted, it defaults to localhost

# e.g
ssh -L 3336:db-hostname:3336 user@intermediate-host

# but if the destination host is the same as the ssh server used to access it, simply
ssh -L 3336:localhost:3336 -N -f user@db-hostname
```

> Note: `-f` is to run the remote connection in the background, `-N` to not execute a remote command.

> Note: Make sure 'AllowTcpForwarding' is **not** set to 'no' in the remote ssh server configuration.

### RPF

To create a RPF:
```
ssh -R [remote-ip:]remote-port:dest-ip:dest-port [user@]ssh-server

# e.g.
ssh -R 8080:localhost:3000 -N -f user@remote-host
```

The ssh server will listen on 8080, tunneling all traffic from this port to you local port 3000, so that your colleagues can access your webapp at ssh-server-ip:8080.

> Note: Make sure 'GatewayPorts' is set to 'yes' in the remote ssh server configuration.