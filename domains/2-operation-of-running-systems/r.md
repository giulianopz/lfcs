## Identify the component of a Linux distribution that a file belongs to

In any DEB-based systems, you can find the package that provides a certain file using apt-file tool.
If you just installed apt-file, the system-wide cache might be empty. You need to run 'apt-file update' as root to update the cache. You can also run 'apt-file update' as normal user to use a cache in the user's home directory.

And, then search for the packages that contains a specific file, say alisp.h, with command (for repository packages, either installed or not installed):
```
apt-file find <alisp.h> # *find* is an alias for *search*
```

apt-file may also be used to list all the files included in a package:
```
apt-file list <packagename>
```

If you already have the file, and just wanted to know which package it belongs to, you can use dpkg command as shown below (only for installed DEB packages - from any source):
```
dpkg -S $(which <alisp.h>)
```

If you already know the package name, you can quickly look up the files that are installed by a Debian package:
```
dpkg -L <packagename>
```