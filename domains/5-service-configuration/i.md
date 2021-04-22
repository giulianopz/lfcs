## Configure HTTP server log files

By default on Debian-based distributions such as Ubuntu , access and error logs are located in the /var/log/apache2 directory. On CentOS the log files are placed in /var/log/httpd directory.

## Reading and Understanding the Apache Log Files

The log files can be opened and parsed using standard commands like cat , less , grep , cut , awk , and so on.

Here is an example record from the access log file that uses the Debian' combine log format:
```
192.168.33.1 - - [08/Jan/2020:21:39:03 +0000] "GET / HTTP/1.1" 200 6169 "-" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36"
```

Let’s break down what each field of the record means:

- `%h` (192.168.33.1) - The Hostname or the IP address of the client making the request.
- `%l` (-) - Remote logname. When the user name is not set, this field shows -.
- `%u` (-) - If the request is authenticated, the remote user name is shown.
- `%t` ([08/Jan/2020:21:39:03 +0000]) - Local server time.
- `\"%r\"` ("GET / HTTP/1.1") - First line of request. The request type, path, and protocol.
- `%>s` (200) - The final server response code. If the > symbol is not used and the request has been internally redirected, it will show the status of the original request.
- `%O` (396) - The size of server response in bytes.
- `\"%{Referer}i\"` ("-") - The URL of the referral.
- `\"%{User-Agent}i\"` (Mozilla/5.0 ...) - The user agent of the client (web browser).

## Virtual Hosts and Global Logging

The logging behavior and the location of the files can be set either globally or per virtual host basis.

Then the CustomLog or ErrorLog directives are set in the main server context, the server writes all log messages to the same access and error log files. Otherwise, if the directives are placed inside a <VirtualHost> block, only the log messages for that virtual host are written to the specified file.

The log directive set in the <VirtualHost> block overrides the one set in the server context.

Virtual hosts without CustomLog or ErrorLog directives will have their log messages written to the global server logs.

The CustomLog directive defines the location of the log file and the format of the logged messages.

The most basic syntax of the **CustomLog** directive is as follows:
`CustomLog log_file format [condition];`

The second argument, format specifies the format of the log messages. It can be either an explicit format definition or a nickname defined by the LogFormat directive.
```
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
CustomLog logs/access.log combined
```

The third argument `[condition]` is optional and allows you to write log messages only when a specific condition is met.

The **ErrorLog** directive defines the name location of the error log. It takes the following form:
`ErrorLog log_file`

For better readability, it is recommended to set separate access and error log files for each virtual host. Here is an example:
```
<VirtualHost *:80>
     ServerName example.com
     ServerAlias www.example.com
     ServerAdmin webmaster@example.com
     DocumentRoot /var/www/example.com/public
     LogLevel warn
     ErrorLog /var/www/example.com/logs/error.log
     CustomLog /var/www/example.com/logs/access.log combined
</VirtualHost>
```

If your server is low on resources and you have a busy website, you might want to disable the access log. To do that, simply comment out or remove the CustomLog directive from the main server configuration and virtual server sections.

If you want to turn off the access log only for one virtual host, set the first argument of the CustomLog directive to /dev/null:
`CustomLog /dev/null combined`


Restart the Apache service for the changes to take effect.

### Configure logging level

The **LogLevel** parameter sets the level of logging. Below are levels listed by their severity (from low to high):

- trace1 - trace8 - Trace messages.
- debug - Debugging messages.
- info - Informational messages.
- notice - Notices.
- warn - Warnings.
- error - Errors while processing a request.
- crit - Critical issues. Requires a prompt action.
- alert - Alerts. Action must be taken immediately.
- emerg - Emergency situation. The system is in an unusable state.

Each log level includes the higher levels. For example, if you set the log level to warn, Apache also writes the error, crit, alert, and emerg messages.

When the LogLevel parameter is not specified, it defaults to warn. It is recommended to set the level to at least crit.

