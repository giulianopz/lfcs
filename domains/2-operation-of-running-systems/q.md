## Manage software

`apt` is a high-level command-line utility for installing, updating, removing, and otherwise managing deb packages on Ubuntu, Debian, and related Linux distributions. It combines the most frequently used commands from the `apt-get` and apt-cache tools with different default values of some options.

> Note: Prefer using apt-get and apt-cache in your shell scripts as they are backward compatible between the different versions and have more options and features.

The first command updates the APT package index which is essentially a database of available packages from the repositories defined in the `/etc/apt/sources.list` file and in the `/etc/apt/sources.list.d` directory.

In addition to the officially supported package repositories available for Ubuntu, there exist additional community-maintained repositories which add thousands more packages for potential installation. Many other package sources are available, sometimes even offering only one package, as in the case of package sources provided by the developer of a single application. 

> Warning: Two of the most popular are the **universe** and **multiverse** repositories. Packages in the multiverse repository often have licensing issues that prevent them from being distributed with a free operating system, and they may be illegal in your locality. Be advised that neither the universe or multiverse repositories contain officially supported packages. In particular, there may not be security updates for these packages. By default, the universe and multiverse repositories are enabled but if you would like to disable them edit /etc/apt/sources.list and comment the lines containing these repositories' names.

Actions of the apt command, such as installation and removal of packages, are logged in the `/var/log/dpkg.log` log file.

---

Installing packages is as simple as running the following command: `sudo apt install <package>`

To remove the package including all configuration files: `sudo remove --purge install <package>`

To list all available packages use the following command (optionally, only the installed or upgradable ones): `sudo apt list (--installed/--upgradeable)`

To retrieve information about a given package, use the show command: `sudo apt show <package>`

To prevent updating a specific package: `sudo apt-mark hold <package>`

To remove the hold: `sudo apt-mark unhold <package>`

Show all packages on hold: `sudo apt-mark showhold`

To add an APT repository to either /etc/apt/sources.list or to a separate file in the /etc/apt/sources.list.d directory (e.g. MongoDB):
```
# first import the repository public key
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
# add the MongoDB repository using the command below
sudo add-apt-repository 'deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse'
# you can now install any of the packages from the newly enabled repository
sudo apt install mongodb-org
```

For example, to add the a PPA repo (e.g. Jonathon F’s PPA which provides FFmpeg version 4.x) you would run:
```
sudo add-apt-repository ppa:jonathonf/ffmpeg-4`
# the PPA repository public key will be automatically downloaded and registered
# once the PPA is added to your system you can install the repository packages
sudo apt install ffmpeg
```

If for any reasons you want to remove a previously enabled repository, use the --remove option: `sudo add-apt-repository --remove 'deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse'`

If you want to have more control over how your sources are organized you can manually edit the /etc/apt/sources.list file and add the apt repository line to the file, and then manually import the public repository key to your system with `apt-key`.

---

`dpkg` is a low-level package manager for Debian-based systems. It can install, remove, and build packages, but unlike other package management systems, it cannot automatically download and install packages or their dependencies. `apt` and `aptitude` are newer, and layer additional features on top of dpkg. 

To list all packages in the system’s package database, including all packages, installed and uninstalled, from a terminal prompt type:
`dpkg -l`

Depending on the number of packages on your system, this can generate a large amount of output. Pipe the output through grep to see if a specific package is installed: `dpkg -l | grep <package-name-or-regex>`

To list the files installed by a package, enter:
`dpkg -L <package>`

If you are not sure which package installed a file, `dpkg -S` may be able to tell you. For example:
```
dpkg -S /etc/host.conf 
base-files: /etc/host.conf
```

> Note: Many files are automatically generated during the package install process, and even though they are on the filesystem, dpkg -S may not know which package they belong to.

You can install a local .deb file by entering: `sudo dpkg -i <package>_<version>-<revision-num>_<arch>.deb`

> Note: For historical reasons, the 64-bit x86 architecture is called "amd64", while the 32-bit version is named "i386".

Uninstalling a package can be accomplished by: `sudo dpkg -r <package> # -P instead removes also config files`

> Warning: Uninstalling packages using dpkg, in most cases, is NOT recommended. It is better to use a package manager that handles dependencies to ensure that the system is in a consistent state. For example, using dpkg -r zip will remove the zip package, but any packages that depend on it will still be installed and may no longer function correctly.

---

Installing a package from source is the old-school approach of managing software. A source package provide you with all of the necessary files to compile or otherwise, build the desired piece of software. It consists, in its simplest form, of three files:
- the upstream tarball with `.tar.gz` ending
- a description file with `.dsc ending.` It contains the name of the package, both, in its filename as well as content
- a tarball, with any changes made to upstream source, plus all the files created for the Debian package (ending with `.debian.tar.gz` or a `.diff.gz`)

To install a debian package from source:

1. download the sources (or download it manually): ` apt source <package>`

> Note: You need a deb-src entry in your /etc/apt/sources.list file, like: `deb-src http://http.us.debian.org/debian unstable main` 

2. install the dependecies for the package: `apt build-dep <package>`
3. go into the extracted source directory and then build the package: 
```
dpkg-buildpackage -rfakeroot -b -uc -us
# or
debuild -b -uc -us
# or
apt source --compile
```
4. install the .deb file: `dpkg -i <deb-file>`
5. if you see a error message caused by missing deependencies, type: `apt install -f`