## Setup user and group disk quotas for filesystems

Storage space is a resource that must be carefully used and monitored. To do that, **quotas** can be set on a file system basis, either for individual users or for groups.

Thus, a limit is placed on the disk usage allowed for a given user or a specific group, and you can rest assured that your disks will not be filled to capacity by a careless (or malicious) user.

### 1. Installing the Quota Tools

To set and check quotas, we first need to install the quota command line tools using apt. Let’s update our package list, then install the package:
```
sudo apt update
sudo apt install quota
```

### 2. Installing the Quota Kernel Module

You can verify that the tools are installed by running the quota command and asking for its version information: `quota --version`

If you are on a cloud-based virtual server, your default Ubuntu Linux installation may not have the kernel modules needed to support quota management. To check, we will use find to search for the quota_v1 and quota_v2 modules in the /lib/modules/... directory:
`find /lib/modules/`uname -r` -type f -name '*quota_v*.ko*'`

If you get no output from the above command, install the linux-image-extra-virtual package: `sudo apt install linux-image-extra-virtual`

### 3. Updating Filesystem Mount Options

To activate quotas on a particular filesystem, we need to mount it with a few quota-related options specified. We do this by updating the filesystem’s entry in the /etc/fstab configuration file. Open that file in your favorite text editor now: `sudo vi /etc/fstab`

This file’s contents will be similar to the following:
```
LABEL=cloudimg-rootfs   /        ext4   defaults        0 0
LABEL=UEFI      /boot/efi       vfat    defaults        0 0
```

Update the line pointing to the root filesystem by replacing the defaults option with the following options:
```
LABEL=cloudimg-rootfs   /        ext4   usrquota,grpquota        0 0
```

This change will allow us to enable both user- (**usrquota**) and group-based (**grpquota**) quotas on the filesystem. If you only need one or the other, you may leave out the unused option. If your fstab line already had some options listed instead of **defaults**, you should add the new options to the end of whatever is already there, being sure to separate all options with a comma and no spaces.

Remount the filesystem to make the new options take effect:
`sudo mount -o remount /`

We can verify that the new options were used to mount the filesystem by looking at the /proc/mounts file. Here, we use grep to show only the root filesystem entry in that file:
```
cat /proc/mounts | grep ' / '
>/dev/vda1 / ext4 rw,relatime,quota,usrquota,grpquota,data=ordered 0 0
```

Note the two options that we specified. Now that we’ve installed our tools and updated our filesystem options, we can turn on the quota system.

### 4. Enabling Quotas

Before finally turning on the quota system, we need to manually run the quotacheck command once: `sudo quotacheck -ugm /`

This command creates the files `/aquota.user` and `/aquota.group`. These files contain information about the limits and usage of the filesystem, and they need to exist before we turn on quota monitoring. The quotacheck parameters we’ve used are:

- `(-u)`, specifies that a user-based quota file should be created
- `(-g)`, indicates that a group-based quota file should be created
- `(-m)`, disables remounting the filesystem as read-only while performing the initial tallying of quotas. Remounting the filesystem as read-only will give more accurate results in case a user is actively saving files during the process, but is not necessary during this initial setup.

We can verify that the appropriate files were created by listing the root directory: `ls /aquota*`

Now we’re ready to turn on the quota system: `sudo quotaon -v /`
 
Our server is now monitoring and enforcing quotas, but we’ve not set any yet!

### 5. Configuring Quotas for a User

There are a few ways we can set quotas for users or groups. Here, we’ll go over how to set quotas with both the `edquota` and `setquota` commands.

#### 5.1 Using edquota to Set a User Quota

We use the `edquota` command to edit quotas. Let’s edit our example **sammy** user’s quota: `sudo edquota -u sammy`

The `-u` option specifies that this is a user quota we’ll be editing. If you’d like to edit a group’s quota instead, use the `-g` option in its place.

This will open up a file in your default text editor:
```
Disk quotas for user sammy (uid 1000):
  Filesystem                   blocks       soft       hard     inodes     soft     hard
  /dev/vda1                        40          0          0         13        0        0
```

This lists the username and uid, the filesystems that have quotas enabled on them, and the block- and inode-based usage and limits. Setting an **inode-based** quota would limit how many files and directories a user can create, regardless of the amount of disk space they use. Most people will want **block-based** quotas, which specifically limit disk space usage. This is what we will configure.

