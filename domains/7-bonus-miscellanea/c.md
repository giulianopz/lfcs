## Examine TLS handshake issues

If you have issues with TLS handshakes while trying to comunicate with a server from a client app, e.g. a Java application, first find out what the server supports:
`nmap --script ssl-enum-ciphers -p 443 my.server.com`

To see then what your JVM supports, try to run you app with the VM argument `-Djavax.net.debug=ssl:handshake:verbose`

Comparing the outputs, you could see that the server and the JVM share some cipher suites, but they fail to agree on the TLS version. You can then either configure the server to support a cipher suite and the protocol version that the JVM supports too or instruct the JVM to use what the server expects: e.g you can run your Java application with a specific TLS version by means of `-Dhttps.protocols=TLSv1.2`.

---

Web browsers, app runtimes (e.g. JRE) and app servers (e.g. Tomcat) have a trustore which collects CA certificates which is queried each time a SSL/TLS connection is established: if the server doesn't respond with a certificate issued by a recognized authority an exception is thrown. If you trust its certificate nevertheless, you can import it into the client trustore. For example, the JRE has a default trustore in $JAVA_HOME/jre/lib/security/cacerts:

1. get the root certificate in PEM format

2. convert it to the DER format: `openssl x509 -in ca.pem -inform pem -out ca.der -outform der`

3. 

More on debugging TLS handshake failures for Java [here](https://www.baeldung.com/java-ssl-handshake-failures).