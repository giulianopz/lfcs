## Manage the startup process and services

To start a service by typing: `sudo systemctl start <unit>.service`

To stop it: `sudo systemctl stop <unit>.service`

To restart the service, we can type: `sudo systemctl restart <unit>.service`

To attempt to reload the service without interrupting normal functionality, we can type: `sudo systemctl reload <unit>.service`

> Note: "Loading" means parsing the unit’s configuration and keeping it in memory.

To enable a service to start automatically at boot, type: `sudo systemctl enable <unit>.service`

This will create a symbolic link from the system’s copy of the service file (usually in /lib/systemd/system or /etc/systemd/system) into the location on disk where systemd looks for autostart files (usually `/etc/systemd/system/some_target.target.wants`). 

> Note: To enable and start a service, use: `sudo systemctl enable --now <unit>.service`

If you wish to disable the service again, type: `sudo systemctl disable <unit>.service`

To get all of the unit files that systemd has listed as “active”, type: `systemctl list-units`

> Note: You can actually leave off the list-units as this is the default systemctl behavior.

To list all of the units that systemd has loaded or attempted to load into memory, including those that are not currently active, add the `--all` switch:
`systemctl list-units --all`

To list all of the units installed on the system, including those that systemd has not tried to load into memory, type: `systemctl list-unit-files`

To see only active service units, we can use: `systemctl list-units --type=service`


To show whether the unit is active, information about the process, and the latest journal entries: `systemctl status <unit>.service`

A unit file contains the parameters that systemd uses to manage and run a unit. To see the full contents of a unit file, type:
`systemctl cat <unit>.service`

To see the dependency tree of a unit (which units systemd will attempt to activate when starting the unit), type:
`systemctl list-dependencies <unit>.service`

This will show the dependent units, with target units recursively expanded. To expand all dependent units recursively, pass the --all flag:
`systemctl list-dependencies --all <unit>.service`

Finally, to see the low-level details of the unit’s settings on the system, you can use the show option:
`systemctl show <unit>.service`

To add a unit file snippet, which can be used to append or override settings in the default unit file, simply call the edit option on the unit:
`sudo systemctl edit <unit>.service`

This will be a blank file that can be used to override or add directives to the unit definition. A directory will be created within the `/etc/systemd/system` directory which contains the name of the unit with `.d` appended. For instance, for the `nginx.service`, a directory called `nginx.service.d` will be created. Within this directory, a snippet will be created called override.conf. When the unit is loaded, systemd will, in memory, merge the override snippet with the full unit file. The snippet’s directives will take precedence over those found in the original unit file (usually found somewhere in `/lib/systemd/system`).

If you prefer to modify the entire content of the unit file instead of creating a snippet, pass the --full flag:
`sudo systemctl edit --full <unit>.service`

After modifying a unit file, you should reload the systemd process itself to pick up your changes:
`sudo systemctl daemon-reload`

systemd also has the ability to mark a unit as completely unstartable, automatically or manually, by linking it to /dev/null. This is called **masking** the unit, and is possible with the mask command: `sudo systemctl mask nginx.service`

Use `unmask` to undo the masking.

---

The files that define how systemd will handle a unit can be found in many different locations, each of which have different priorities and implications.

The system’s copy of unit files are generally kept in the `/lib/systemd/system` directory. When software installs unit files on the system, this is the location where they are placed by default. You should not edit files in this directory. Instead you should override the file, if necessary, using another unit file location which will supersede the file in this location. The best location to do so is within the `/etc/systemd/system` directory. Unit files found in this directory location take precedence over any of the other locations on the filesystem. If you need to modify the system’s copy of a unit file, putting a replacement in this directory is the safest and most flexible way to do this. If you wish to override only specific directives from the system’s unit file, you can actually provide unit file snippets within a subdirectory. These will append or modify the directives of the system’s copy, allowing you to specify only the options you want to change. The correct way to do this is to create a directory named after the unit file with `.d` appended on the end. So for a unit called example.service, a subdirectory called `example.service.d` could be created. Within this directory a file ending with `.conf` can be used to override or extend the attributes of the system’s unit file. There is also a location for run-time unit definitions at `/run/systemd/system`. Unit files found in this directory have a priority landing between those in /etc/systemd/system and /lib/systemd/system. The systemd process itself uses this location for dynamically created unit files created at runtime. This directory can be used to change the system’s unit behavior for the duration of the session. All changes made in this directory will be lost when the server is rebooted.

To learn more about unit files, look [here](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files).