## How to fix screen low resolution

Sometimes when you connect a device to a monitor (external or integrated), you may experience an unexpected low resolution that you cannot change via system setting GUI of your desktop environment: only lower resolutions could be available. 

This can happen especially if you are using a VGA-to-HDMI converter to connect an old pc to a newer monitor. If the comunication is unidirectional, from input (e.g., a mini pc supporting only VGA) to output (e.g. an external monitor supporting only HDMI), the monitor won't be able to send [EDID](https://en.wikipedia.org/wiki/Extended_Display_Identification_Data) data packets which containts info regarding its capabilities.

In such cases, you can still grab the EDID data from another pc connected to this monitor or online, if you are lucky enough to find it.

Firstly, you should verify that the graphic card(s) of your pc can match the recommended resolution of your monitor: typically, 1920x1080 at 60 refresh rate (a standard also know as 1080p, Full HD or FHD,). For Intel cards, see [here](https://www.intel.com/content/www/us/en/support/articles/000023781/graphics.html).

Once this is verified, you may try to just add the the intended resolution (let's say, 1920x1080) with [xrandr](https://www.x.org/releases/X11R7.5/doc/man/man1/xrandr.1.html):
```
# show available resolutions for common display types (VGA, HDMI, etc.)
xrandr
# generate correct params for the target resolution
cvt 1920 1080 60
# pass the above params to the next command
xrandr --newmode "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
# make available the new resolution for the intended display type
xrandr --addmode VGA-1 "1920x1080_60.00"
xrandr --output VGA-1 --mode "1920x1080_60.00"
# go to the system settings GUI and select the resolution you have just configured if it's not still active after last command is executed
```

If this solved your problem, you have just to put these commands in an executable file sourced when the X session starts. Put this file in one of the following directories:
- `~/.profile`
- `/etc/profile.d`

If this did not solve the problem for you, some extra work is needed.

---
References:
- [Unable to set my screen resolution higher](https://askubuntu.com/questions/1075157/unable-to-set-my-screen-resolution-higher)
