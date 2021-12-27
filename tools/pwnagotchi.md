# Pwnagotchi
Pwnagotchi is a standalone project for RaspberryPi Zeros but can be installed on other Linux systems too.

You need to have [bettercap](bettercap.md) and `libpcap` installed.

```bash
sudo apt install libpcap0.8
```

## Bettercap Caplets
Depending on the name of the WiFi interface you’re going to use, you’ll need to edit the `/usr/local/share/bettercap/caplets/pwnagotchi-auto.cap` and `/usr/local/share/bettercap/caplets/pwnagotchi-manual.cap` caplet files accordingly.

In the default Pwnagotchi image bettercap is running as a systemd service through a launcher script `/etc/systemd/system/bettercap.service` with the following content:
```bash
[Unit]
Description=bettercap api.rest service.
Documentation=https://bettercap.org
Wants=network.target
After=pwngrid.service

[Service]
Type=simple
PermissionsStartOnly=true
ExecStart=/usr/bin/bettercap-launcher
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
```

And this is `/usr/bin/bettercap-launcher`
```bash
#!/usr/bin/env bash
/usr/bin/monstart
if [[ $(ifconfig | grep usb0 | grep RUNNING) ]] || [[ $(cat /sys/class/net/eth0/carrier) ]]; then
  # if override file exists, go into auto mode
  if [ -f /root/.pwnagotchi-auto ]; then
    /usr/bin/bettercap -no-colors -caplet pwnagotchi-auto -iface mon0
  else
    /usr/bin/bettercap -no-colors -caplet pwnagotchi-manual -iface mon0
  fi
else
  /usr/bin/bettercap -no-colors -caplet pwnagotchi-auto -iface mon0
fi
```
Again the interface name and the command to start the monitor mode need to be adjusted for the specific computer and WiFi card.

## PwnGrid
The second service we will need is pwngrid:
```bash
wget "https://github.com/evilsocket/pwngrid/releases/download/v1.10.3/pwngrid_linux_amd64_v1.10.3.zip"
unzip pwngrid_linux_amd64_v1.10.3.zip
sudo mv pwngrid /usr/bin/
# generate the keypair
sudo pwngrid -generate -keys /etc/pwnagotchi
```
Alternate make it yourself from source
```bash
git clone https://github.com/evilsocket/pwngrid.git
cd pwngrid
make
make install
```

Pwngrid runs via the `/etc/systemd/system/pwngrid-peer.service` systemd service, don't forget to change your interface
```bash
[Unit]
Description=pwngrid peer service.
Documentation=https://pwnagotchi.ai
Wants=network.target

[Service]
Type=simple
PermissionsStartOnly=true
ExecStart=/usr/bin/pwngrid -keys /etc/pwnagotchi -address 127.0.0.1:8666 -client-token /root/.api-enrollment.json -wait -log /var/log/pwngrid-peer.log -iface mon0
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
```

## PwnaGotchi
The last ingredient is going to be the python3 Pwnagotchi main codebase
```bash
wget "https://github.com/evilsocket/pwnagotchi/archive/v1.4.3.zip"
unzip v1.4.3.zip
cd pwnagotchi-1.4.3
sudo pip3 install -r requirements.txt
sudo pip3 install .
```
Also alternativ compile it yourself from source
```bash
git clone https://github.com/evilsocket/pwnagotchi.git
cd pwnagotchi
sudo pip3 install -r requirements.txt
make
sudo make install
```

Assuming both bettercap and pwngrid are configured and running correctly, we can now start pwnagotchi
```bash
# AUTO mode
sudo pwnagotchi
# AUTO mode with debug logs
sudo pwnagotchi --debug
# MANU mode
sudo pwnagotchi --manual
# MANU mode with debug logs
sudo pwnagotchi --manual --debug
# show the other options
pwnagotchi -h
```

This will install the default configuration file in `/etc/pwnagotchi/default.toml`, in order to apply customizations you’ll need to create a new `/etc/pwnagotchi/config.toml` file as explained in the configuration section.

## RPi Tweaks
1. having an ethernet port allows you an easier connection to the booted system. Just connect a cable to the port and Pwnagotchi get an IP address with DHCP. If a plugged ethernet cable is detected on boot it will start in MANU mode
2. in order to improve battery duration and reduce power requirements you can lower cpu frequency (underclocking). Edit your `/boot/config.txt` and add/uncomment the `arm_freq=800` line
3. to run the Pi3 you need at least 2.5A, but 2A should be enough if you underclocked


# Sources and more
[Pwnagotchi](https://pwnagotchi.ai)