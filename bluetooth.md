# Bluetooth
Normally bluetooth is pre-installed, if not you can get it with
```bash
sudo apt install bluetooth
```

# Connect devices via bluetooth
```bash
bluetoothctl
> agent on
> scan on
... wait for your device to show up ...
... now pair with its address
> pair aa:bb:cc:dd:ee:ff
... and trust it permantently ...
> trust aa:bb:cc:dd:ee:ff
... wait ...
> quit
```

# Configure bluetooth
If your are missing additional antennas, you want to use wlan0 for monitor mode and injection, meaning we need another way to connect to our RPi. For this, we can setup the bluetooth module to work as a bt-nap server, to be able to connect via bluetooth and reach it with an IP adress on that bluetooth connection. This works both from a laptop and smartphone well.

```bash
# install a few dependencies
sudo apt install git
# download the required repository
git clone https://github.com/bablokb/pi-btnap.git
# install btnap as a server
./pi-btnap/tools/install-btnap server
```

Fix the bluetooth configuration file `/etc/systemd/system/bluetooth.target.wants/bluetooth.service` by disabling the SAP plugin that would break bluetooth, change the ExecStart part with: `ExecStart=/usr/lib/bluetooth/bluetoothd --noplugin=sap`

Let’s set the bluetooth name of your device by editing `/etc/bluetooth/main.conf` and finally edit the btnap configuration file itself, `/etc/btnap.conf`:
```bash
MODE="server"
BR_DEV="br0"
BR_IP="192.168.20.99/24"
BR_GW="192.168.20.1" 
ADD_IF="lo" 
REMOTE_DEV="" 
DEBUG=""
```

Enable all the services at boot and restart them:
```bash
systemctl enable bluetooth
systemctl enable btnap
systemctl enable dnsmasq

service bluetooth restart
service dnsmasq restart
service btnap restart
```

Before being able to connect via bluetooth, we need to manually pair and trust the device we’re going to use (remember to repeat this step for every new device you want to allow to connect to the RPi), make sure your control device (your laptop for instance) has bluetooth enabled and it’s visible, then from the RPi:
```bash
bluetoothctl
> agent on
> scan on
... wait for your device to show up ...
... now pair with its address
> pair aa:bb:cc:dd:ee:ff
... and trust it permantently ...
> trust aa:bb:cc:dd:ee:ff
... wait ...
> quit
```

Sometimes an error 'no default controller available' shows up, then just run `sudo bluetoothctl` instead.

After reboot, you’ll be able to connect to the board via bluetooth.
Your system should now have a new DHCP based RPi Network entry in the network manager. Check it with `ifconfig` for a interface named `br0`

To ssh into your RPi via bluetooth from your computer: 
```
echo "192.168.20.99 <username>" >> /etc/hosts
ssh root@<hostname>
``` 
Don't forget to change <username> to your chosen username from above.

# Free your wifi
We’re now ready to 'free' the `wlan0` interface and use it for more cool stuff, let’s change the file `/etc/network/interfaces` to:
```bash[/etc/network/interfaces]
auto lo
iface lo inet loopback

allow-hotplug wlan0
iface wlan0 inet static
```

From the board now, disable `wpa_supplicant` and reboot:
```bash
service wpa_supplicant disable
sudo systemctl disable wpa_supplicant.service 
reboot
```


# Sources and more
[blog.iamlevi.net](https://blog.iamlevi.net/2017/05/control-raspberry-pi-android-bluetooth/)