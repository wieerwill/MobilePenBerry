# OTG
OTG (on-the-go) is a neat feature which allows you to connect to your system over ssh by just connection it to usb-c. Therefore you don't need any network cable, bluetooth or wifi connection. It's low power and reduces further risks of detection or hackers.

Update your system first
```bash
sudo apt update
sudo apt install rpi-eeprom
sudo apt full-upgrade
```

Change the `/boot/config.txt` and `/boot/cmdline.txt` files. You can edit them directly with nano: `sudo nano /boot/config.txt` and `sudo nano /boot/cmdline.txt`

`/boot/config.txt`:
```bash[/boot/config.txt]
# enable USB OTG
dtoverlay=dwc2
```

in `/boot/cmdline.txt` add directly after `rootwait`:
```bash[/boot/cmdline.txt]
modules-load=dwc2,g_ether
```

After that we need to add:
- `libcomposite` to `/etc/modules` (`sudo nano /etc/modules`)
- `denyinterfaces usb0` to `/etc/dhcpcd.conf` (`sudo nano /etc/dhcpcd.conf`)

We are ready to configure the network sharing, to do that you need to install and configure dnsmasq:
```bash
sudo apt install dnsmasq
```

And create `/etc/dnsmasq.d/usb` with the following content (`sudo nano /etc/dnsmasq.d/usb`):
```bash[/etc/dnsmasq.d/usb]
interface=usb0
dhcp-range=10.55.0.2,10.55.0.6,255.255.255.248,1h
dhcp-option=3
leasefile-ro
```

Next to that we create `/etc/network/interfaces.d/usb0` with the following content:
```bash[/etc/network/interfaces.d/usb0]
auto usb0
allow-hotplug usb0
iface usb0 inet static
  address 10.55.0.1
  netmask 255.255.255.248
```

Finally we create `/root/usb.sh`, a simple python script with the following lines of code:
```bash
#!/bin/bash
cd /sys/kernel/config/usb_gadget/
mkdir -p pi4
cd pi4
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2
echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol
mkdir -p strings/0x409
echo "fedcba9876543211" > strings/0x409/serialnumber
echo "Ben Hardill" > strings/0x409/manufacturer
echo "PI4 USB Device" > strings/0x409/product
mkdir -p configs/c.1/strings/0x409
echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower
# Add functions here
# see gadget configurations below
# End functions
mkdir -p functions/ecm.usb0
HOST="00:dc:c8:f7:75:14" # "HostPC"
SELF="00:dd:dc:eb:6d:a1" # "BadUSB"
echo $HOST > functions/ecm.usb0/host_addr
echo $SELF > functions/ecm.usb0/dev_addr
ln -s functions/ecm.usb0 configs/c.1/
udevadm settle -t 5 || :
ls /sys/class/udc > UDC
ifup usb0
service dnsmasq restart
```

This script need to be run every time the RPi is booted, to do that add `/root/usb.sh` to `/etc/rc.local` before `exit 0` line.

With this setup the RPi will show up as a ethernet device with an IP address of `10.55.0.1` and will assign the device you plug it into an IP address via DHCP. This means you can just ssh to `<username>@10.55.0.1` to start using it.


# Sources and more
[altervista.org](https://raspiproject.altervista.org/en/raspberry-pi-4-as-usb-c-gadget/)