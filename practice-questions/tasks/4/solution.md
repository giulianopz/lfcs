Create a cron job that kills all processes named scan_filesystem which is owned by root, every minute:
```
crontab -l > mycron
echo "*/1 * * * * pkill -u root -f scan_filesystem" >> mycron
crontab mycron
rm mycron
```
