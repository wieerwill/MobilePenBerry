Headless setup is a often used configuration as you don't need any extra pair of keyboard and mouse. 

# Setting up your Computer and SD Card
We will start at your Computer. Insert the SD card into your computer. 

## Writing the Image to SD card
Update your Distribution and install the RPi imager.
```bash
sudo apt update
sudo apt upgrade
sudo apt install rpi-imager #tool to download and install images onto SD card
rpi-imager 
```
In this Series we use the RaspberryPi OS (legacy) without desktop environment.
Now we can configure the Image to start at best conditions. 

## Enable SSH
To enable SSH directly on the SD card add a new file named `ssh`, with no extension, to the 
If you have added an empty file `ssh` to the boot sector of your SD card (`touch /boot/ssh`), the Pi will start with SSH enabled. After that we can connect from your laptop with: `ssh pi@raspberrypi.local` (or `ssh pi@<IPADRESS>` when the ip adress in known).


# Booting up your Pi
Insert the SD card into your RapsberryPi, connect it to your router and power it on. After the startup we can connect via SSH 
`ssh pi@raspberrypi.local` and log in (default pw is "raspberry"). 

Normally your raspberry can be found in the same network with `raspberrypi.local`. If not check your routers ip table to find your RPis IP and connect `@<localip>`

If you don't have a wire-connection you can use your Wifi, read the [how to](wifi.md)

Start using the RPi with `raspi-config` to configure all settings.


# Sources and more
[RaspbberryPi.com](https://www.raspberrypi.com/software/)