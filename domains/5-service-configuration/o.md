## Manage and configure Virtual Machines

The default virtualization technology supported in Ubuntu is **KVM**, which add hypervisor capabilities to the kernel. For Intel and AMD hardware KVM requires virtualization extensions. But KVM is also available for IBM Z and LinuxONE, IBM POWER as well as for ARM64. **Qemu** is part of the KVM experience being the userspace backend for it, but it also can be used for hardware without virtualization extensions by using its TCG mode.

Qemu is a machine emulator that can run operating systems and programs for one machine on a different machine. Mostly it is not used as emulator but as virtualizer in collaboration with KVM kernel components. In that case it utilizes the virtualization technology of the hardware to virtualize guests.

**libvirt** is a toolkit to interact with virtualization technologies which abstracts away from specific versions and hypervisors.

Managing KVM can be done from both command line tools (`virt-*` and `qemu-*`) and graphical interfaces (`virt-manager`).

Before getting started with libvirt it is best to make sure your hardware supports the necessary virtualization extensions for KVM. Enter the following from a terminal prompt:
```
kvm-ok
# or alternatively, it should be enough to ensure this regex patter matches some lines in /proc/cpuinfo
egrep "vmx|svm" /proc/cpuinfo 
```

> Note: On many computers with processors supporting hardware assisted virtualization, it is necessary to activate an option in the BIOS to enable it.

### Installation

To install the necessary packages, from a terminal prompt enter:
```
sudo apt update
sudo apt install qemu-kvm libvirt-daemon-system
```

After installing libvirt-daemon-system, the user used to manage virtual machines will need to be added to the libvirt group. This is done automatically for members of the sudo group, but needs to be done in additon for anyone else that should access system wide libvirt resources. Doing so will grant the user access to the advanced networking options.

In a terminal enter: `sudo adduser $USER libvirt`

You are now ready to install a Guest operating system. Installing a virtual machine follows the same process as installing the operating system directly on the hardware.

You either need:

- a way to automate the installation
- a keyboard and monitor will need to be attached to the physical machine.
- use cloud images which are meant to self-initialize (**Multipass** and **UVTool**)

In the case of virtual machines a Graphical User Interface (GUI) is analogous to using a physical keyboard and mouse on a real computer. Instead of installing a GUI, the **virt-viewer** or **virt-manager** application can be used to connect to a virtual machine’s console using **VNC**.

### virsh

There are several utilities available to manage virtual machines and libvirt. The `virsh` utility can be used from the command line.

To list running virtual machines: `virsh list`

To start a virtual machine: `virsh start <guestname>`

Similarly, to start a virtual machine at boot: `virsh autostart <guestname>`

Reboot a virtual machine with: `virsh reboot <guestname>`

The state of virtual machines can be saved to a file in order to be restored later. The following will save the virtual machine state into a file named according to the date: `virsh save <guestname> save-my.state`

Once saved the virtual machine will no longer be running. A saved virtual machine can be restored using: `virsh restore save-my.state`

To shutdown a virtual machine do: `virsh shutdown <guestname>`

A CDROM device can be mounted in a virtual machine by entering: `virsh attach-disk <guestname> /dev/cdrom /media/cdrom`

To change the definition of a guest virsh exposes the domain via `virsh edit <guestname>`

That will allow one to edit the XML representation that defines the guest and when saving it will apply format and integrity checks on these definitions.

Editing the XML directly certainly is the most powerful way, but also the most complex one. Tools like [**Virtual Machine Manager / Viewer**](https://ubuntu.com/server/docs/virtualization-virt-tools) can help unexperienced users to do most of the common tasks.

> Note: If `virsh` (or other `vir*-tools`) shall connect to something else than the default qemu-kvm/system hypervisor one can find alternatives for the connect option in man virsh or libvirt doc.