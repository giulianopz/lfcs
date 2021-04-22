## Configure an HTTP server

The primary function of a web server is to store, process and deliver Web pages to clients. The clients communicate with the server sending HTTP requests. Clients, mostly via Web Browsers, request for a specific resources and the server responds with the content of that resource or an error message. The response is usually a Web page such as HTML documents which may include images, style sheets, scripts, and the content in form of text.

When accessing a Web Server, every HTTP request that is received is responded to with a content and a HTTP status code. HTTP status codes are three-digit codes, and are grouped into five different classes. The class of a status code can be quickly identified by its first digit:

- 1xx : Informational - Request received, continuing process
- 2xx : Success - The action was successfully received, understood, and accepted
- 3xx : Redirection - Further action must be taken in order to complete the request
- 4xx : Client Error - The request contains bad syntax or cannot be fulfilled
- 5xx : Server Error - The server failed to fulfill an apparently valid request

More information about status code check the RFC 2616.
Implementation

Web Servers are heavily used in the deployment of Web sites and in this scenario we can use two different implementations:

- Static Web Server: The content of the server’s response will be the hosted files “as-is”.
- Dynamic Web Server: Consist in a Web Server plus an extra software, usually an application server and a database. For example, to produce the Web pages you see in the Web browser, the- application server might fill an HTML template with contents from a database. Due to that we say that the content of the server’s response is generated dynamically.

### Installation

At a terminal prompt enter the following command:
`sudo apt install apache2`

### Configuration

Apache2 is configured by placing directives in plain text configuration files. These directives are separated between the following files and directories:

- apache2.conf: the main Apache2 configuration file. Contains settings that are global to Apache2.
- httpd.conf: historically the main Apache2 configuration file, named after the httpd daemon. In other distributions (or older versions of Ubuntu), the file might be present. In Ubuntu,all configuration options have been moved to apache2.conf and the below referenced directories, and this file no longer exists.
- conf-available: this directory contains available configuration files. All files that were previously in /etc/apache2/conf.d should be moved to /etc/apache2/conf-available.
- conf-enabled: holds symlinks to the files in /etc/apache2/conf-available. When a configuration file is symlinked, it will be enabled the next time apache2 is restarted.
- envvars: file where Apache2 environment variables are set.
- mods-available: this directory contains configuration files to both load modules and configure them. Not all modules will have specific configuration files, however.
- mods-enabled: holds symlinks to the files in /etc/apache2/mods-available. When a module configuration file is symlinked it will be enabled the next time apache2 is restarted.
- ports.conf: houses the directives that determine which TCP ports Apache2 is listening on.
- sites-available: this directory has configuration files for Apache2 Virtual Hosts. Virtual Hosts allow Apache2 to be configured for multiple sites that have separate configurations.
- sites-enabled: like mods-enabled, sites-enabled contains symlinks to the /etc/apache2/sites-available directory. Similarly when a configuration file in sites-available is symlinked,the - site configured by it will be active once Apache2 is restarted.
- magic: instructions for determining MIME type based on the first few bytes of a file.

In addition, other configuration files may be added using the Include directive, and wildcards can be used to include many configuration files. Any directive may be placed in any of these configuration files. Changes to the main configuration files are only recognized by Apache2 when it is started or restarted.

The server also reads a file containing mime document types; the filename is set by the TypesConfig directive, typically via /etc/apache2/mods-available/mime.conf, which might also include additions and overrides, and is /etc/mime.types by default.

### Basic Settings

Apache2 ships with a virtual-host-friendly default configuration. That is, it is configured with a single default virtual host (using the **VirtualHost** directive) which can be modified or used as-is if you have a single site, or used as a template for additional virtual hosts if you have multiple sites. If left alone, the default virtual host will serve as yourdefault site, or the site users will see if the URL they enter does not match the ServerName directive of any of your custom sites. To modify the default virtual host, edit the file etc/apache2/sites-available/000-default.conf.

Note 
> The term **Virtual Host** refers to the practice of running more than one web site (such as company1.example.com and company2.example.com) on a single machine. Virtual hosts can be "IP-based", meaning that you have a different IP address for every web site, or "name-based", meaning that you have multiple names running on each IP address. The fact that they are running on the same physical server is not apparent to the end user.

