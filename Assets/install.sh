#!/bin/bash
############################################################
##  MobilePenBerry
##  
##  Create your mobile penetration testing station
##  on a RaspberryPi
##  Tested on RaspberryPi 4
##  
##  run script as root
##
##  author: github.com/wieerwill
##
############################################################
read -p "new user name: " USERNAME
read -sp "new user password: " PASSWORD

echo Updating
apt update
apt full-upgrade
apt install rpi-eeprom git build-essential dkms raspberrypi-kernel-headers -y
apt autoremove
rfkill unblock 0
rfkill unblock 1

echo create new user and disable default pi user
adduser $USERNAME
adduser $USERNAME sudo
usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi $USERNAME
usermod -L pi
passwd -l pi

echo setting locale to de_DE
sed 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen de_DE.UTF-8
update-locale de_DE.UTF-8

echo SSH keys
rm -rf /home/pi/.ssh
rm -rf /home/$USERNAME/.ssh
ssh-keygen -R raspberrypi
ssh-keygen -t ecdsa -b 521

read -p "Disable SSH password login? (only do if exchanged ssh keys) [yes|no] " SSHPASS
if [ $SSHPASS == 'yes' ]; 
then
sed 's/# ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sed 's/# PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed 's/# UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
service ssh restart
fi

read -p "Install Fail2ban? [yes|no] " FAIL2BAN
if [ $FAIL2BAN == 'yes' ]; 
then
apt install fail2ban -y
cat > /etc/fail2ban/jail.local << EOF
[ssh]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 6
EOF
service fail2ban restart
fi


read -p "Create WiFi AP? [yes|no] " WIFIAP
if [ $WIFIAP == 'yes' ]; 
then
read -p "What should be the name of the AP? " NETWORKNAME
read -p "What is the password of the AP? " NETWORKPASSWORD
apt-get install hostapd dnsmasq
systemctl stop hostapd
systemctl stop dnsmasq
echo "interface wlan0" >> /etc/dhcpcd.conf
echo "static ip_address=192.168.0.10/24" >> /etc/dhcpcd.conf
echo "denyinterfaces eth0" >> /etc/dhcpcd.conf
echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
cat > /etc/dnsmasq.conf << EOF
interface=wlan0
dhcp-range=192.168.0.11,192.168.0.30,255.255.255.0,24h
EOF
cat > /etc/hostapd/hostapd.conf << EOF
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
EOF
echo "ssid=$NETWORKNAME" >> /etc/hostapd/hostapd.conf
echo "wpa_passphrase=$NETWORKPASSWORD" >> /etc/hostapd/hostapd.conf
sed 's/#DEAMON_CONF=/DAEMON_CONF="/etc/hostapd/hostapd.conf/' /etc/default/hostapd
else
	echo "WIFI AP will not be configured"
fi

