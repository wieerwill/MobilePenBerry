# Kismet
Kismet is a wireless network and device detector, sniffer, wardriving tool, and WIDS (wireless intrusion detection) framework.

Kismet works with Wi-Fi interfaces, Bluetooth interfaces, some SDR (software defined radio) hardware like the RTLSDR, and other specialized capture hardware.

Kismet can integrate with a GPS device to provide geolocation coordinates for devices.

## Compile
Important to get no errors: If you installed Kismet using a package from your distribution, uninstall it the same way; if you compiled it yourself, be sure to remove it.

```bash
# get all requiremets
sudo apt install build-essential git libwebsockets-dev pkg-config zlib1g-dev libnl-3-dev libnl-genl-3-dev libcap-dev libpcap-dev libnm-dev libdw-dev libsqlite3-dev libprotobuf-dev libprotobuf-c-dev protobuf-compiler protobuf-c-compiler libsensors4-dev libusb-1.0-0-dev python3 python3-setuptools python3-protobuf python3-requests python3-numpy python3-serial python3-usb python3-dev python3-websockets librtlsdr0 libubertooth-dev libbtbb-dev
# Clone Kismet from git
git clone https://www.kismetwireless.net/git/kismet.git
cd kismet
# Run configure
# If you have any missing dependencies or incompatible library versions, they will show up here
./configure
# compile and install Kismet
make
sudo make suidinstall
# add your user to the kismet group
sudo usermod -aG kismet $USER
# reload and check your groups
newgrp -
groups
```

For RTLSDR rtl_433 support, you will also need the rtl_433 tool if it is not already a package in your distribution.

Kismet can be run with no options and configured completely from the web interface: `kismet`.
If you already know which interface to use you can start Kismet with that source already defined, e.g. `kismet -c wlan0`. 

THE FIRST TIME YOU RUN KISMET, you must go to the Kismet web UI and create a login and password. This password is stored in `~/.kismet/kismet_httpd.conf` which is in the home directory of the user which started Kismet.

## Automatically launching Kismet
An example systemd script is in the `packaging/systemd/` directory of the Kismet source; if you are installing from source this can be copied to `/etc/systemd/system/kismet.service` and packages should automatically include this file.

When starting Kismet via systemd, you should install kismet as suidroot and use `systemctl edit kismet.service` to set the following:
```bash
[Service]
User=your-unprivileged-user
Group=kismet
```
When using systemd, you will need to be sure to configure Kismet to log to a valid location. By default, Kismet logs to the directory it is launched from, which is unlikely to be valid when starting from a boot script. Be sure to put a `log_prefix=...` in your `kismet_site.conf`, e.g. `log_prefix=/home/kismet/logs`

## Configuring Kismet
Lismet is configured through a set of text files. By default these are installed into `/usr/local/etc/` when compiling from source. The config is seperated into several files:
- `kismet.conf`: master config file which loads all other configuration files and contains most of the system-wide options
- `kismet_alerts.conf`: includes rules for alert matching, rate limits on alerts, and other IDS/problem detection options
- `kismet_httpd.conf`: Webserver configuration
- `kismet_memory.conf`: Memory consumption and system tuning options
- `kismet_storage.conf`: persistent storage configuration
- `kismet_logging.conf`: Logfile configuration
- `kismet_filter.conf`: Packet and device filter
- `kismet_uav.conf`: Parsing rules for detecting UAV/Drones or similar devices
- `kismet_80211.conf`: Configuration settings for Wi-Fi specific options
- `kismet_site.conf`: Optional configuration override; will load any options here last and take precedence over all other configs

Any lines beginning with a `#` are comments, and are ignored

Often used configurations are listed below:

Edit `/kismet.conf` to set the default devices to use, e.g. wifi, bluetooth and GPS
```bash
#wireless adapter 
source=wlan1:name=wifi1:type=linuxwifi
#internal bluetooth
source=hci0:name=bluetooth0:type=linuxbluetooth
#gpsd service with gps-usb adapter
gps=gpsd:host=localhost,port=2947,reconnect=true
```

Edit `/kismet_logging.conf` to change logging to a defined new path instead of home directory.

Edit `/kismet_filter.conf` to filter your own devices and packets and reduce waste of time and space.
```bash
kis_log_device_filter=IEEE802.11,B0:4E:26:11:95:F9,block
kis_log_packet_filter=IEEE802.11,any,02:11:87:1A:A0:D9,block
```

Change `/kismet_memory.conf` as you like, here is a configuration to run efficent and memory cheap on a RPi:
```bash
# Forget long idle devices
tracker_device_timeout=1800     # 60s * 30 = 30 minutes
# Don't track signal levels
keep_datasource_signal_history=false
# Disable memory taking organizing of devices
track_device_seenby_view=false
track_device_phy_view=false
manuf_lookup=false
packet_dedup_size=1024 #standard 2048
```

## KismetDB
Kismet can replay recorded data in the kismetdb format, the unified log created by Kismet.

Kismet can replay a pcapfile for testing, debugging, demo, or reprocessing.

A `kismetdb` file can contain packets and device data from any source Kismet handles.

```bash
# Install kismetdb
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python3 get-pip.py
# or
sudo apt install python3-pip
pip3 install kismetdb
```

The kismetdb datasource will auto-detect kismetdb files and paths to files:
```bash
kismet -c /tmp/foo.kismet
```

## useful commands
Before sharing a packet log, you should *strip* the packet content
```bash
kismetdb_strip_packets --in some-kismet-file.kismet --out some-other-file.kismet
```

Kismet to *Wigle* (to upload it via browser to wigle.net)
```bash
kismetdb_to_wiglecsv --in some-kismet-log-file.kismet --out some-wigle-file.csv
```

Kismet to *KML*, an XML-based markup language for use with Google Earth
```bash
kismetdb_to_kml --in some-kismet-log-file.kismet --out some-kml-file.kml
```

Kismet stores *devices* it has seen in the kismetdb log file as JSON dumps containing everything Kismet knows about a device.
```bash
kismetdb_dump_devices --in some-kismet-file.kismet --out some-json.json
```

## useful plugins

### Kestrel (Maps)
Add live mapping of networks into the Kismet UI directly
```bash
git clone https://gitlab.com/SoliForte777/Kestrel.git
cd Kestrel/plugin-kestrel
sudo make install
```

### IoD (Internet of Dongs)
Plugin for Kismet to detect and highlight IoD devices.
```bash
git clone https://github.com/internetofdongs/IoD-Screwdriver.git
cd IoD-Screwdriver/plugin-iod-screwdriver
make install
```

### Report Generator
This tool generates a report for a specific SSID. This data is exportable as PDF and CSV
```bash
git clone https://github.com/soliforte/kismetreportgen.git
cd kismetreportgen
make install
```

## run a Kismet bot
Add new user and update
```bash
useradd -m scanbot -G kismet -s /bin/bash
# add password to bot 
passwd scanbot
usermod -aG sudo scannrunner
```
load new configuration with `logout` and log back in

autostart kismet for bot
```bash
# copy systemd file from kismet to systemd
cp /home/pi/kismet/packaging/systemd/kismet.service /lib/systemd/system/
systemctl edit kismet
        [Service]
        User=scanbot
        Group=kismet
systemctl enable kismet
systemctl start kismet
systemctl status kismet
reboot
```
The bot will now start Kismet on boot and log every device you get near (if you configured it correct).

# Sources and more
[Kismet Homepage](https://www.kismetwireless.net/)