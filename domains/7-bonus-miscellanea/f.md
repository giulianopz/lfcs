## Create a self-signed SSL certificate for Apache web server

1. Prerequisites:
```
sudo apt install apache2
sudo ufw allow "Apache Full"
sudo a2enmod ssl
sudo systemctl restart apache2
```

2. Generate the certificate:
`sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout [/etc/ssl/private/apache-selfsigned.key] -out [/etc/ssl/certs/apache-selfsigned.crt]`

> Note: `-nodes` is for skipping passphrase, `-keyout` is for the private key destination, while `-out` for the certificate destination.

3. Configure Apache to use SSL:
`vi /etc/apache2/sites-available/[your-domain-or-ip].conf`

Insert into it:
```
<Virtual Host *:443>
    ServerName [your-domain-or-ip]
    DocumentRoot [/var/www/your-domain-or-ip]

    SSLEngine on
    SSLCertificateFile [/etc/ssl/certs/apache-selfsigned.crt]
    SSLCertificateKeyFIle [/etc/ssl/private/apache-selfsigned.key]
</Virtual Host>
```

> Note: `ServerName` must match the **Common Name** you choose when creating the certificate.

4. Add a stub web page:
```
mkdir [/var/www/your-domain-or-ip]
echo "<h1>it worked</h1>" > /var/www/[your-domain-or-ip]/index.html
```

5. Enable the configuration:
```
sudo a2ensite [your-domain-or-ip].conf
sudo apache2ctl configtest
# if it prints out "syntax ok"
sudo systemctl reload apache2
```

6. Try to connect to your site with a browser: you should receive a warning since your certificate is not signed by any of its known certificate authorities.

7. Redirect http to https, adding to `[your-domain-or-ip].conf`:
```
<Virtual Host *:80>
    ServerName [your-domain-or-ip]
    Redirect / https://[your-domain-or-ip]/
</Virtual Host>
```

8. Re-test your configuration an restart apache daemon:
```
sudo apache2ctl configtest
sudo systemctl reload apache2
```