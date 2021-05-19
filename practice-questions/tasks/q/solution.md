The following tasks may be achieved using the user ​student​’s sudo privileges:

1. Temporarily mount the filesystem available on /dev/xvdf2​ under ​/mnt/backup/​
2. Decompress and unarchive the /mnt/backup/backup-primary.tar.bz2​ archive into ​/opt/​. This should result in a new directory (created from the archive itself) named ​/opt/proddata/​.

```
su - student
sudo mount /dev/xvdf2 /mnt/backup
sudo tar xvf /mnt/backup/backup-primary.tar.bz2​ -C /opt​
```
    
    