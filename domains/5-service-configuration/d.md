## Configure SSH servers and clients

1. Installation

Installation of the OpenSSH client and server applications is simple. To install the OpenSSH client applications on your Ubuntu system, use this command at a terminal prompt:
`sudo apt install openssh-client`

To install the OpenSSH server application, and related support files, use this command at a terminal prompt:
`sudo apt install openssh-server`

2. Configuration

You may configure the default behavior of the OpenSSH server application, sshd, by editing the file **/etc/ssh/sshd_config**. For information about the configuration directives used in this file, you may view the appropriate manual page with the following command, issued at a terminal prompt:
`man sshd_config`

There are many directives in the sshd configuration file controlling such things as communication settings, and authentication modes. The following are examples of configuration directives that can be changed by editing the /etc/ssh/sshd_config file.

> Tip: Prior to editing the configuration file, you should make a copy of the original file and protect it from writing so you will have the original settings as a reference and to reuse as necessary. Copy the /etc/ssh/sshd_config file and protect it from writing with the following commands, issued at a terminal prompt:
```
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original
sudo chmod a-w /etc/ssh/sshd_config.original
```

Furthermore since losing an ssh server might mean losing your way to reach a server, check the configuration after changing it and before restarting the server:
`sudo sshd -t -f /etc/ssh/sshd_config`

The following are examples of configuration directives you may change.

To set your OpenSSH to listen on TCP port 2222 instead of the default TCP port 22, change the Port directive as such:
`Port 2222`

To make your OpenSSH server display the contents of the /etc/issue.net file as a pre-login banner, simply add or modify this line in the /etc/ssh/sshd_config file:
`Banner /etc/issue.net`

After making changes to the /etc/ssh/sshd_config file, save the file, and restart the sshd server application to effect the changes using the following command at a terminal prompt:
`sudo systemctl restart sshd.service`

> Warning: Many other configuration directives for sshd are available to change the server application’s behavior to fit your needs. Be advised, however, if your only method of access to a server is ssh, and you make a mistake in configuring sshd via the /etc/ssh/sshd_config file, you may find you are locked out of the server upon restarting it. Additionally, if an incorrect configuration directive is supplied, the sshd server may refuse to start, so be extra careful when editing this file on a remote server.

3. SSH Keys

SSH allow authentication between two hosts without the need of a password. SSH key authentication uses a private key and a public key.

To generate the keys, from a terminal prompt enter:
`ssh-keygen -t rsa`

This will generate the keys using the RSA Algorithm. At the time of this writing, the generated keys will have 3072 bits. You can modify the number of bits by using the -b option. For example, to generate keys with 4096 bits, you can do:
`ssh-keygen -t rsa -b 4096`

During the process you will be prompted for a password. Simply hit Enter when prompted to create the key.

By default the public key is saved in the file ~/.ssh/id_rsa.pub, while ~/.ssh/id_rsa is the private key. Now copy the id_rsa.pub file to the remote host and append it to ~/.ssh/authorized_keys by entering:
`ssh-copy-id <username>@<remotehost>`

Please, note that this requires that password authentication is enabled on the remote ssh server.

Finally, double check the permissions on the authorized_keys file, only the authenticated user should have read and write permissions. If the permissions are not correct change them by:
`chmod 600 .ssh/authorized_keys`

You should now be able to SSH to the host without being prompted for a password.

4. Import keys from public keyservers

These days many users have already ssh keys registered with services like launchpad or github. Those can be easily imported with:
`ssh-import-id <username-on-remote-service>`

The prefix `lp:` is implied and means fetching from launchpad, the alternative `gh:` will make the tool fetch from github instead.

5. Two factor authentication with U2F/FIDO

OpenSSH 8.2 added support for U2F/FIDO hardware authentication devices. These devices are used to provide an extra layer of security on top of the existing key-based authentication, as the hardware token needs to be present to finish the authentication.

It’s very simple to use and setup. The only extra step is generate a new keypair that can be used with the hardware device. For that, there are two key types that can be used: ecdsa-sk and ed25519-sk. The former has broader hardware support, while the latter might need a more recent device.

Once the keypair is generated, it can be used as you would normally use any other type of key in openssh. The only requirement is that in order to use the private key, the U2F device has to be present on the host.

For example, plug the U2F device in and generate a keypair to use with it:
```
$ ssh-keygen -t ecdsa-sk
Generating public/private ecdsa-sk key pair.
You may need to touch your authenticator to authorize key generation. <-- touch device
Enter file in which to save the key (/home/ubuntu/.ssh/id_ecdsa_sk): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/ubuntu/.ssh/id_ecdsa_sk
Your public key has been saved in /home/ubuntu/.ssh/id_ecdsa_sk.pub
The key fingerprint is:
SHA256:V9PQ1MqaU8FODXdHqDiH9Mxb8XK3o5aVYDQLVl9IFRo ubuntu@focal
```

Now just transfer the public part to the server to ~/.ssh/authorized_keys and you are ready to go:
```
$ ssh -i .ssh/id_ecdsa_sk ubuntu@focal.server
Confirm user presence for key ECDSA-SK SHA256:V9PQ1MqaU8FODXdHqDiH9Mxb8XK3o5aVYDQLVl9IFRo <-- touch device
Welcome to Ubuntu Focal Fossa (GNU/Linux 5.4.0-21-generic x86_64)
(...)
ubuntu@focal.server:~$
```