## Configure an IMAP and IMAPS service

**Dovecot** is a Mail Delivery Agent, written with security primarily in mind. It supports the major mailbox formats: **mbox** or **Maildir**. This section explains how to set it up as an IMAP or POP3 server.

### Installation

To install a basic Dovecot server with common POP3 and IMAP functions, run the following command:
`sudo apt install dovecot-imapd dovecot-pop3d`

There are various other Dovecot modules including dovecot-sieve (mail filtering), dovecot-solr (full text search), dovecot-antispam (spam filter training), dovecot-ldap (user directory).

### Configuration

To configure Dovecot, edit the file /etc/dovecot/dovecot.conf and its included config files in /etc/dovecot/conf.d/. By default all installed protocols will be enabled via an include directive in /etc/dovecot/dovecot.conf:
`!include_try /usr/share/dovecot/protocols.d/*.protocol`

IMAPS and POP3S are more secure because they use SSL encryption to connect. A basic self-signed ssl certificate is automatically set up by package ssl-cert and used by Dovecot in /etc/dovecot/conf.d/10-ssl.conf.

By default mbox format is configured, if required you can also use Maildir. More about that can be found in the comments in /etc/dovecot/conf.d//10-mail.conf. Also see the Dovecot web site to learn about further benefits and details.

Make sure to also configure your Mail Transport Agent (MTA) to transfer the incoming mail to the selected type of mailbox.

Once you have configured Dovecot, restart its daemon in order to test your setup:
`sudo service dovecot restart`

Try to log in with the commands telnet localhost pop3 (for POP3) or telnet localhost imap2 (for IMAP). You should see something like the following:
```
telnet localhost pop3
> Trying 127.0.0.1...
> Connected to localhost.localdomain.
> Escape character is '^]'.
> +OK Dovecot ready.
```

### Dovecot SSL Configuration

Dovecot is configured to use SSL automatically by default, using the package ssl-cert which provides a self signed certificate.

You can instead generate your own custom certificate for Dovecot using openssh, for example:
```
sudo openssl req -new -x509 -days 1000 -nodes -out "/etc/dovecot/dovecot.pem" \
    -keyout "/etc/dovecot/private/dovecot.pem"
```

See certificates-and-security for more details on creating custom certificates.

Then edit /etc/dovecot/conf.d/10-ssl.conf and amend following lines to specify Dovecat use these custom certificates :
```
ssl_cert = </etc/dovecot/private/dovecot.pem
ssl_key = </etc/dovecot/private/dovecot.key
```

You can get the SSL certificate from a Certificate Issuing Authority or you can create self-signed one (see certificates-and-security for details). Once you create the certificate, you will have a key file and a certificate file that you want to make known in the config shown above.

### Firewall Configuration for an Email Server

To access your mail server from another computer, you must configure your firewall to allow connections to the server on the necessary ports:

- IMAP - 143
- IMAPS - 993
- POP3 - 110
- POP3S - 995
