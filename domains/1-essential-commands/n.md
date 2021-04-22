## Manage access to the root account

By default Ubuntu does not set up a root password during installation and therefore you don’t get the facility to log in as root. However, this does not mean that the root account doesn’t exist in Ubuntu or that it can’t be completely accessed. Instead you are given the ability to execute tasks with superuser privileges using the `sudo` command.

To access the root user account run one of the following commands and enter your normal-user password: 
```
sudo -i         # run the shell specified by the target user's password database entry as a login shell
sudo su         # substitute user staying in the previous dir
sudo su -       # land on substituted user's home
sudo su root    # redundant, since root is the default account
``` 

You can change root password as shown below:
```
sudo passwd root
>Enter new UNIX password:
>Retype new UNIX password:
>passwd: password updated successfully
```

If you wish to disable root account login, run the command below to set the password to expire: `sudo passwd -l root`