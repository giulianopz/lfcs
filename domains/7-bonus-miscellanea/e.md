## Install a CA certificate

To install a new CA certificate in a server:

1. Get the root certificate in PEM format and name it with a .crt file extension.

2. Add the .crt file to the folder /usr/local/share/ca-certificates/.

3. Run: `update-ca-certificates`

4. Check if the .crt file has been concatenated to /etc/ssl/certs/ca-certificates.crt.

---

The **PEM** (originally, *Privacy Enhanced Mail*) format is the de facto file format for storing and sending cryptographic keys, certificates and other sensitive data:
```
-----BEGIN [label]-----
[base64-encoded binary data]
-----END [label]-----
```

PEM data is commonly stored in files with a `.pem` suffix, a `.cer` or `.crt` suffix (for certificates), or a `.key` suffix (for public or private keys). The label inside a PEM file ("CERTIFICATE", "CERTIFICATE REQUEST", "PRIVATE KEY" and "X509 CRL") represents the type of the data more accurately than the file suffix, since many different types of data can be saved in a `.pem` file:

A PEM file may contain multiple instances. For instance, an operating system might provide a file containing a list of trusted CA certificates, or a web server might be configured with a "chain" file containing an end-entity certificate plus a list of intermediate certificates. 