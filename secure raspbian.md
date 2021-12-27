# Security
For your own safety it is recommended to do the following steps. This will improve your systems security and make it more and more difficult for hackers to intrude.

## Change your password
The standard password "raspberry" is known to everybody. Change it with 
```bash
passwd
```
and enter your new password

## Update your RPi (frequently)
Every time in a while you should update your RPi for newest security patches.
```bash
sudo apt update
sudo apt full-upgrade
sudo apt install rpi-eeprom raspberrypi-kernel-headers
sudo apt autoremove
```

If the bootloader didn't have the OTG availability you can now add the lines of code mentioned in [OTG](OTG.md) and restart.

### automate updates
You can use the package `unattended-upgrades` to run updates in a frequent base without having to do it all by your own

1. Install the package `sudo apt install unattended-upgrades`
2. Open the config file `sudo nano /etc/apt/apt.conf.d/50unattended-upgrades`
3. Change the file at your needs. I recommend to uncomment `Unattended-Upgrade::Mail "root";` to send an email at updates and errors (if you configured a mail server)
4. Edit the periodic upgrades by editing `sudo nano /etc/apt/apt.conf.d/02periodic`. Insert the following lines, this runs updates every day 
    ``bash
    APT::Periodic::Enable "1";
    APT::Periodic::Update-Package-Lists "1";
    APT::Periodic::Download-Upgradeable-Packages "1";
    APT::Periodic::Unattended-Upgrade "1";
    APT::Periodic::AutocleanInterval "1";
    APT::Periodic::Verbose "2";
    ```
5. to show the configuration and debug error you can run `sudo unattended-upgrades -d`

## Change the standard user
Create a new user `sudo adduser <username>` and grant sudo-Rights `sudo adduser <username> sudo`. After that copy all files and rights owned by the `pi` user to your new user:
```bash
sudo cp -r /home/pi/ /home/<username>/
sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi <username>
```

Check if your new user is available and can handle everything, log into your new user via SSH `<username>@raspberrypi.local` and after that, delete the old `pi` user:
```bash
sudo pkill -u pi #kills all processes by pi
sudo deluser -remove-home pi
```

If you are unsure with deletion, you can also just deactivate the account:
```bash
usermod -L pi
passwd -l pi
```
With that the user `pi` is can no longer log into his account. 

## Create and use SSH keys
To be (at our time) absolutely save against password/brute-force attacks you can use SSH keys. Those are used to identify one computer to another.

On your RPi delete the pre-generated SSH keys and create new ones at your hand:
```bash
# delete keys from standard user
rm -rf /home/pi/.ssh
# delete keys from all other users
rm -rf /home/<username>/.ssh
# delete hostname keys; standard hostname is raspberry
ssh-keygen -R <hostname>
# create new keys; choose your own config if you want
ssh-keygen -t ecdsa -b 521
```

Now to authenticate your computer to the RPi we start at your computer
1. create your SSH Keypair on your Computer: `ssh-keygen -t ecdsa -b 521`
2. Copy the generated public key to your RPi: `cp ~/.ssh/id_ecdsa.pub <username>@raspberrypi.local:/home/<username>/publicKey.pub`
3. add the public key to your RPi-Keychain: `cat /home/<username>/publickey.pub >> ~/.ssh/authorized_keys`
4. reconnect to your RPi again. Now you shouldn't be asked a password as the SSH key was used to identify

Alternatifly, if ssh-copy-id is available you can just `ssh-copy-id <USERNAME>@<IP-ADDRESS>` to copy and register your SSH Key to your RPi.

After SSH-key-exchange you can now log into your RPi without the need of a password. You can now (optional) disable the password based login. To do that change the ssh configuration file `sudo nano /etc/ssh/sshd_config`
```bash[/etc/ssh/sshd_config]
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no
```
Save and restart


## SSH: disable root login
As access with root privileges is a great thread you can disable it. Without root access you can log in as your normal user and then use `sudo` to gain root priviledges. By default the root access is disabled, check that:
- open the SSH config file `sudo nano /etc/ssh/sshd_config`
- search the following line `#PermitRootLogin prohibit-password`
- prepend a `#` if not exist already
- save and restart SSH `sudo service ssh restart`

It's also possible to block certain users from using SSH. Therefore use the lines `AllowUsers <username>` and `DenyUsers <username>` in the `/etc/ssh/sshd_config` file

## SSH: change the port
SSH uses the default port 22. Most bots and hackers will try to penetrate that port at first. You can change the port to make it more difficult to hack you.
- Edit the config file `sudo nano /etc/ssh/sshd_config`
- search the line `#Port 22`
- exchange the set number by your port number, e.g. `Port 1111` (also remove the `#`)
  - make sure the port is not used by other services, heres a list: [List of port numbers](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers)
- save and restart SSH `sudo service ssh restart`

To access your RPi with your custom port use the '-p' option:
```bash
ssh <username>@<ipadress> -p 1111
```

Don't forget to update your firewall rules (if installed) and check the connection before closing it to prevent errors.

## Remove unused network services
Nearly all OS have network services preinstalled and activated. Most of them are useful and you want to keep them. But there may also be some you want to remove. List all running network-services with `sudo ss -atpu`.

As example it could look like that:
```bash
tcp LISTEN 0 128 *:http *:* users:(("nginx",pid=22563,fd=7))
tcp LISTEN 0 128 *:ssh *:* benutzer:(("sshd",pid=685,fd=3))
```
To completely remove a service use `sudo apt purge <service-name>`


