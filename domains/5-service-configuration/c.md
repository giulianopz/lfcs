## Configure email aliases

The process of getting an email from one person to another over a network or the Internet involves many systems working together. Each of these systems must be correctly configured for the process to work. The sender uses a **Mail User Agent** (MUA), or email client, to send the message through one or more **Mail Transfer Agents** (MTA), the last of which will hand it off to a **Mail Delivery Agent** (MDA) for delivery to the recipient’s mailbox, from which it will be retrieved by the recipient’s email client, usually via a POP3 or IMAP server.

The **sendmail** smtp mail server is able to set up mailbox aliases which can be used to forward mail to specific users, or even other aliases. This can be done by simply editing a configuration file called ‘aliases’ that is generally located in **/etc/mail/aliases** (symlinked to **/etc/aliases**).

The following are some example aliases from an aliases file:
```
# Unix Workstation Support Group
ajc: ajc@indiana.edu
brier: brier@indiana.edu
leighg: leighg@indiana.edu
rtompkin: rtompkin@indiana.edu
uthuppur: uthuppur@indiana.edu

group: ajc,brier,leighg,rtompkin,uthuppur
```

The first line is a comment, ignored by sendmail, as is the blank line before the group alias. The rest of the lines are aliases, which explain a lot about how aliasing works.

The first five aliases (ajc, brier, leighg, rtompkin, and uthuppur) are for those users, and they simply redirect each user's mail to user@indiana.edu. So, instead of being delivered locally, mail to each of those users will go to them @indiana.edu (which, incidentally, is another alias on IU's post office machines, which redirects mail to the user's preferred email address here at IU). 

The last alias, group, is a bit more interesting in terms of demonstrating how aliasing works. The group alias does not correspond to an actual user of the system. Instead, it is an alias pointing to a group of users (in this case, the members of the UWSG). So, an alias can direct mail to more than one address, as long as addresses are separated by commas. 

Edit the file in your favorite text editor to suit your needs:
`sudo vi /etc/mail/aliases`

Once you have the aliases configuration file set up the way you want, you need to use that plain text file to update the random access database aliases.db file using the **newaliases** command as follows:
`sudo newaliases`

## How To Install And Configure Sendmail On Ubuntu

1. Install Sendmail:
`sudo apt-get install sendmail`

2. Configure /etc/hosts file.

Find your hostname by typing:
`hostname`

Then:
`sudo vi /etc/hosts`

On the line starting with 127.0.0.1, add the hostname to the end so it looks the same as:
`127.0.0.1 localhost <hostname>`

(You willl notice that your hostname can also be identified on the line that starts with 127.0.1.1 where it appears twice)

3. Run Sendmail’s config and answer ‘Y’ to everything:
`sudo sendmailconfig`

4. Restart Apache
`sudo service apache2 restart`

5. Using sendmail.

To quickly send an email:
`sendmail -v someone@email.com`

After hitting the enter key, on the line directly below, enter a From address (each line after you hit enter will be blank):
`From: you@yourdomain.com`

Hit enter again and type a subject:
`Subject: This is the subject field of the email`

Hit enter again and type the message:
`This is the message to be sent.`

Hit enter again. To send the email, type a ‘.‘ (period/dot) on the empty line and press enter:
`.`

Wait a few seconds and you will see the output of the email being sent.