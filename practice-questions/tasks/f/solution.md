Create a *candidate* user account with the password *cert456*:
```
    echo "candidate:cert456" | chpasswd
```

Modify the sudo configuration to let the candidate account access root privileges with no password prompt:
```
sudo visudo
>> candidate ALL=(ALL) NOPASSWD:ALL 	
```

