## Start, stop, and check the status of network services

On systemd-based systems, use:
`sudo systemctl [is-active|is-enabled-start|restart|reload|status|stop|try-restart] <name.service>`

> Note: On SysV-based systems use the `service` command instead.