## Stop unnecessary services
Save power and close security holes by stopping all services you don't need. 

First of all you can get a list of all services, with runlevel and showing if they are running or not:
```bash
systemctl list-unit-files --type=service
systemctl list-dependencies graphical.target
```

Unwanted services can be disabled
```bash
systemctl disable <service-name>
systemctl disable httpd.<service-name>
```
and late be started/restarted or stopped
```bash
systemctl start <service-name>
systemctl restart <service-name>
systemctl stop <service-name>
```

You can also remove services from the system, that will make up some space:
- if a service starts at boot: `sudo update-rc.d <service-name> remove`
- to uninstall a service use: `sudo apt remove <service-name>`

Be aware not to stop system-relevant services as your raspberry may stop working then (just reboot in most cases after that happens).


## Repent brute force with Fail2ban
Hackers will try to access your system more than one time. Fail2ban can recognise and block those brute force attacks. Fail2ban blocks IP adresses that couldn't log in successful for a couple of times. It is configurable to set the amount of tries and duration of block. 

1. install the package `sudo apt install fail2ban`
2. configure fail2ban wih `sudo nano /etc/fail2ban/jail.local` and edit following
    ```bash
    [ssh]
    enabled  = true
    port     = ssh
    filter   = sshd
    logpath  = /var/log/auth.log
    maxretry = 6
    ```
3. restart fail2ban to update with configuration `sudo service fail2ban restart`

The configuration above will limit logins to 5 tries every 10 minutes, a total of 720 tries per day.

## install a firewall
Firewalls can block all ports you don't use, restrict access to specific IPs and more. For example you can only allow SSH access from your very own IP address. 
There are different approaches and packages to build your firewall.

To show all open ports and programms accessing them use `netstat -tulpn`, `ss -tulpn` or
```bash
nmap -sT -O localhost
nmap -sT -O server.example.com
```


### Uncomplicated Firewall
1. install the package
    ```bash
    sudo apt install ufw
    ```
2. allow access to everybody for HTTP und HTTPS
    ```bash
    sudo ufw allow http #Port 80
    sudo ufw allow https #Port 443
    ```
3. allow SSH access only to your IP address (edit to your configuration)
    ```bash
    sudo ufw allow from <IpAdresse> port 22
    ```
4. activate the firewall (now and at every boot)
    ```bash
    sudo ufw enable
    ```
5. check your configuration
    ```bash
    sudo ufw status verbose
    ```

### iptables
Iptables are a bit more complex but allow more specific rulesets.

1. install the package. Choose "Yes" for `rule.v4` and optional `rule.v6` for IPv6 support
2. edit the rules for IPv4
    ```bash
    sudo nano /etc/iptables/rules.v4
    ```
3. the configuration should be emtpy. Add or edit the following lines
    ```bash
    *Filter.
    :INPUT ACCEPT [5897:7430402]
    :FORWARD ACCEPT [0:0]
    :OUTPUT ACCEPT [1767:169364]
    COMMIT
    ```
    Add your own iptables before `COMMIT` and save. E.g. you could add
    ```bash
    sudo iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j REJECT
    ```
    This rule filters ICMP traffic of type 8 and sends "Destination port unreachable"
4. Test your firewall with ping. If it answers as expected you can restart now
5. after restart the ping should show "Destination port unreachable"
6. to show your iptables configuration: `iptables -L` which should show something like
   ```bash
    Chain INPUT (policy ACCEPT)

    target prot opt source destination

    REJECT icmp – anywhere anywhere icmp echo-request reject-with icmp-port-unreachable

    Chain FORWARD (policy ACCEPT)

    target prot opt source destination

    Chain OUTPUT (policy ACCEPT)

    target prot opt source destination
    ```


## Encrypt your connections
With basic unencrypted protocols, the data on the network flows in plain text. That means if you type in your password, a hacker could get it easily while listening to the network. But there are often other protocols that work more securely by encrypting all data.

The first thing you should do is stop using insecure protocols (e.g. FTP, Telnet or HTTP) and then try to replace them with more secure accesses (SFTP, SSH, HTTPS).

## Use a VPN
VPN stands for Virtual Private Network and allows you to remotely access all services on your RPi as if you were on the local network. 
All data flows between you and the RPi are encrypted using a strong protocol. 
This is a good option to prevent many ports from being opened on the Internet without security.
As example you could use [OpenVPN](https://openvpn.net/)

## Protect physical access
Obvious, but often ignored. You can configure all the security protocols, firewall and VPN from all the previous steps but if your RPi is physically accessible to everyone, it is useless.

Make sure it (or the SD card) can't be easily stolen or that no one could come in and plug in a keyboard and screen and be logged in automatically. 
The steps to implement to protect against this type of attack will depend on your system. Maybe you need an automatic logout after X minutes, a password in the grub boot menu, or encryption of the data on the SD card. 

## Check your logs regularly
More a commitment to follow. Most of the time, attacks are visible in log files, so try to read them regularly to detect suspicious activity. 

All logs are located in the `/var/log` folder, the most important log files to check are:
- `/var/log/syslog`: main log file for all services
- `/var/log/message`: log file for the whole system
- `/var/log/auth.log`: all authentication attempts are logged here
- `/var/log/mail.log`: if you have a mail server, a record of the last emails sent can be found here
- Any critical application log file, for example `/var/log/apache2/error.log` or `/var/log/mysql/error.log`.

You can also use logwatch to get daily reports about the system operation
