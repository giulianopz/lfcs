Configure the swap partition ​/dev/xvdi1​ so that it does ​not​ become attached automatically at boot time:
```
swapoff -v ​/dev/xvdi1
cat /proc/swaps # check if swap file is no more present
sed -i "/xvdi1/d" /etc/fstab
```