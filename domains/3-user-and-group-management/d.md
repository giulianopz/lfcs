## Manage template user environment

The `/etc/skel` directory contains files and directories that are automatically copied over to a new user’s when it is created from `useradd` command:
```
ll /etc/skel/
>total 48K
>drwxr-xr-x   3 root root 4.0K Jul 31  2020 ./
>drwxr-xr-x 156 root root  12K Mar 26 21:44 ../
>-rw-r--r--   1 root root  220 Feb 25  2020 .bash_logout
>-rw-r--r--   1 root root 3.7K Feb 25  2020 .bashrc
>drwxr-xr-x   2 root root 4.0K Jul 31  2020 .config/
>-rw-r--r--   1 root root  15K Apr 13  2020 .face
>lrwxrwxrwx   1 root root    5 Jan  5 15:33 .face.icon -> .face
>-rw-r--r--   1 root root  807 Feb 25  2020 .profile
```

> Note: The location of /etc/skel can be changed by editing the line that begins with SKEL= in the configuration file /etc/default/useradd.