## Synchronize time using other network peers

Ubuntu by default uses **timedatectl** (front-end utility)/**timesyncd** (daemon) to synchronize time and users can optionally use **chrony** to serve the *Network Time Protocol*.

Until recently, most network time synchronization was handled by the Network Time Protocol daemon or **ntpd**. This service connects to a pool of other NTP servers that provide it with constant and accurate time updates.

Ubuntu’s default install now uses **timesyncd** instead of ntpd. timesyncd connects to the same time servers and works in roughly the same way, but is more lightweight and more integrated with systemd and the low level workings of Ubuntu.

`ntpdate` is considered deprecated in favor of `timedatectl` (or `chrony`) and thereby no more installed by default. timesyncd will generally do the right thing keeping your time in sync, and chrony will help with more complex cases: `systemd-timesyncd` implements SNTP, not NTP, hence multi-server support is out of focus; if you want a full NTP implementation, please use `ntpd` (<18.04) or `chrony` (>18.04).

We can query the status of timesyncd by running timedatectl with no arguments. You don’t need to use sudo in this case: `timedatectl`

*system clock synchronized: yes* indicates that the time has been successfully synced, and *systemd-timesyncd.service active: yes* means that timesyncd is enabled and running.

If you’re not sure about your time zone, you can list the available time zones with the following command: `timedatectl list-timezones`

Next, you can set the time zone using the timedatectl set-timezone command: `timedatectl set-timezone America/Antigua`

### Hardware vs System Clock

A Linux system will generally have two clocks, a hardware clock/real time clock (**RTC**) and a system clock.

The hardware clock is physically present and continues to run from battery power even if the system is not plugged into a power source, this is how the time stays in place when there is no power available. As the Linux system boots up it will read time from the hardware clock, this initial time is then passed to the system clock.

The system clock runs in the kernel and after getting its initial time from the hardware clock it will then synchronize with an NTP server to become up to date.

We can manually synchronize the hardware clock to the system clock if required, this would generally only be required if there was no NTP server available: `hwclock --hctosys`

We can also reverse the process and synchronize the system clock to the hardware clock. `hwclock --systohc`

The `hwclock` command can also be used to display the current time of the hardware clock as shown below:
```
sudo hwclock
> Tue 15 Sep 2015 22:24:32 AEST  -0.352785 seconds
```

### Understanding Stratum

NTP servers work based on a layered hierarchy referred to as *stratum*, starting at stratum 0. Stratum 0 are the highly exact time sources such as atomic clocks or GPS clocks, these are our reference time devices. Stratum 1 are the computers that synchronize with the stratum 0 sources, these are highly accurate NTP servers. Stratum 2 servers then get their time from the stratum 1 servers, while stratum 3 servers synchronize with stratum 2 sources.

Essentially stratum n+1 will synchronize against stratum n, the highest limit is 15, while 16 refers to a device that is not synchronized. There are [plenty of public stratum-1 servers available](https://www.pool.ntp.org) on the Internet for use. It is generally recommended that you synchronize with a time source higher in the hierarchy, for instance synchronizing time against a stratum 1 server will be considered more reliable than using a stratum 4 server.

### Firewall Rules

By default NTP uses UDP port **123**, so if you are connecting over the Internet to an external NTP server ensure that outbound UDP 123 traffic is allowed out to the NTP server specified in your configuration. Normally by default all outbound traffic is allowed so this should not be a problem. Public NTP servers on the Internet should already be configured to accept inbound NTP traffic.

## How to synchronize the system clock with a remote server (enable NTP) using timedatectl

Enable the NTP service on your Linux system with the command, if it's inactive:
`sudo timedatectl set-ntp on`

It's worth noting that this command fails if a NTP service is not installed, e.g. timesyncd, ntpd, Chrony or others. timesyncd should be installed by default in many cases though (for example it's installed by default with Ubuntu 16.04 and newer).

If using a service like chrony or ntpd to make changes, these are not shown by timedatectl until systemd-timedated is restarted:
`sudo systemctl restart systemd-timedated`

On an Ubuntu 18.04 server I also had to restart systemd-timesyncd (but this was no needed on my Ubuntu 19.04 or Solus OS systems for example), or else the system time would not get synchronized. In case you're also using timesyncd, and timedatectl shows `System clock synchronized: no`, even though it shows `NTP service active`, restart systemd-timesyncd: `sudo systemctl restart systemd-timesyncd`

When using the default systemd-timesyncd service, you can see some more information than that provided by timedatectl, like the NTP time server used, and a log showing the last time the synchronization was performed, with: `sudo systemctl status systemd-timesyncd`

On systemd 239 and newer (e.g. this won't work on Ubuntu 18.04, because it uses systemd 237) you may show the systemd-timesyncd status using: `timedatectl show-timesync`

And the properties systemd-timesyncd using: `timedatectl timesync-status`

You can change the settings shown here by editing the `/etc/systemd/timesyncd.conf` configuration file. E.g. to change the NTP servers (you could use the servers provided by the [NTP Pool Project](https://www.ntppool.org/en/use.html)), uncomment the NTP line, and add the servers you want to use separated by a space. After changing the configuration file, restart systemd-timesyncd:
```
[Time]
NTP=0.it.pool.ntp.org 1.it.pool.ntp.org 2.it.pool.ntp.org 3.it.pool.ntp.org
FallbackNTP=ntp.ubuntu.com
RootDistanceMaxSec=5
PollIntervalMinSec=32
PollIntervalMaxSec=2048
```