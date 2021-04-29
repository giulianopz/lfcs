## Network-Manager

The point of **NetworkManager** is to make networking configuration and setup as painless and automatic as possible. If using DHCP, NetworkManager is intended to replace default routes, obtain IP addresses from a DHCP server and change nameservers whenever it sees fit. In effect, the goal of NetworkManager is to make networking Just Work.

The computer should use the wired network connection when it's plugged in, but automatically switch to a wireless connection when the user unplugs it and walks away from the desk. Likewise, when the user plugs the computer back in, the computer should switch back to the wired connection. The user should, most times, not even notice that their connection has been managed for them; they should simply see uninterrupted network connectivity. 

NetworkManager is composed of two layers:

- a daemon running as root: `network-manager`.
- a front-end: `nmcli` and `nmtui` (enclosed in package network-manager), `nm-tray`, `network-manager-gnome` (`nm-applet`), `plasma-nm`. 

Start network manager: `sudo systemctl start network-manager`

Enable starting the network manager when the system boots: `sudo systemctl enable network-manager`

Depending on the Netplan backend in use (desktop or server:
`sudo systemctl [start|restart|stop|status] [network-manager|system-networkd]`

Use `nmcli` to manage the former, and `networkctl` for the latter.

Establish a wifi connection:
```
nmcli d                                           # determine the name of the wifi interface
nmcli r wifi on                                   # make sure wifi radio is on
nmcli d wifi list                                 # list available wifi connections
nmcli d wifi connect <some-wifi> password <pwd>   # connect to an access point
```