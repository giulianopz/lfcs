## Verify completion of scheduled jobs

First, check the status of the cron service to ensure it is currently running: `sudo systemctl status cron`

Check if rsyslogd is logging cron jobs execution in its own file:
```
cat /etc/rsyslog.d/50-default.conf | grep cron
>#cron.*                         /var/log/cron.log
```

If this line is commentd as above, the cron logs are on the syslog dump file.

`crond` (unless configured otherwise, as said above) will send a log message to syslog every time it invokes a scheduled job. The simplest way to verify that cron tried to run the job is to simply examine the logs: `grep -E "(ana)*cron" /var/log/syslog`

> Note: If you have a mail transfer agent — such as Sendmail — installed and properly configured on your server, you can send the output of cron tasks to the email address associated with your Linux user profile. You can also manually specify an email address by providing a MAILTO setting at the top of the crontab. 

For `anacron`, you can force the execution of the scheduled jobs: `sudo anacron -f -n`, and then examining the logs: `tail -f  /var/log/syslog`. The timestamp for each job is stored in `/var/spool/anacron`.