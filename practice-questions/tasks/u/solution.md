A data directory is not used anymore and is about to be archived. You have been asked to identify and remove some files, before archiving takes place.
Perform the following tasks to demonstrate your ability to search for files given various criteria: 

1. Find all executable files in the directory /srv/SAMPLE002​ and remove them.
    ```
    find /srv/SAMPLE002/ -executable -type f -exec rm {} \;
    ```
2. Find all files in the directory ​/srv/SAMPLE002​, which have not been accessed during the last month and remove them.
    ```
    find /srv/SAMPLE002/ -type f -atime +30 -exec rm {} \;
    ```
3. Find all empty directories in the directory/srv/SAMPLE002​ and remove them. 
    ```
    find /srv/SAMPLE002/ -type d -empty -exec rm -rf {} \;
    ```
4. Find all files in the directory ​/srv/SAMPLE002​ with a file extension of ​.tar​. Write a list of matching filenames, one per line, to the file /opt/SAMPLE002/toBeCompressed.txt​, which has already been created. Ensure that you specify a relative path to each file, using ​/srv/SAMPLE002​ as the base directory for the relative path.
    ```
    find /srv/SAMPLE002 -name "*.tar" -printf "./%P\n" >> /opt/SAMPLE002/toBeCompressed
    ```