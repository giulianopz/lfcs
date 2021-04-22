Linux administrators are responsible for the creation, deletion, and the modification of groups, as well as the group membership.
Complete the following tasks to demonstrate your ability to create and manage groups and group membership:

1. Create the *computestream* group:
```
sudo groupadd  computestream
```

2. Create a computestream folder in /exam/:
```
mkdir -p /exam/computestream
```

3. Make the *computestream* group the owner of the /exam/computestream folder:
```
chgrp -R computestream /exam/computestream
```
