## Debugging TLS handshake issues

TLS handshakes are a mechanism by which a client and server establish the trust and logistics required to secure their connection over the network.

> Note: **SSL** is now-deprecated predecessor of **TLS**, but some people still tend to refer to the current implementation of the protocol with *SSL* for historical reasons.

This is a very orchestrated procedure and understanding the details of this can help understand why it often fails, which we intend to cover in the next section.

Typical steps in an TLS handshake are:

- Client provides a list of possible TLS version and cipher suites to use
- Server agrees on a particular TLS version and cipher suite, responding back with its certificate
- Client extracts the public key from the certificate responds back with an encrypted “pre-master key”
- Server decrypts the “pre-master key” using its private key
- Client and server compute a “shared secret” using the exchanged “pre-master key”
- Client and server exchange messages confirming the successful encryption and decryption using the “shared secret”

While most of the steps are the same for any SSL handshake, there is a subtle difference between one-way and two-way TLS: in the latter both the client and server must present and accept each other's public certificates before a successful connection can be established.

If you have issues with TLS handshakes while trying to comunicate with a server from a client app, e.g. a Java application, first find out what the server supports:
`nmap --script ssl-enum-ciphers -p 443 my.server.com`

To see then what your JVM supports, try to run you app with the VM argument `-Djavax.net.debug=ssl:handshake:verbose`

Comparing the outputs, you could see that the server and the JVM share some cipher suites, but they fail to agree on the TLS version. You can then either configure the server to support a cipher suite and the protocol version that the JVM supports too or instruct the JVM to use what the server expects: e.g you can run your Java application with a specific TLS version by means of `-Dhttps.protocols=TLSv1.2`.

---

### TLS handshake failures in Java

Private and public keys are used in asymmetric encryption. A public key can have an associated certificate. A certificate is a document that verifies the identity of the person, organization or device claiming to own the public key. A certificate is typically digitally signed by the verifying party as proof. 

In most cases, we use a keystore and a truststore when our application needs to communicate over SSL/TLS. 

In disussions about Java the two terms like *keystore* and *truststore* are often used interchangeably since the same file can act as keystore as well as truststore: it's just a matter of pointing `javax.net.ssl.keyStore` and `javax.net.ssl.trustStore` properties to that file but there is a difference between keystore and truststore. Generally speaking, keystores hold keys that our application owns that we can use to prove the integrity of a message and the authenticity of the sender, say by signing payloads. A truststore is the opposite – while a keystore typically holds onto certificates that identify us, a truststore holds onto certificates that identify others.

Usually, these are password-protected files that sit on the same file system as our running application. The default format used for these files is **JKS** until Java 8.

Since Java 9, though, the default keystore format is PKCS12. The biggest difference between JKS and **PKCS12** is that JKS is a format specific to Java, while PKCS12 is a standardized and language-neutral way of storing encrypted private keys and certificates.

Not only Java, but also Web browsers and and application servers (e.g. Tomcat) have a truststore which collects CA certificates which is queried each time a SSL/TLS connection is established: if the server doesn't respond with a certificate issued by a recognized authority an exception is thrown (e.g javax.net.ssl.SSLHandshakeException). If you trust its certificate nevertheless, you can import it into the client truststore. For example, Java has bundled a truststore called **cacerts** and it resides in the **$JAVA_HOME/jre/lib/security** directory:

1. get the root certificate in PEM format

2. convert it to the DER format: `openssl x509 -in [ca.pem] -inform pem -out [ca.der] -outform der`

3. validate the root certificate content: `keytool -v -printcert -file [ca.cert]`

4. import the root certificate into the JVM truststore: 
`keytool -importcert -alias [startssl] -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass [changeit] -file [ca.der]`

> Note: `changeit` is the default password for the JVM truststore, you should use a new one for a application deployed in production.

5. verify that the root certificate has been imported: 
`keystore -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass [changeit] -list | grep [startssl]`

You can learn more on the most frequent handshake failure scenarios in Java [here](https://www.baeldung.com/java-ssl-handshake-failures).