read -p "Install RTL88X2BU WiFi Driver? [yes|no] " RTLBU
if [ $RTLBU == 'yes' ]; then
cd
git clone https://github.com/cilynx/rtl88x2bu
cd rtl88x2bu/
sed -i 's/I386_PC = y/I386_PC = n/' Makefile
sed -i 's/ARM_RPI = n/ARM_RPI = y/' Makefile
VER=$(sed -n 's/\PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)
rsync -rvhP ./ /usr/src/rtl88x2bu-${VER}
dkms add -m rtl88x2bu -v ${VER}
dkms build -m rtl88x2bu -v ${VER}
dkms install -m rtl88x2bu -v ${VER}
echo 8812bu | tee -a /etc/modules
cd
fi

read -p "Install RTL8812AU WiFi Driver? [yes|no] " RTLAU
if [ $RTLAU == 'yes' ]; then
cd
git clone https://github.com/gnab/rtl8812au.git
cd rtl8812au/
sed -i 's/I386_PC = y/I386_PC = n/' Makefile
sed -i 's/ARM_RPI = n/ARM_RPI = y/' Makefile
make dkms_install
echo 8812au | tee -a /etc/modules
cd
fi

read -p "Install GPS drivers? [yes|no]" GPS
if [ $RTLAU == 'yes' ]; then
apt install gpsd gpsd-clients python-gi-cairo minicom -y
#GPSDID = pidof gpsd
#kill $GPSDID
killall gpsd
systemctl stop gpsd.socket
systemctl disable gpsd.socket
killall gpsd
rm /var/run/gpsd.sock
gpsctl -f -n /dev/ttyUSB0
stty -F /dev/ttyACM0
stty -F /dev/ttyACM0 9600
mv /etc/default/gpsd /etc/default/gpsd_default
cat > /etc/default/gpsd << EOF
START_DAEMON="true"
USBAUTO="true"
DEVICES="/dev/ttyACM0"
GPSD_OPTIONS="-b -n -S 2900"
GPSD_SOCKET="/var/run/gpsd.sock"
service gpsd restart
EOF
fi

read -p "Install I2C SSD1306 Display? [yes|no]" SSD1306
if [ $SSD1306 == 'yes' ]; then
apt install -y git python3-dev python3-pil python3-smbus python3-pil python3-pip python3-setuptools python3-rpi.gpio python3-pip i2ctools libi2c-dev -y
cat > /etc/modules << EOF
i2c-dev
i2c-bcm2708
EOF
cat > /boot/config.txt << EOF
dtparam=i2c_arm=on
dtparam=i2c1=on
EOF
i2cdetect -y 1
cd
git clone https://github.com/adafruit/Adafruit_Python_SSD1306.git
cd Adafruit_Python_SSD1306
python3 setup.py install
cd
fi

read -p "Enable SPI? [yes|no]" SPI
if [ $SPI == 'yes' ]; then
cat > /boot/config.txt << EOF
dtparam=spi=on
EOF
# check if enabled
lsmod | grep spi_
fi

read -p "Install BCM2835 library? [yes|no]" BCM2835
if [ $BCM2835 == 'yes' ]; then
apt install wget -y
wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.71.tar.gz
tar zxvf bcm2835-1.71.tar.gz 
rm -r bcm2835-1.71.tar.gz 
cd bcm2835-1.71/
./configure
make
make check
make install
cd
fi

read -p "Install WiringPi library? [yes|no]" WIRINGPI
if [ $WIRINGPI == 'yes' ]; then
apt install wiringpi dpkg wget -y
wget https://project-downloads.drogon.net/wiringpi-latest.deb
dpkg -i wiringpi-latest.deb
rm wiringpi-latest.deb
fi

read -p "Install Python3 GPIO library? [yes|no]" PYTHONGPIO
if [ $PYTHONGPIO == 'yes' ]; then
apt install python3-pip python3-pil python3-numpy -y
pip3 install RPi.GPIO spidev
fi

read -p "Download Waveshare Codes? [yes|no]" WAVESHARE
if [ $WAVESHARE == 'yes' ]; then
git clone https://github.com/waveshare/e-Paper
fi


read -p "Install I2C Real Time Clock? [yes|no]" RTC
if [ $RTC == 'yes' ]; then
cat > /boot/config.txt << EOF
dtoverlay=i2c-rtc,ds1307
EOF
apt -y remove fake-hwclock
update-rc.d -f fake-hwclock remove
sed -i '/if [ -e /run/systemd/system ] ; then\
        exit 0\
    fi/#if [ -e /run/systemd/system ] ; then\
    	#exit 0\
    #fi/g' /lib/udev/hwclock-set
fi

read -p "Install mkp224o to generate onion address? [yes|no]" MKP22O
if [ $MKP22O == 'yes' ]; then
apt install gcc libsodium-dev make autoconf git -y
cd
git clone https://github.com/cathugger/mkp224o
cd mkp224o
./autogen.sh
./configure
make
fi

read -p "Install TOR service? [yes|no]" TOR
if [ $TOR == 'yes' ]; then
apt install nginx tor -y
systemctl enable nginx
systemctl start nginx
systemctl enable tor
systemctl start tor
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
    <head>
        <title>Example</title>
    </head>
    <body>
        <p>This is an example of a simple HTML page with one paragraph.</p>
    </body>
</html>
EOF
systemctl restart nginx
sed -i 's+#HiddenServiceDir /var/lib/tor/hidden_service/ = y+HiddenServiceDir /var/lib/tor/hidden_service/+' /etc/tor/torrc
sed -i 's+#HiddenServicePort 80 127.0.0.1:80+HiddenServicePort 80 127.0.0.1:80+' /etc/tor/torrc
systemctl restart tor
fi

read -p "Install Bettercap? [yes|no]" BETTERCAP
if [ $BETERCAP == 'yes' ]; then
wget https://go.dev/dl/go1.17.5.linux-armv6l.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go1.17.5.linux-armv6l.tar.gz
cat > ~/.profile << EOF
PATH=$PATH:/usr/local/go/bin
GOPATH=$HOME/golang
EOF
source ~/.profile
rm -r go1.17.5.linux-armv6l.tar.gz
apt install libpcap-dev libnetfilter-queue-dev libusb-1.0-0-dev build-essential
go install github.com/bettercap/bettercap@latest
cp go/bin/bettercap /usr/bin/
bettercap -eval "caplets.update; ui.update; quit"
fi

read -p "Install Xerosploit? [yes|no]" BETTERCAP
if [ $BETERCAP == 'yes' ]; then
cd
git clone https://github.com/LionSec/xerosploit
cd xerosploit 
python install.py
fi