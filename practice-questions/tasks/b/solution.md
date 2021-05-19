1. Create a bash shell script named certscript.sh under /home/student/apps/:
```
touch certscript.sh
```

2. Make sure the script can be invoked as ./certscript.sh:
```
chmod a+x certscript.sh
```

3. The first line of output from the script should consist of the name of the user who invoked it.

4. The second line of output should contain the IP address of the default gateway:
```
vi certscript.sh

> #!/bin/bash
> 
> printf '%s\n' "${SUDO_USER:-$USER}"
> 
> echo $(ip route | grep default | cut -d ' ' -f 3)

./certscript.sh
```
