Find the name of the service which uses TCP port ​2605​, as documented in ​/etc/services​, and write the service name tothe file ​/home/student/port-2605.txt​. Find all of the portsused for TCP services ​IMAP3​ and ​IMAPS​, again as documentedin ​/etc/services​, and write those port numbers to the file /home/student/imap-ports.txt​:
```
grep 2605 /etc/services | cut -f 1 > /home/student/port-2605.txt
grep -iPo "(?<=(imaps|imap3)\t\t)\d+" /etc/services > /home/student/imap-ports.txt
```