> Note: The concept of a block is poorly specified and can change depending on many factors, including which command line tool is reporting them. In the context of setting quotas on Ubuntu, it’s fairly safe to assume that 1 block equals 1 kilobyte of disk space.

In the above listing, our user sammy is using 40 blocks, or 40KB of space on the /dev/vda1 drive. The soft and hard limits are both disabled with a 0 value.

Each type of quota allows you to set both a soft limit and a hard limit. When a user exceeds the soft limit, they are over quota, but they are not immediately prevented from consuming more space or inodes. Instead, some leeway is given: the user has – by default – seven days to get their disk use back under the soft limit. At the end of the seven day **grace period**, if the user is still over the soft limit it will be treated as a hard limit. A hard limit is less forgiving: all creation of new blocks or inodes is immediately halted when you hit the specified hard limit. This behaves as if the disk is completely out of space: writes will fail, temporary files will fail to be created, and the user will start to see warnings and errors while performing common tasks.

Let’s update our sammy user to have a block quota with a 100MB soft limit, and a 110MB hard limit:
```
Disk quotas for user sammy (uid 1000):
  Filesystem                   blocks       soft       hard     inodes     soft     hard
  /dev/vda1                        40       100M       110M         13        0        0
```

Save and close the file. To check the new quota we can use the quota command:
```
sudo quota -vs sammy
>Disk quotas for user sammy (uid 1000):
>     Filesystem   space   quota   limit   grace   files   quota   limit   grace
>      /dev/vda1     40K    100M    110M              13       0       0
```

The command outputs our current quota status, and shows that our quota is 100M while our limit is 110M. This corresponds to the soft and hard limits respectively.

> Note: If you want your users to be able to check their own quotas without having sudo access, you’ll need to give them permission to read the quota files we created in Step 4. One way to do this would be to make a users group, make those files readable by the users group, and then make sure all your users are also placed in the group.

#### 5.2 Using setquota to Set a User Quota

Unlike `edquota`, setquota will update our user’s quota information in a single command, without an interactive editing step. We will specify the username and the soft and hard limits for both block- and inode-based quotas, and finally the filesystem to apply the quota to:
`sudo setquota -u sammy 200M 220M 0 0 /`

The above command will double sammy’s block-based quota limits to 200 megabytes and 220 megabytes. The `0 0` for inode-based soft and hard limits indicates that they remain unset. This is required even if we’re not setting any inode-based quotas.

Once again, use the quota command to check our work:
```
sudo quota -vs sammy
>Disk quotas for user sammy (uid 1000): 
>     Filesystem   space   quota   limit   grace   files   quota   limit   grace
>      /dev/vda1     40K    200M    220M              13       0       0
```

### 6. Generating Quota Reports

To generate a report on current quota usage for all users on a particular filesystem, use the repquota command:
```
>sudo repquota -s /
>Output
>*** Report for user quotas on device /dev/vda1
>Block grace time: 7days; Inode grace time: 7days
>                        Space limits                File limits
>User            used    soft    hard  grace    used  soft  hard  grace
>----------------------------------------------------------------------
>root      --   1696M      0K      0K          75018     0     0
>daemon    --     64K      0K      0K              4     0     0
>man       --   1048K      0K      0K             81     0     0
>nobody    --   7664K      0K      0K              3     0     0
>syslog    --   2376K      0K      0K             12     0     0
>sammy     --     40K    100M    110M             13     0     0
```

In this instance we’re generating a report for the / root filesystem. The `-s` command tells repquota to use human-readable numbers when possible. There are a few system users listed, which probably have no quotas set by default. Our user sammy is listed at the bottom, with the amounts used and soft and hard limits.

Also note the `Block grace time: 7days` callout, and the `grace` column. If our user was over the soft limit, the grace column would show how much time they had left to get back under the limit.

### 7. Configuring a Grace Period for Overages

We can configure the period of time where a user is allowed to float above the soft limit. We use the setquota command to do so:
`sudo setquota -t 864000 864000 /`

The above command sets both the block and inode grace times to 864000 seconds, or 10 days. This setting applies to all users, and both values must be provided even if you don’t use both types of quota (block vs. inode).

> Note: The values must be specified in seconds.

Run repquota again to check that the changes took effect:
`sudo repquota -s /`

The changes should be reflected immediately in the repquota output.