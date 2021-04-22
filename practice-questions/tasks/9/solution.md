Create a new user account with the following attributes:

1. Username is ​harry​.
2. Password is ​magic​.
3. This user’s home directory is defined as/home/school/harry/​.
4. This new user is a member of the existing ​students group.
5. The ​/home/school/harry/binaries/​ directory is part of the ​PATH​ variable

```
sudo mkdir /home/school
sudo useradd harry -d /home/school/harry -m -G students
sudo passwd harry # magic
sudo sh -c 'echo "PATH=$PATH:/home/school/harry/binaries/" >> /home/school/harry/.bashrc'
```