Configure the system so that the existing filesystem that corresponds to ​/staging​ gets persistently mounted in read-only mode:
```
sed -i "s/staging auto $(grep staging /etc/fstab | cut -d" " -f4)/staging auto ro/g" /etc/fstab
```