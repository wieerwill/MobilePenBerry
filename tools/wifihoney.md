# Wifi Honey
It's to work out what encryption a client is looking for in a given network by setting up four fake access points, each with a different type of encryption, None, WEP, WPA and WPA2 and the seeing which of the four the client connects to.

In the case of WPA/WPA2, by running airodump-ng along side this you also end up capturing the first two packets of the four way handshake and so can attempt to crack the key with either aircrack-ng or coWPAtty.

What this script does is to automate the setup process, it creates five monitor mode interfaces, four are used as APs and the fifth is used for airodump-ng. To make things easier, rather than having five windows all this is done in a screen session which allows you to switch between screens to see what is going on. All sessions are labelled so you know which is which.

## Installation
The script requires screen and the aircrack-ng suite, make sure they are both installed and in the path
```bash
sudo apt install wifi-honey
```

Or download the script:
```bash
wget https://digi.ninja/files/wifi_honey_1.0.tar.bz2
tar -xf wifi_honey.tar.bz2
cd wifi_honey
chmod a+x wifi_honey.sh
# remember to run wifihoney from the .sh directory
```

## Usage
Usage is simple, start the script with the ESSID of the network you want to impersonate.
```bash
wifi_honey FreeWifi
```

Specify also the channel and interface: Broadcast the given ESSID (FreeWiFi) on channel 6 (6) using the wireless interface (wlan0)
```bash
wifi-honey FreeWiFi 6 wlan0
```

## The script
As Wifi Honey is a small script you can also just copy paste or look what it does here:
```bash
#!/usr/bin/env bash

if [[ -z "$1" ]]
then
	echo "Missing ESSID"
	exit 1
fi

if [ "$1" == "-h" -o "$1" == "-?" ]
then
	echo "Usage: $0 <essid> <channel> <interface>"
	echo
	echo "Default channel is 1"
	echo "Default interface is wlan0"
	echo
	echo "Robin Wood <robin@digininja.org>"
	echo "See Security Tube Wifi Mega Primer episode 26 for more information"
	exit 1
fi

ESSID=$1
CHANNEL=$2
INTERFACE=$3

if [[ "$CHANNEL" == "" ]]
then
	CHANNEL=1
fi

if [[ "$INTERFACE" == "" ]]
then
	INTERFACE="wlan0"
fi

x=`iwconfig mon4`

if [[ "$x" == "" ]]
then
	airmon-ng start $INTERFACE 1
	airmon-ng start $INTERFACE 1
	airmon-ng start $INTERFACE 1
	airmon-ng start $INTERFACE 1
	airmon-ng start $INTERFACE 1
fi

sed "s/<ESSID>/$ESSID/" wifi_honey_template.rc | sed "s/<CHANNEL>/$CHANNEL/" > screen_wifi_honey.rc
screen -c screen_wifi_honey.rc
```