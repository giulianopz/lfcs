## Install a CA certificate

The **PEM** (originally, *Privacy Enhanced Mail*) format is the de facto file format for storing and sending cryptographic keys, certificates and other sensitive data:
```
-----BEGIN [label]-----
[base64-encoded binary data]
-----END [label]-----
```

PEM data is commonly stored in files with a `.pem` suffix, a `.cer` or `.crt` suffix (for certificates), or a `.key` suffix (for public or private keys). The label inside a PEM file ("CERTIFICATE", "CERTIFICATE REQUEST", "PRIVATE KEY" and "X509 CRL") represents the type of the data more accurately than the file suffix, since many different types of data can be saved in a `.pem` file:

A PEM file may contain multiple instances. For instance, an operating system might provide a file containing a list of trusted CA certificates, or a web server might be configured with a "chain" file containing an end-entity certificate plus a list of intermediate certificates. 

> Note: A certification authority (**CA**) is an entity that issues digital certificates (usually encoded in **X.509** standard). A CA acts as a trusted third party—trusted both by the subject (owner) of the certificate and by the party relying upon the certificate.

> Note: X.509 is a series of standards, while PEM is just X.509 object representation in a file (encoding). Literally any data can be represented in PEM format. Anything that can be converted to a byte array (and anything can be, because RAM is a very large byte array) can be represented in PEM format.

To install a new CA certificate in a server:

1. Get the root certificate in PEM format and name it with a .crt file extension.

2. Add the .crt file to the folder /usr/local/share/ca-certificates/.

3. Run: `update-ca-certificates`

4. Check if the .crt file has been concatenated to /etc/ssl/certs/ca-certificates.crt.

You can import CA certificates in one line by running:
```
sudo bash -c "echo -n | openssl s_client -showcerts -connect ${hostname}:${port} \
2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
>> `curl-config --ca`"
```

> Note: You may need to install the following package: ``sudo apt-get install libcurl4-openssl-dev`

Chances are that you will face common issues like `server certificate verification failed. CAfile: /etc/ssl/certs/ca-certificates.crt CRLfile: none` when cloning a repository.

To solve such problems, first make sure first that you have certificates installed in /etc/ssl/certs.

If not, reinstall them: `sudo apt-get install --reinstall ca-certificates`

Since that package does not include root certificates, add them:
```
sudo mkdir /usr/local/share/ca-certificates/cacert.org
sudo wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt
sudo update-ca-certificates
```

Make sure your git configuration does reference those CA certs: `git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt`

Alternatively, to temporarily disable SSL: `git config --global http.sslverify false`

> Note: Another cause of this problem might be that your clock might be off. Certificates are time sensitive. You might consider installing NTP to automatically sync the system time with trusted internet timeservers from the global NTP pool (see NTP [guide](../4-networking/f.md) in this repo).