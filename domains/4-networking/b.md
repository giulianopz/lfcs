## Configure network services to start automatically at boot

It’s usually a good idea to configure essential network services to automatically start on boot. This saves you the hassle of starting them manually upon a reboot and also, the resulting havoc caused in case you forget to do so. Some of the crucial network services include `SSH`, `NTP`, and `httpd`.

You can confirm what is your system service manager by running the following command:
```
ps --pid 1
>    PID TTY          TIME CMD
>      1 ?        00:00:04 systemd
```

To enable a service to start on boot, use the syntax: `sudo systemctl enable <service-name>`

> Note: On SysV-based systems use `chkconfig` in place of `systemctl`.

To confirm that the desired service has been enabled, list all the enabled services by executing the command:
`sudo systemctl list-unit-files --state=enabled`