Note
> The directives set for a virtual host only apply to that particular virtual host. If a directive is set server-wide and not defined within the virtual host settings, the default setting is used. For example, you can define a Webmaster email address and not define individual email addresses for each virtual host.

If you wish to configure a new virtual host or site, copy that file into the same directory with a name you choose. For example:
`sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/mynewsite.conf`

Edit the new file to configure the new site using some of the directives described below.

The **ServerAdmin** directive specifies the email address to be advertised for the server’s administrator. The default value is webmaster@localhost. This should be changed to an emailaddress that is delivered to you (if you are the server’s administrator). If your website has a problem, Apache2 will display an error message containing this email address to reportthe problem to. Find this directive in your site’s configuration file in /etc/apache2/sites-available.

The **Listen** directive specifies the port, and optionally the IP address, Apache2 should listen on. If the IP address is not specified, Apache2 will listen on all IP addresses assignedto the machine it runs on. The default value for the Listen directive is 80. Change this to 127.0.0.1:80 to cause Apache2 to listen only on your loopback interface so that it will notbe available to the Internet, to (for example) 81 to change the port that it listens on, or leave it as is for normal operation. This directive can be found and changed in its ownfile, /etc/apache2/ports.conf

The **ServerName** directive is optional and specifies what FQDN your site should answer to. The default virtual host has no ServerName directive specified, so it will respond to allrequests that do not match a ServerName directive in another virtual host. If you have just acquired the domain name mynewsite.com and wish to host it on your Ubuntu server, the valueof the ServerName directive in your virtual host configuration file should be mynewsite.com. Add this directive to the new virtual host file you created earlier (/etc/apache2sites-available/mynewsite.conf).

You may also want your site to respond to www.mynewsite.com, since many users will assume the www prefix is appropriate. Use the ServerAlias directive for this. You may also usewildcards in the **ServerAlias** directive.
For example, the following configuration will cause your site to respond to any domain request ending in .mynewsite.com.
`ServerAlias *.mynewsite.com`

The **DocumentRoot** directive specifies where Apache2 should look for the files that make up the site. The default value is /var/www/html, as specified in /etc/apache2/sites-available000-default.conf. If desired, change this value in your site’s virtual host file, and remember to create that directory if necessary!

## Enable the new VirtualHost using the a2ensite utility and restart Apache2:
```
sudo a2ensite mynewsite.conf
sudo systemctl restart apache2.service
```

Note
> Be sure to replace mynewsite with a more descriptive name for the VirtualHost. One method is to name the file after the ServerName directive of the VirtualHost.

Note
> If you haven’t been using actual domain names that you own to test this procedure and have been using some example domains instead, you can at least test the functionality of this process by temporarily modifying the /etc/hosts file on your local computer:
```
<your_server_IP> example.com
```

Similarly, use the a2dissite utility to disable sites. This is can be useful when troubleshooting configuration problems with multiple VirtualHosts:
```
sudo a2dissite mynewsite
sudo systemctl restart apache2.service
```

### Default Settings

This section explains configuration of the Apache2 server default settings. For example, if you add a virtual host, the settings you configure for the virtual host take precedence for that virtual host. For a directive not defined within the virtual host settings, the default value is used.

The **DirectoryIndex** is the default page served by the server when a user requests an index of a directory by specifying a forward slash (/) at the end of the directory name.

For example, when a user requests the page http://www.example.com/this_directory/, he or she will get either the DirectoryIndex page if it exists, a server-generated directory list if it does not and the Indexes option is specified, or a Permission Denied page if neither is true. The server will try to find one of the files listed in the DirectoryIndex directive and will return the first one it finds. If it does not find any of these files and if Options Indexes is set for that directory, the server will generate and return a list, in HTML format, of the subdirectories and files in the directory. The default value, found in /etc/apache2/mods-available/dir.conf is “index.html index.cgi index.pl index.php index.xhtml index.htm”. Thus, if Apache2 finds a file in a requested directory matching any of these names, the first will be displayed.

