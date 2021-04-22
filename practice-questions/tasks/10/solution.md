Create a user account with username ​sysadmin​ with thefollowing attributes:
1. Use a password of ​science​.
2. This user’s home directory is defined as ​/sysadmin/​:
```
sudo useradd "sysadmin" -d "/home/sysadmin" -m
sudo passwd sysadmin # science
```

3. sysadmin​ has sudo privileges and will not be prompted for a password when using the sudo command:
```
sudo usermod -aG sudo sysadmin
sudo visudo
>> %sysadmin ALL= NOPASSWD: ALL
```

4. The default shell for this user is ​zsh:
```
sudo usermod sysadmin -s "/usr/bin/zsh"
```