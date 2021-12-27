# Wifi
## enable automatic networking
This step is required if you can't connect to a network via cable. It will activate your wifi connection at startup.

Insert the SD card into the computer (not RPi).
Create and open a file named `wpa_supplicant.conf` in the `/boot` folder of the SD card and add the following
```bash[/boot/wpa_supplicant.conf]
country=US # replace with your country code
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
network={
    ssid="<WIFI_NETWORK_NAME>"
    psk="<WIFI_PASSWORD>"
    key_mgmt=WPA-PSK
}
```

Replace WIFI_NETWORK_NAME and WIFI_PASSWORD with the actual name and password of your Wi-Fi network. 

To add further networks just add new `network` Objects with credentials.

## hide your credentials
As the file can be accessed and read by anybody who has access to the SD card or user you can also use a tool to hide your password.
```bash
wpa_passphrase <WIFI_NETWORK_NAME> <WIFI_PASSWORD> >> \etc\wpa_supplicant\wpa_supplicant.conf
```
The network should be added automatically. Check the file `/etc/wpa_supplicant/wpa_supplicant.conf` and edit what's missing
```bash
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=DE

network={# example network
    ssid="<WIFI_NETWORK_NAME>" # also called SSID
    scan_ssid=1
    psk=<32byte-key> # instead of password
    key_mgmt=WPA-PSK
    id_str="home" # short name to call this network
}
```

Now you can restart the wifi device to connect properly
```bash
wpa_cli -i wlan0 reconfigure
ifconfig wlan0
```

Now the RPi should automatically connect to the Wi-Fi network on boot.

## deactivate DHCP
If you got multiple RPis or Devices in your Network, it is practical to call them by their hostname instead of using DHCP. Therefore change the file `/etc/network/interfaces`
```bash
auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet manual
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
    post-up ifdown eth0
iface default inet dhcp
```

Remember that hostnames may not be identical! Change the hostnames by editing `/etc/hostname`

## RPi as AP
Get all requirements and make them ready to configure
```bash
sudo apt-get install hostapd dnsmasq
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
```

We assume the standard home network IP address is like 192.168.###.###. Therefore we assign the IP address 192.168.0.10 to the wlan0 interface by editing the dhcpcd configuration file `/etc/dhcpcd.conf`, add the following lines at the end:
```bash
interface wlan0
static ip_address=192.168.0.10/24
denyinterfaces eth0
denyinterfaces wlan0
```
The last two lines are needed in order to make the bridge work.

Now we configure the DHCP server via dnsmasq. Rename the default configuration file and create a new one
```bash
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo nano /etc/dnsmasq.conf
```
Add these lines to the new config file
```bash
interface=wlan0
  dhcp-range=192.168.0.11,192.168.0.30,255.255.255.0,24h
```
To edit hostapd we create a new file `sudo nano /etc/hostapd/hostapd.conf` and add the following
```bash
interface=wlan0
bridge=br0
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ssid=<NETWORK>
wpa_passphrase=<NETWORKPASSWORD>
```

To show the system the location of the config file open `/etc/default/hostapd` and search "#DEAMON_CONF=" to delete the `#` and put the path of the config file into the quotes: `DAEMON_CONF="/etc/hostapd/hostapd.conf"`

### Forward traffic
We can connect to the RPi via wlan0 but we don't get any internet connection. So to forward traffic over to the ethernet cable, we have wlan0 forward everything via ethernet cable to the modem. Edit `/etc/sysctl.conf`, find the line `#net.ipv4.ip_forward=1` and delete the `#`. 

Next add IP masquerading for outbound traffic on eth0 using `sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE` abd save tghe new iptables rule `sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"`. 

To load the rule on boot, edit the file `/etc/rc.local` and add the following line just above the line exit 0: `iptables-restore < /etc/iptables.ipv4.nat`. Now the traffic should be forwarded correctly.

To enable the internet connection by using a bridge. Therefore install `bridge-utils`
```bash
sudo apt-get install bridge-utils
# add a new bridge called br0
sudo brctl addbr br0
# connect eth0 interface to bridge
sudo brctl addif br0 eth0
# edit the interfaces file
sudo nano /etc/network/interfaces
```
and add the following lines at the end file
```bash
auto br0
iface br0 inet manual
bridge_ports eth0 wlan0
```

Reboot to make all changes happen.

# NetworkManager
`nmcli` is a command‐line tool for controlling NetworkManager.
Just change <WifiInterface>, <WiFiSSID>, <WiFiPassword> in the following commands to reflect your setup. If WiFi info already saved, easier way using <SavedWiFiConn> name of connection as it was saved in NetworkManager.

- list of saved connections `nmcli c`
- list of available WiFi hotspots `nmcli d wifi list` or `sudo iwlist wlan0 scanning`
- list of interfaces `ifconfig -a`

- Disconnect an interface `nmcli d disconnect <WifiInterface>`
- Connect an interface `nmcli d connect <WifiInterface>` 

If you already got an connection saved in your manager you can also use:
- disconnect: `nmcli c down <SavedWiFiConn>`
- connect: `nmcli c up <SavedWiFiConn>`

To connect to a new access point:
- `nmcli d wifi connect <WiFiSSID> password <WiFiPassword> iface <WifiInterface>`
- and to disconnect `nmcli d disconnect iface <WifiInterface>`

If your password isn't automatically recognized type this: `nmcli -a c up <SavedWiFiConn>`


# Sources and more
- [webonomic.nl](https://dev.webonomic.nl/4-ways-to-connect-your-raspberry-pi-4-to-the-internet)
- [roboticsbackend.com](https://roboticsbackend.com/enable-ssh-on-raspberry-pi-raspbian/)