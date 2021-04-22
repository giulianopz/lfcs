## Configure systems to mount file systems on demand

 One drawback of using /etc/fstab is that, regardless of how infrequently a user accesses the NFS mounted file system, the system must dedicate resources to keep the mounted file system in place. This is not a problem with one or two mounts, but when the system is maintaining mounts to many systems at one time, overall system performance can be affected. An alternative to /etc/fstab is to use the kernel-based **automount** utility. An automounter consists of two components:

- a kernel module that implements a file system, and
- a user-space daemon that performs all of the other functions. 

The automount utility can mount and unmount NFS file systems automatically (on-demand mounting), therefore saving system resources. It can be used to mount other file systems including AFS, SMBFS, CIFS, and local file systems.

hese automatic mount points are mounted only when they are accessed, and unmounted after a certain period of inactivity. This on-demand behavior saves bandwidth and results in better performance than static mounts managed by /etc/fstab. While `autofs` is a control script, `automount` is the command (daemon) that does the actual auto-mounting. 

---

### 1. Installation

Install the autofs package either by clicking here or entering the following in a terminal window: `sudo apt install autofs`

### 2. Configuration

autofs can be configured by editing configuration files. There are other ways to configure autofs on a network (see [AutofsLDAP](https://help.ubuntu.com/community/AutofsLDAP)), but config files provide the simplest setup. 

The master configuration file for autofs is `/etc/auto.master` by default. Unless you have a good reason for changing this, leave it as the default.

Here is the sample file provided by Ubuntu:
```
#
# $Id: auto.master,v 1.4 2005/01/04 14:36:54 raven Exp $
#
# Sample auto.master file
# This is an automounter map and it has the following format
# key [ -mount-options-separated-by-comma ] location
# For details of the format look at autofs(5).
#/misc   /etc/auto.misc --timeout=60
#/smb   /etc/auto.smb
#/misc  /etc/auto.misc
#/net    /etc/auto.net
```

Each of the lines in auto.master describes a mount and the location of its **map**. These lines have the following format:
`mount-point [map-type[,format]:] map [options]`

The map files are usually named using the convention `auto.<X>`, where `<X>` can be anything as long as it matches an entry in `auto.master` and is valid for a file-name.

### 3. EXAMPLE: Auto-mounting an NFS share

In this howto, we will configure autofs to auto-mount an NFS share, using a set of configuration files. This howto assumes that you are already familiar with NFS exports, and that you already have a properly-functioning NFS share on your network. Go to the [NFS Setup Page](https://help.ubuntu.com/community/SettingUpNFSHowTo) to learn how to set up such a server.

3.11. Edit /etc/auto.master

The following step creates a mount point at `/nfs` and configures it according to the settings specified in `/etc/auto.nfs` (which we will create in the next step).

Type the following into a terminal: `sudo vi /etc/auto.master`

Add the following line at the end of /etc/auto.master: `/nfs   /etc/auto.nfs`

3.2. Create /etc/auto.nfs

Now we will create the file which contains our automounter map: `sudo vi /etc/auto.nfs`

This file should contain a separate line for each NFS share. The format for a line is `{mount point} [{mount options}] {location}`. If you have previously configured static mounts in /etc/fstab, it may be helpful to refer to those. Remember, the mount points specified here will be relative to the mount point given in /etc/auto.master.

The following line is for shares using older versions of NFS (prior to version 4): `server   server:/`

This creates a new mount point at `/nfs/server/` and mounts the NFS root directory exported by the machine whose host-name is `server`.

3.2.1. NFSv4

If your NFS shares use NFSv4, you need to tell autofs about that. In such a case, the above line would appear as follows: `server   -fstype=nfs4   server:/`

The client needs the same changes to `/etc/default/nfs-common` to connect to an NFSv4 server. In /etc/default/nfs-common we set:
```
NEED_IDMAPD=yes
NEED_GSSD=no # no is default
```

3.3. Unmount static mounts and edit /etc/fstab

If you have previously configured the NFS shares as static mounts, now is the time to unmount them: `sudo umount /server`

Next, remove (or comment out) their respective entries in /etc/fstab: `#server:/ /server/ nfs defaults 0 0`

3.4. Reload /etc/init.d/autofs

After entering your changes, run the following command to reload autofs: `sudo systemctl restart autofs`

3.5. Make sure it works

In order to access the share and verify that it is working properly, enter the following into a shell: `ls /nfs/server`

If you see your NFS share listed, congratulations! You have a functioning NFS mount via autofs! If you want to learn some more advanced information, keep reading [here](https://help.ubuntu.com/community/Autofs).