## Automate Login via SSH

You can use [expect](https://linux.die.net/man/1/expect) for automating the interaction with CLI prompts. It uses expectations captured in the form of regular expressions, which it can respond to by sending out responses without any user intervention.

Let's say you want to automate the login into a home server for which you have to provide the passphrase of your public key (`id_rsa`). If so, you just need a simple script like the following:
```
#!/usr/bin/expect
set timeout 60
spawn ssh YOUR_USERNAME_HERE@[lindex $argv 0]
expect "Are you sure you" {
        send "yes\r"
}
expect "*?assphrase" {
        send "YOUR_PASSWORD_HERE\r"
        }
interact
```

In the above script:
- `lindex` gets the individual elements from a positional argument list
  - `$argv 0` should be the IP address of your server
- `spawn` invokes a new process or session
- `expect` waits for the spawned process output in the expected pattern
- `send` writes to the spawned process' stdin
- `interact` gives the control back to the current process so that stdin is sent to the current process, and subsequently, stdout and stderr are returned.

If your home server doesn't have a static IP address, you could automate the IP discovery by scanning your own home network with an alias in your `.bash_aliases`:
```
alias sshlogin='for ip in $(nmap -sn 192.168.1.1/24 | grep -Po "(?<=Nmap scan report for )\d+\.\d+\.\d+\.\d+"); do ./ABOVE_SCRIPT_NAME.sh $ip; done'
```

> Note: Also the generation of such script can be automated with [autoexpect](https://www.baeldung.com/linux/logging-into-ssh-server#3-using-autoexpect).
>
> Note: The script above contains the password in plain text. This can be safe only at home, provided that you really configured your home network and home devices in a secured way that protexts you from any security threats. Using an [encrypted file](https://www.baeldung.com/linux/logging-into-ssh-server#2-using-file-in-encrypted-form) to store you password should be much safer.
