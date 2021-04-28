## Examine TLS handshake issues

If you have issues with TLS handshakes while trying to comunicate with a server from a client app, e.g. a Java application, first find out what the server supports:
```
nmap --script ssl-enum-ciphers -p 443 google.com
>Starting Nmap 7.80 ( https://nmap.org ) at 2021-04-28 00:06 CEST
>Nmap scan report for google.com (142.250.184.78)
>Host is up (0.014s latency).
>Other addresses for google.com (not scanned): 2a00:1450:4002:807::200e
>rDNS record for 142.250.184.78: mil41s03-in-f14.1e100.net
>
>PORT    STATE SERVICE
>443/tcp open  https
>| ssl-enum-ciphers: 
>|   TLSv1.0: 
>|     ciphers: 
>|       TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA (ecdh_x25519) - A
>|       TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA (ecdh_x25519) - A
>|       TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA (ecdh_x25519) - A
>|       TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA (ecdh_x25519) - A
>|       TLS_RSA_WITH_AES_128_CBC_SHA (rsa 2048) - A
>|       TLS_RSA_WITH_AES_256_CBC_SHA (rsa 2048) - A
>|       TLS_RSA_WITH_3DES_EDE_CBC_SHA (rsa 2048) - C
>|     compressors: 
>|       NULL
>|     cipher preference: server
>|     warnings: 
>|       64-bit block cipher 3DES vulnerable to SWEET32 attack
>|   TLSv1.1: 
>|     ciphers: 
>|       TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA (ecdh_x25519) - A
>|       TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA (ecdh_x25519) - A
>|       TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA (ecdh_x25519) - A
>|       TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA (ecdh_x25519) - A
>|       TLS_RSA_WITH_AES_128_CBC_SHA (rsa 2048) - A
>|       TLS_RSA_WITH_AES_256_CBC_SHA (rsa 2048) - A
>|       TLS_RSA_WITH_3DES_EDE_CBC_SHA (rsa 2048) - C
>|     compressors: 
>|       NULL
>|     cipher preference: server
>|     warnings: 
>|       64-bit block cipher 3DES vulnerable to SWEET32 attack
>|   TLSv1.2: 
>|     ciphers: 
>|       TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA (ecdh_x25519) - A
>|       TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 (ecdh_x25519) - A
>|       TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA (ecdh_x25519) - A
>|       TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 (ecdh_x25519) - A
>|       TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256 (ecdh_x25519) - A
>|       TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA (ecdh_x25519) - A
>|       TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (ecdh_x25519) - A
>|       TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA (ecdh_x25519) - A
>|       TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (ecdh_x25519) - A
>|       TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256 (ecdh_x25519) - A
>|       TLS_RSA_WITH_3DES_EDE_CBC_SHA (rsa 2048) - C
>|       TLS_RSA_WITH_AES_128_CBC_SHA (rsa 2048) - A
>|       TLS_RSA_WITH_AES_128_GCM_SHA256 (rsa 2048) - A
>|       TLS_RSA_WITH_AES_256_CBC_SHA (rsa 2048) - A
>|       TLS_RSA_WITH_AES_256_GCM_SHA384 (rsa 2048) - A
>|     compressors: 
>|       NULL
>|     cipher preference: client
>|     warnings: 
>|       64-bit block cipher 3DES vulnerable to SWEET32 attack
>|_  least strength: C
>
>Nmap done: 1 IP address (1 host up) scanned in 1.35 seconds
```

To see then what your JVM supports, try to run you app with the VM argument `-Djavax.net.debug=ssl:handshake:verbose`

Web browsers, app runtimes (e.g. JRE) and app servers (e.g. Tomcat) have a trustore which collects CA certificates which is queried each time a SSL/TLS connection is established: if the server doesn't respond with a certificate issued by a recognized authority an exception is thrown. If you trust its certificate nevertheless, you can import it into the client trustore. For example, the JRE has a default trustore in $JAVA_HOME/jre/lib/security/cacerts:

1. get the root certificate in PEM format

2. convert it to the DER format: `openssl x509 -in ca.pem -inform pem -out ca.der -outform der`

3. 

More on debugging TLS handshake failures for Java [here](https://www.baeldung.com/java-ssl-handshake-failures).