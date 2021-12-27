# GPS: Glonass G-7020 VK-172 GPS
I got myself the G-7020 GPS Module to connect my RPi via USB. Here is how it works
```bash
# requirements
sudo apt install gpsd gpsd-clients python-gi-cairo minicom
```

Check if gpsd is already running
```bash
ps -aux | grep gpsd
kill <gpsd id>
```

Note if you're using the Raspbian Jessie or later release you'll need to disable a systemd service that gpsd installs. This service has systemd listen on a local socket and run gpsd when clients connect to it, however it will also interfere with other gpsd instances that are manually run (like here). You will need to disable the gpsd systemd service by running the following commands:
```bash
sudo systemctl stop gpsd.socket
sudo systemctl disable gpsd.socket
```
Should you ever want to enable the default gpsd systemd service you can run these commands to restore it (but remember the rest of the steps here won't work!):
```bash
sudo systemctl enable gpsd.socket
sudo systemctl start gpsd.socket
```

Check if port 2947 is free or blocked: 
```bash
netstat -tulpn
```

Now list all ports and find the new one
```bash
ls /dev/tty*
```
or use system to show new devices
```bash
dmesg | grep tty
```
Test if the choosen port gets data
```bash
cat /dev/ttyACM0
```
If you wish to go that route, for whatever reason, before doing anything else, make sure gpsd is not running.
```bash
sudo killall gpsd
```
and remove any sockets gpsd might have left behind,
```bash
sudo rm /var/run/gpsd.sock
```
Change from binary to NMEA:
```bash
gpsctl -f -n /dev/ttyUSB0
stty -F /dev/ttyACM0
#set baud rate of GPS
stty -F /dev/ttyACM0 9600
```
Now test your device
```bash
minicom -b 9600 -o -D /dev/ttyACM0
```
To leave minicom press 'Ctrl-A' then 'X' and ENTER

and test gpsd
```bash
gpsd -b -n -N -D4 -s 9600 -S 2948 /dev/ttyACM0 
```

You can configure your GPS device by editing `/etc/default/gpsd`:
```bash
START_DAEMON="true"
USBAUTO="true"
DEVICES="/dev/ttyACM0"
GPSD_OPTIONS="-b -n -S 2900"
GPSD_SOCKET="/var/run/gpsd.sock"
```

After that restart the service and watch the results
```bash
sudo service gpsd restart
xgps 
cgps -s
```