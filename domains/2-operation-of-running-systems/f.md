## Schedule tasks to run at a set date and time

To run tasks at a specific time in the future different services are available:

- `at` specifies a one-time task that runs at a certain time
- `cron` can schedule tasks on a repetitive basis, such as daily, weekly, or monthly
- `anacron` can  be  used  to  execute  commands periodically, with a frequency specified in days, but unlike cron, it does not assume that the machine is running continuously.

--- 

### Cron

The crond daemon is the background service that enables cron functionality.

The cron service checks for files in the `/var/spool/cron` and `/etc/cron.d` directories and the '/etc/anacrontab` file. The contents of these files define cron jobs that are to be run at various intervals. The individual user cron files are located in /var/spool/cron, and system services and applications generally add cron job files in the /etc/cron.d directory.

The cron utility runs based on commands specified in a cron table (crontab). Each user, including root, can have a cron file. These files don't exist by default, but can be created in the /var/spool/cron directory using the `crontab -e` command that's also used to edit a cron file:
```
SHELL=/bin/bash
MAILTO=root@example.com
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed

# backup using the rsbu program to the internal 4TB HDD and then 4TB external
01 01 * * * /usr/local/bin/rsbu -vbd1 ; /usr/local/bin/rsbu -vbd2

# Set the hardware clock to keep it in sync with the more accurate system clock
03 05 * * * /sbin/hwclock --systohc

# Perform monthly updates on the first of the month
# 25 04 1 * * /usr/bin/dnf -y update
```

The first three lines in the code above set up a default environment. The environment must be set to whatever is necessary for a given user because cron does not provide an environment of any kind. 

> Warning: If no user is specified, the job is run as the user that owns the crontab file, root in the case of the root crontab.

To prevent possible misuse, you can control access to the `crontab` command by using two files in the /etc/cron.d directory: `cron.deny` and `cron.allow`. These files permit only specified users to perform crontab command tasks such as creating, editing, displaying, or removing their own crontab files.

The cron.deny and cron.allow files consist of a list of user names, one user name per line. 

These access control files work together as follows:

- if cron.allow exists, only the users who are listed in this file can create, edit, display, or remove crontab files
- if cron.allow does not exist, all users can submit crontab files, except for users who are listed in cron.deny
- if neither cron.allow nor cron.deny exists, superuser privileges are required to run the crontab command.


### Anacron

The `anacron` program performs the same function as crond, but it adds the ability to run jobs that were skipped, such as if the computer was off or otherwise unable to run the job for one or more cycles. The anacron program provides some easy options for running regularly scheduled tasks. Just install your scripts in the `/etc/cron.[hourly|daily|weekly|monthly]` directories, depending how frequently they need to be run.

anacron itself doesn't run as a service/daemon, but as a cron job: /etc/cron.d/anacron. So cron is running and checking if anacron is present for the daily, weekly and monthly tasks (it would be duplication of effort to have both running preriod-fixed tasks), but not for the hourly tasks. cron runs the hourly tasks.

So, actually anacron uses a variety of methods to run:
- if the system is running systemd, it uses a systemd timer (in the Debian package, you’ll see it in /lib/systemd/system/anacron.timer)
- if the system isn’t running systemd, it uses a system cron job (in /etc/cron.d/anacron)
- in all cases it runs daily, weekly and monthly cron jobs (in /etc/cron.{daily,weekly,monthly}/0anacron)
- it also runs at boot (from /etc/init.d/anacron or its systemd unit).

anacron will check if a job has been executed within the specified period in the period field. If not, it executes the command specified in the command field after waiting the number of minutes specified in the delay field. Once the job has been executed, it records the date in a timestamp file in the /var/spool/anacron directory with the name specified in the job-id field:
```
cat /var/spool/anacron/bck.weekly 
>20210328
```

> Note: the specified delay times in each line help prevent these jobs from overlapping themselves and other cron jobs.    

> Tip: Instead of placing whole bash programs in the cron.X directories, just install them in the `/usr/local/bin` directory, which will allow you to run them easily from the command line. Then, add a symlink in the appropriate cron directory, such as `/etc/cron.daily`.

### Examples of job definition syntax:

Every minute of every day:
```
# m h dom mon dow command
* * * * * /home/user/command.sh
# or
0-59 0-23 0-31 0-12 0-7 /home/user/command.sh
```

