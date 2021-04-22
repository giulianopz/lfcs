## Configure a database server

Ubuntu provides two popular database servers:

- [MySQL](https://ubuntu.com/server/docs/databases-mysql)
- [PostgreSQL](https://ubuntu.com/server/docs/databases-postgresql)

Both are popular choices among developers, with similar feature sets and performance capabilities. Historically, Postgres tended to be a preferred choice for its attention to standards conformance, features, and extensibility, whereas Mysql may be more preferred for higher performance requirements, however over time each has made good strides catching up with the other. Specialized needs may make one a better option for a certain application, but in general both are good, strong options.

They are available in the main repository and equally supported by Ubuntu.

## MySQL

MySQL is a fast, multi-threaded, multi-user, and robust SQL database server. It is intended for mission-critical, heavy-load production systems and mass-deployed software. To install MySQL, run the following command from a terminal prompt: `sudo apt install mysql-server`

Once the installation is complete, the MySQL server should be started automatically: `sudo systemctl status mysql`

ou can edit the files in `/etc/mysql/` to configure the basic settings – log file, port number, etc. For example, to configure MySQL to listen for connections from network hosts, in the file `/etc/mysql/mysql.conf.d/mysqld.cnf`, change the bind-address directive to the server’s IP address:
```
bind-address            = 192.168.0.5
```

> Note: Replace `192.168.0.5` with the appropriate address, which can be determined via `ip address show`.

After making a configuration change, the MySQL daemon will need to be restarted: `sudo systemctl restart mysql`

Whilst the default configuration of MySQL provided by the Ubuntu packages is perfectly functional and performs well there are things you may wish to consider before you proceed.

MySQL is designed to allow data to be stored in different ways. These methods are referred to as either **database or storage engines**. There are two main engines that you’ll be interested in: **InnoDB** (locking can occur on a row level basis within a table --> multiple updates can occur on a single table simultaneously) and **MyISAM** (only capable of locking an entire table for writing --> only one process can update a table at a time). Storage engines are transparent to the end user. MySQL will handle things differently under the surface, but regardless of which storage engine is in use, you will interact with the database in the same way.

For fresh installations of MySQL, you’ll want to run the DBMS’s included security script. This script changes some of the less secure default options for things like remote root logins and sample users.

Run the security script with sudo: `sudo mysql_secure_installation`

This will take you through a series of prompts where you can make some changes to your MySQL installation’s security options. The first prompt will ask whether you’d like to set up the **Validate Password Plugin**, which can be used to test the password strength of new MySQL users before deeming them valid.

If you elect to set up the Validate Password Plugin, any MySQL user you create that authenticates with a password will be required to have a password that satisfies the policy you select. The strongest policy level — which you can select by entering `2` — will require passwords to be at least eight characters long and include a mix of uppercase, lowercase, numeric, and special characters:

Regardless of whether you choose to set up the Validate Password Plugin, the next prompt will be to set a password for the MySQL root user.

> Note: Even though you’ve set a password for the root MySQL user, this user is not currently configured to authenticate with a password when connecting to the MySQL shell.

If you used the Validate Password Plugin, you’ll receive feedback on the strength of your new password. Then the script will ask if you want to continue with the password you just entered or if you want to enter a new one. Assuming you’re satisfied with the strength of the password you just entered, enter `Y` to continue the script.

From there, you can press `Y` and then `ENTER` to accept the defaults for all the subsequent questions. This will remove some anonymous users and the test database, disable remote root logins, and load these new rules so that MySQL immediately respects the changes you have made.

Once the script completes, your MySQL installation will be secured. You can now move on to creating a dedicated database user with the MySQL client.

Upon installation, MySQL creates a root user account which you can use to manage your database. This user has full privileges over the MySQL server, meaning it has complete control over every database, table, user, and so on. Because of this, it’s best to avoid using this account outside of administrative functions. This step outlines how to use the root MySQL user to create a new user account and grant it privileges.

In Ubuntu systems running MySQL 5.7 (and later versions), the root MySQL user is set to authenticate using the **auth_socket** plugin by default rather than with a password. This plugin requires that the name of the operating system user that invokes the MySQL client matches the name of the MySQL user specified in the command, so you must invoke mysql with sudo privileges to gain access to the root MySQL user: `sudo mysql`

> Note: If you installed MySQL with another tutorial and enabled password authentication for root, you will need to use a different command to access the MySQL shell. The following will run your MySQL client with regular user privileges, and you will only gain administrator privileges within the database by authenticating: `mysql -u root -p`

Once you have access to the MySQL prompt, you can create a new user with a CREATE USER statement. These follow this general syntax:
```
CREATE USER 'username'@'host' IDENTIFIED WITH authentication_plugin BY 'password';
```
 
After `CREATE USER`, you specify a username. This is immediately followed by an `@` sign and then the hostname from which this user will connect. If you only plan to access this user locally from your Ubuntu server, you can specify `localhost`. Wrapping both the username and host in single quotes isn’t always necessary, but doing so can help to prevent errors.

You have several options when it comes to choosing your user’s authentication plugin. The auth_socket plugin mentioned previously can be convenient, as it provides strong security without requiring valid users to enter a password to access the database. But it also prevents remote connections, which can complicate things when external programs need to interact with MySQL.

As an alternative, you can leave out the `WITH authentication plugin` portion of the syntax entirely to have the user authenticate with MySQL’s default plugin, **caching_sha2_password**. The MySQL documentation recommends this plugin for users who want to log in with a password due to its strong security features.

Run the following command to create a user that authenticates with caching_sha2_password. Be sure to change sammy to your preferred username and password to a strong password of your choosing: `CREATE USER 'sammy'@'localhost' IDENTIFIED BY 'password';`

> Note: There is a known issue with some versions of PHP that causes problems with caching_sha2_password. If you plan to use this database with a PHP application — phpMyAdmin, for example — you may want to create a user that will authenticate with the older, though still secure, mysql_native_password plugin instead:
`CREATE USER 'sammy'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';`

If you aren’t sure, you can always create a user that authenticates with caching_sha2_plugin and then ALTER it later on with this command:
`ALTER USER 'sammy'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';`

After creating your new user, you can grant them the appropriate privileges. The general syntax for granting user privileges is as follows:
`GRANT PRIVILEGE ON database.table TO 'username'@'host';`

The PRIVILEGE value in this example syntax defines what actions the user is allowed to perform on the specified database and table. You can grant multiple privileges to the same user in one command by separating each with a comma. You can also grant a user privileges globally by entering asterisks (`*`) in place of the database and table names. In SQL, asterisks are special characters used to represent “all” databases or tables.

To illustrate, the following command grants a user global privileges to CREATE, ALTER, and DROP databases, tables, and users, as well as the power to `INSERT`, `UPDATE`, and `DELETE` data from any table on the server. It also grants the user the ability to query data with `SELECT`, create foreign keys with the `REFERENCES` keyword, and perform `FLUSH` operations with the `RELOAD` privilege. However, you should only grant users the permissions they need, so feel free to adjust your own user’s privileges as necessary.

You can find the full list of available privileges in the official MySQL documentation.

Run this GRANT statement, replacing sammy with your own MySQL user’s name, to grant these privileges to your user:
`GRANT CREATE, ALTER, DROP, INSERT, UPDATE, DELETE, SELECT, REFERENCES, RELOAD on *.* TO 'sammy'@'localhost' WITH GRANT OPTION;`

> Note: This statement also includes `WITH GRANT OPTION`. This will allow your MySQL user to grant any that it has to other users on the system.

> Warning: Some users may want to grant their MySQL user the ALL PRIVILEGES privilege, which will provide them with broad superuser privileges akin to the root user’s privileges, like so: `GRANT ALL PRIVILEGES ON *.* TO 'sammy'@'localhost' WITH GRANT OPTION;`

Such broad privileges should not be granted lightly, as anyone with access to this MySQL user will have complete control over every database on the server.

Following this, it’s good practice to run the `FLUSH PRIVILEGES` command. This will free up any memory that the server cached as a result of the preceding CREATE USER and GRANT statements: `ì`FLUSH PRIVILEGES;`

Then you can exit the MySQL client: `exit`

In the future, to log in as your new MySQL user, you’d use a command like the following: `mysql -u sammy -p`

The `-p` flag will cause the MySQL client to prompt you for your MySQL user’s password in order to authenticate.

Finally, let’s test the MySQL installation. Regardless of how you installed it, MySQL should have started running automatically. To test this, check its status:
`sudo systemctl status mysql.service`

You’ll see output similar to the following:

If MySQL isn’t running, you can start it with `sudo systemctl start mysql`.

For an additional check, you can try connecting to the database using the `mysqladmin` tool, which is a client that lets you run administrative commands. For example, this command says to connect as a MySQL user named *sammy* (`-u sammy`), prompt for a password (`-p`), and return the version. Be sure to change sammy to the name of your dedicated MySQL user, and enter that user’s password when prompted: `sudo mysqladmin -p -u sammy version`

You should see output similar to this:
```
Output
mysqladmin  Ver 8.0.19-0ubuntu5 for Linux on x86_64 ((Ubuntu))
Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Server version      8.0.19-0ubuntu5
Protocol version    10
Connection      Localhost via UNIX socket
UNIX socket     /var/run/mysqld/mysqld.sock
Uptime:         10 min 44 sec

Threads: 2  Questions: 25  Slow queries: 0  Opens: 149  Flush tables: 3  Open tables: 69  Queries per second avg: 0.038
```

This means MySQL is up and running.

To learn more about the basic syntax of SQL queries as well as some of the more commonly-employed functions and operators, look [here](https://www.digitalocean.com/community/tutorials/introduction-to-queries-mysql).