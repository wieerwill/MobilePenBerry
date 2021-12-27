# Network client
To configure your network and network-devices it is important to know how they work. Here is a little overview of the network client.
```bash
nmcli connection add ifname <INTERFACE> type wifi ssid <SSID> 
nmcli connection edit <CONNECTION>
nmcli> goto wifi
nmcli 802-11-wireless> set mode infrastructure 
nmcli 802-11-wireless> back 
nmcli> goto wifi-sec 
nmcli 802-11-wireless-security> set key-mgmt wpa-psk 
nmcli 802-11-wireless-security> set psk
nmcli 802-11-wireless-security> save 
nmcli 802-11-wireless-security> quit
```

## Add Wifi Drivers for RTL8812BU
The RTL8812BU is an often used chip built into USB-Wifi-Modules. It's very useful if you want to use more than the in-build wifi or scan multiple networks parallel.
```bash
# get requirements
sudo apt install git build-essential dkms raspberrypi-kernel-headers

# get scripts
git clone https://github.com/cilynx/rtl88x2bu
cd rtl88x2bu/

# Configure for RasPi
sed -i 's/I386_PC = y/I386_PC = n/' Makefile
sed -i 's/ARM_RPI = n/ARM_RPI = y/' Makefile

# setup DKMS
VER=$(sed -n 's/\PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)
sudo rsync -rvhP ./ /usr/src/rtl88x2bu-${VER}
sudo dkms add -m rtl88x2bu -v ${VER}
# building will take a while
sudo dkms build -m rtl88x2bu -v ${VER}
sudo dkms install -m rtl88x2bu -v ${VER}
# automatically load at boot
echo 8812bu | sudo tee -a /etc/modules
# Plug in your adapter then confirm your new interface name
ip addr
```

After the reboot you should find a new network device when plugged in. Check it with `ifconfig`

# Add Wifi Driver for RTL8812AU  
Alpha builds very good Wifi antennas that support much more software tweaks, monitor mode and on. (Those drivers are already included in Kali Linux.) For example i use the Alpha AWUS036ACH Module.

Check if the driver already exists
```bash
modprobe 8812au
systemctl restart network-manager
```
As no errors appear, everything should be alright and your network manager already knew the driver. 

If not get it now:
```bash
# get requirements
sudo apt install git build-essential dkms raspberrypi-kernel-headers

# get scripts
git clone https://github.com/gnab/rtl8812au.git
cd rtl8812au/

# Configure for RasPi
sed -i 's/I386_PC = y/I386_PC = n/' Makefile
sed -i 's/ARM_RPI = n/ARM_RPI = y/' Makefile

# setup and install
sudo make dkms_install

# automatically load at boot
echo 8812au | sudo tee -a /etc/modules
# Plug in your adapter then confirm your new interface name
ip addr
```

# change interface modes
Many tools can set the interface modes on their own. But you can do or re-do that with those little commands:
- Set interface down `sudo ip link set <interface> down`
- Set monitor mode `sudo iwconfig <interface> mode monitor`
- Set interface up `sudo ip link set <interface> up`
