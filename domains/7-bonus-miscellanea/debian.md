## Non-Free Firmware for Debian

After installing, you may need to install non-free firmware to get the drivers required by your hardware: e.g. to enable wireless connection.

First, allow apt to download packages from contrib and non-free sources:
```bash
apt-add-repository contrib
apt-add-repository non-free
```

Add some common firmware:
```
apt install firmware-linux-nonfree
apt install firmware-misc-nonfree
# if you have Realtek hardware in your machine
apt install firmware-realtek
```

For the specific wifi drivers you need, read the Debian docs online. For example, for Intel cards you will need [iwlwifi](https://wiki.debian.org/iwlwifi): 
```
apt update && apt install firmware-iwlwifi
# reload kernel module
modprobe -r iwlwifi ; modprobe iwlwifi
```

For nvidia GPUs, use `nvidia-detect` to find out the appropriate drivers, e.g.:
```
apt install nvidia-driver
```

Check if the nvidia modules are loaded with `lsmod | grep nvidia`. If not, verify that you had already disabled Secure/Fast Boot in the BIOS/UEFI settings. 