The **ErrorDocument** directive allows you to specify a file for Apache2 to use for specific error events. For example, if a user requests a resource that does not exist, a 404 error will occur. By default, Apache2 will simply return a HTTP 404 Return code. Read /etc/apache2/conf-available/localized-error-pages.conf for detailed instructions for using ErrorDocument, including locations of example files.

By default, the server writes the transfer log to the file /var/log/apache2/access.log. You can change this on a per-site basis in your virtual host configuration files with the CustomLog directive, or omit it to accept the default, specified in /etc/apache2/conf-available/other-vhosts-access-log.conf. You may also specify the file to which errors are logged, via the ErrorLog directive, whose default is /var/log/apache2/error.log. These are kept separate from the transfer logs to aid in troubleshooting problems with your Apache2 server. You may also specify the LogLevel (the default value is “warn”) and the LogFormat (see /etc/apache2/apache2.conf for the default value).

Some options are specified on a per-directory basis rather than per-server. Options is one of these directives. A Directory stanza is enclosed in XML-like tags, like so:
```
<Directory /var/www/html/mynewsite>
...
</Directory>
```

### HTTPS Configuration

The **mod_ssl** module adds an important feature to the Apache2 server - the ability to encrypt communications. Thus, when your browser is communicating using SSL, the https:// prefix is used at the beginning of the Uniform Resource Locator (URL) in the browser navigation bar.

The mod_ssl module is available in apache2-common package. Execute the following command at a terminal prompt to enable the mod_ssl module:
`sudo a2enmod ssl`

There is a default HTTPS configuration file in /etc/apache2/sites-available/default-ssl.conf. In order for Apache2 to provide HTTPS, a certificate and key file are also needed. The default HTTPS configuration will use a certificate and key generated by the ssl-cert package. They are good for testing, but the auto-generated certificate and key should be replaced by a certificate specific to the site or server. For information on generating a key and obtaining a certificate see Certificates.

To configure Apache2 default configuration for HTTPS, enter the following:
`sudo a2ensite default-ssl`

> Note: The directories /etc/ssl/certs and /etc/ssl/private are the default locations. If you install the certificate and key in another directory make sure to change SSLCertificateFile and SSLCertificateKeyFile appropriately.

To generate a self-signed certificate:
`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/<apache-self-signed>.key -out /etc/ssl/private/<apache-self-signed>.crt`

Edit /etc/apache2/sites-available/mynewsite.conf as follows: 
```
<VirtualHost *:443>
    ServerName mynewsite.com
    DocumentRoot /var/www/mynewsite

    SSLEngine on
    SSLCertificateFile /etc/ssl/private/<apache-self-signed>.crt
    SSLCertificateKeyFile /etc/ssl/private/<apache-self-signed>.key
</VirtualHost>
```

Enable your configuration:
`sudo a2ensite mynewsite.conf`

Test it:
`sudo apache2ctl configtest`

With Apache2 now configured for HTTPS, restart the service to enable the new settings:
`sudo systemctl restart apache2.service`

> Note: Depending on how you obtained your certificate you may need to enter a passphrase when Apache2 starts.

You can access the secure server pages by typing https://mynewsite.com in your browser address bar.

> Note: You should receive a warning, since the certificate is not signed by any certificate authorities known by the browser

To redirect http to https, add to /etc/apache2/sites-available/mynewsite.conf:
```
<VirtualHost *:80>
    ServerName mynewsite.com
    Redirect / https://mynewsite.com/
</VirtualHost>
```

Teste again the configuration and reload the apache2 service.

### Sharing Write Permission

For more than one user to be able to write to the same directory it will be necessary to grant write permission to a group they share in common. The following example grants shared write permission to /var/www/html to the group “webmasters”.
```
sudo chgrp -R webmasters /var/www/html
sudo chmod -R g=rwX /var/www/html/
```

These commands recursively set the group permission on all files and directories in /var/www/html to allow reading, writing and searching of directories. Many admins find this useful for allowing multiple users to edit files in a directory tree.

> Warning: The apache2 daemon will run as the www-data user, which has a corresponding www-data group. These should not be granted write access to the document root, as this would mean that vulnerabilities in Apache or the applications it is serving would allow attackers to overwrite the served content.