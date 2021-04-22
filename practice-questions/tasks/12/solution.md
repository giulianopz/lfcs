Correct the ​projectadmin​ user account so that logins are possible using the password ​_onetime43_​. Set the home directory to ​/home/projectadmin​:
```
sudo usermod ​projectadmin​ -d "​/home/projectadmin​" -m 
sudo passwd ​projectadmin​ # ​_onetime43_​
```

To force the user to change his/her pwd at the next login:
```
sudo passwd -e  ​projectadmin​
```