Every 15 minutes of every day:
```
# m h dom mon dow command
*/15 * * * * /home/user/command.sh
# or
0-59/15 * * * * /home/user/command.sh
# or
0,15,30,45 * * * * /home/user/command.sh
```

> Note: The division expressions must result in a remainder of zero for the job to run.

Every 5 minutes of the 2 am hour starting at 2:03:
```
# m h dom mon dow command
03-59/5 02 * * * /home/user/command.sh
# This runs at 2:03, 2:08, 2:13, 2:18, 2:23, and so on until 2:58
```

Every day at midnight:
```
# m h dom mon dow command
0 0 * * * /home/user/command.sh
# or
0 0 * * 0-7 /home/user/command.sh
```

Twice a day:
```
# m h dom mon dow command
0 */12 * * * /home/user/command.sh
# or
# m h dom mon dow command
0 0-23/12 * * * /home/user/command.sh
# or
0 0,12 * * * /home/user/command.sh
```

Every weekday at 2 am:
```
# m h dom mon dow command
0 02 * * 1-5 /home/user/command.sh
```

Weekends at 2 am:
```
# m h dom mon dow command
0 02 * * 6,7 /home/user/command.sh
# or
0 02 * * 6-7 /home/user/command.sh
```

Once a month on the 15th at 2 am:
```
# m h dom mon dow command
0 02 15 * * /home/user/command.sh
```

Every 2 days at 2 am:
```
# m h dom mon dow command
0 02 */2 * * /home/user/command.sh
```

Every 2 months at 2 am on the 1st:
```
# m h dom mon dow command
0 02 1 */2 * /home/user/command.sh
```

### Shortcuts

The are shortcuts which can be used to replace the five fields usually used to specify times. The `@` character is used to identify shortcuts to cron. The list below, taken from the crontab(5) man page, shows the shortcuts with their equivalent meanings.

- `@reboot`: run once after reboot
- `@yearly`: run once a year, i.e. `0 0 1 1 *`
- `@annually`: run once a year, i.e. `0 0 1 1 *`
- `@monthly`: run once a month, i.e. `0 0 1 * *`
- `@weekly`: run once a week, i.e. `0 0 * * 0`
- `@daily`: run once a day, i.e. `0 0 * * *`
- `@hourly`: run once an hour, i.e. `0 * * * *`

These shortcuts can be used in any of the crontab files.

### At

`at` is an interactive command-line utility that allows you to schedule commands to be executed at a particular time. Jobs created with at are executed only once.

The at command takes the date and time (runtime) when you want to execute the job as a command-line parameter, and the command to be executed from the standard input.

Let’s create a job that will be executed at 9:00 am: `at 09:00`

Once you hit Enter, you’ll be presented with the at command prompt that most often starts with `at>`. You also see a warning that tells you the shell in which the command will run:
```
warning: commands will be executed using /bin/sh
at>
```

Enter one or more command you want to execute: `tar -xf /home/linuxize/file.tar.gz`

When you’re done entering the commands, press Ctrl-D to exit the prompt and save the job:
```
at> <EOT>
job 4 at Tue May  5 09:00:00 2020
```

The command will display the job number and the execution time and date.

There are also other ways to pass the command you want to run, besides entering the command in the at prompt. One way is to use echo and pipe the command to at:
```
echo "command_to_be_run" | at 09:00
```

The at utility accepts a wide range of time specifications. You can specify time, date, and increment from the current time:

- time: to specify a time, use the `HH:MM` or `HHMM` form. To indicate a 12-hour time format, use `am` or `pm` after the time (e.g. `at 1pm + 2 days`). You can also use strings like `now`, `midnight`, `noon`, or `teatime` (16:00). If the specified time is passed, the job will be executed the next day.

- date: the command allows you to schedule job execution on a given date. The date can be specified using the month name followed by the day and an optional year. You can use strings, such as `today`, `tomorrow`, or weekday. The date can be also indicated using the `MMDD[CC]YY`, `MM/DD/[CC]YY`, `DD.MM.[CC]YY` or `[CC]YY-MM-DD` formats (e.g. `at 12:30 102120`).

- increment: at also accepts increments in the `now + count time-unit` format, where `count` is a number and `time-unit` can be one of the following strings: `minutes`, `hours`, `days`, or `weeks` (e.g. `at sunday +10 minutes`).

Time, date and increment can be combined.

Alternatively, use a here document or pass a file with `-f`.

To list the user’s pending jobs run the atq or at -l command: `atq`

To remove a pending job invoke the atrm or at -r command followed by the job number: `atrm 9`