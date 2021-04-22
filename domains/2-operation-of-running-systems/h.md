## Update software to provide required functionality and security

Update the system in one line: `sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y`

The command `dist-upgrade` does a little trickier work the just `upgrade`, handling upgrades which may have been held back by the latter. It is usually run before upgrading Ubuntu to a new LTS version by executing `sudo do-release-upgrade`.