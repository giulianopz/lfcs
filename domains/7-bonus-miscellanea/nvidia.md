## How to fix Nvidia graphics card problems

Unfortunately the FOSS project [nouveau](https://wiki.archlinux.org/title/nouveau) is long from being able to replace the infamous proprietary nvidia drivers. Chances are you are going to install them to have basic stuff working, such as simply connecting an external monitor to your laptop.

See the article on [non-free firmware](./debian.md) to understand how to install them.

The drivers aren't going to completely save your time, tough.

In fact, even if they blacklist nouveau, to configure a dual-monitor setup with your desktop environment you may need anyway to:

1. force the appropriate kernel modules to be loaded at boot-time in the kernel boot parameters 
```bash
nvidia-drm.modeset=1
```
2. and, after rebooting, do some magic trick with xrandr:
```bash
xrandr --setprovideroutputsource NVIDIA-G0 modesetting && xrandr --auto
```
as explained in the nvidia [documentation](http://download.nvidia.com/XFree86/Linux-x86_64/450.80.02/README/randr14.html).

If in trouble, consult or ask for help in their online [forum](https://forums.developer.nvidia.com/c/gpu-graphics/linux/148) and study [Xorg](https://wiki.archlinux.org/title/xorg) and the related tooling.
