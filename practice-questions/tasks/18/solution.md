Working with archives and compressed files is an integral part of the System Administrator’s job.
Perform the following tasks to demonstrate your ability to work with archives and compressed files:

1. Extract all files from archive file ​/opt/SAMPLE001.zip into target directory ​/opt/SAMPLE001:
```
unzip /opt/SAMPLE001.zip -d ​/opt/
```
2. Create a tar archive file ​/opt/SAMPLE0001.tar containing all files in the directory ​/opt/SAMPLE001:
```
tar cfv ​/opt/SAMPLE0001.tar ​/opt/SAMPLE001
```
3. Compress the tar archive file ​/opt/SAMPLE0001.tar using the ​bzip2​ compression algorithm:
```
​bzip2​ -k ​/opt/SAMPLE0001.tar
```
4. Compress the tar archive file ​/opt/SAMPLE0001.tar using the ​xz​ compression algorithm:
```
xz ​-k /opt/SAMPLE0001.tar
```

Make sure that the uncompressed archive file/opt/SAMPLE0001.tar​ is not removed after creating the compressed versions of the archive file!
```
test -e ​/opt/SAMPLE0001.tar && echo -e "OK: the file still exists" || echo -e "KO: you lost the original tarball"
```