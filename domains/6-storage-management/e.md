## Configure and manage swap space

One of the easiest way of guarding against out-of-memory errors in applications is to add some swap space to your server.

> Warning: Although swap is generally recommended for systems utilizing traditional spinning hard drives, using swap with SSDs can cause issues with hardware degradation over time. 

The information written to disk will be significantly slower than information kept in RAM, but the operating system will prefer to keep running application data in memory and use swap for the older data. Overall, having swap space as a fallback for when your system’s RAM is depleted can be a good safety net against out-of-memory exceptions on systems with non-SSD storage available.

### 1. Checking the System for Swap Information

Before we begin, we can check if the system already has some swap space available. It is possible to have multiple swap files or swap partitions, but generally one should be enough.

We can see if the system has any configured swap by typing: `sudo swapon --show`

If you don’t get back any output, this means your system does not have swap space available currently.

You can verify that there is no active swap using the free utility:
```
free -h
>Output
>              total        used        free      shared  buff/cache   available
>Mem:           985M         84M        222M        680K        678M        721M
>Swap:            0B          0B          0B
```

As you can see in the Swap row of the output, no swap is active on the system.

## 2. Checking Available Space on the Hard Drive Partition

Before we create our swap file, we’ll check our current disk usage to make sure we have enough space:
```
df -h
>Output
>Filesystem      Size  Used Avail Use% Mounted on
>udev            481M     0  481M   0% /dev
>tmpfs            99M  656K   98M   1% /run
>/dev/vda1        25G  1.4G   23G   6% /
>tmpfs           493M     0  493M   0% /dev/shm
>tmpfs           5.0M     0  5.0M   0% /run/lock
>tmpfs           493M     0  493M   0% /sys/fs/cgroup
>/dev/vda15      105M  3.4M  102M   4% /boot/efi
>tmpfs            99M     0   99M   0% /run/user/1000
```

The device with `/` in the `Mounted on` column is our disk in this case. We have plenty of space available in this example (only 1.4G used). Your usage will probably be different.

> Note: Modern machines probably does not need swap space at all (see [here](https://opensource.com/article/19/2/swap-space-poll)).

### 3. Creating a Swap File

Now that we know our available hard drive space, we can create a swap file on our filesystem. We will allocate a file of the swap size that we want called `swapfile` in our root (/) directory.

The best way of creating a swap file is with the `fallocate` program. This command instantly creates a file of the specified size:
`sudo fallocate -l 1G /swapfile`

### 4. Enabling the Swap File

First, we need to lock down the permissions of the file so that only the users with root privileges can read the contents. This prevents normal users from being able to access the file, which would have significant security implications.

Make the file only accessible to root by typing: `sudo chmod 600 /swapfile`

We can now mark the file as swap space by typing: 
```
sudo mkswap /swapfile
>Output
>Setting up swapspace version 1, size = 1024 MiB (1073737728 bytes)
>no label, UUID=6e965805-2ab9-450f-aed6-577e74089dbf
```

After marking the file, we can enable the swap file, allowing our system to start utilizing it: `sudo swapon /swapfile`

Verify that the swap is available by typing: 
```
sudo swapon --show
>Output
>NAME      TYPE  SIZE USED PRIO
>/swapfile file 1024M   0B   -2
```

We can check the output of the free utility again to corroborate our findings:
```
free -h
>Output
>              total        used        free      shared  buff/cache   available
>Mem:           985M         84M        220M        680K        680M        722M
>Swap:          1.0G          0B        1.0G
```

### 5. Making the Swap File Permanent

Our recent changes have enabled the swap file for the current session. However, if we reboot, the server will not retain the swap settings automatically. We can change this by adding the swap file to our /etc/fstab file.

Add the swap file information to the end of your /etc/fstab file by typing:
`echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab`

---

### Tuning your Swap Settings

There are a few options that you can configure that will have an impact on your system’s performance when dealing with swap:

- `swappiness`, a parameter which configures how often your system swaps data out of RAM to the swap space, expressed as a percentage.

    We can see the current swappiness value by typing: `cat /proc/sys/vm/swappiness`

    > Tip: For a Desktop, a swappiness setting of 60 is not a bad value. For a server, you might want to move it closer to 0.

    We can set the swappiness to a different value by using the sysctl command.

    For instance, to set the swappiness to 10, we could type: `sudo sysctl vm.swappiness=10`

    This setting will persist until the next reboot. We can set this value automatically at restart by adding the line to our /etc/sysctl.conf file: `vm.swappiness=10`

-  `vfs_cache_pressure`, a parameter which configures how much the system will choose to cache inode and dentry information over other data.

    Basically, this is access data about the filesystem. This is generally very costly to look up and very frequently requested, so it’s an excellent thing for your system to cache. You can see the current value by querying the proc filesystem again: `cat /proc/sys/vm/vfs_cache_pressure`

    As it is currently configured, our system removes inode information from the cache too quickly. We can set this to a more conservative setting like 50 by typing: `sudo sysctl vm.vfs_cache_pressure=50`

    Again, this is only valid for our current session. We can change that by adding it to our configuration file like we did with our swappiness setting: `vm.vfs_cache_pressure=50`

---

### Removing a Swap File

To deactivate and remove the swap file, start by deactivating the swap space by typing: `sudo swapoff -v /swapfile`

Next, remove the swap file entry `/swapfile` the `/etc/fstab` file.

Finally, remove the actual swapfile file: `sudo rm /swapfile`