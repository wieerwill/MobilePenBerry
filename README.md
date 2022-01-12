# Mobile Pen(etration) (Rasp)Berry(Pi)
This is a little project aiming for a multi-purpose mobile Penetration, Pwning and Wifi-Testing Station on a RaspberryPi. 

Next to that i gather all snippets and helps related to RaspberryPi and additonal parts.

Warning: 
- This project are for **LAWFUL, ETHICAL AND EDUCATIONAL PURPOSES ONLY**.
- Many countries forbid accessing or deauthenticating networks without explicit permission. Make sure you got the permission of network owners or only test your very own networks.
- The files contained in this repository are released "as is" without warranty, support, or guarantee of effectiveness.
- **I am open to hearing about any issues found within these files and will be actively maintaining this repository for the foreseeable future. If you find anything noteworthy, let me know and I'll see what I can do about it.**

The author's intent for this project is to provide information on security and possible attacks. Avoid getting into any of those wiretaps or traps yourself by knowing how they work.

Rules
1. Respect the privacy of others.
2. Think before you type.
3. With great power comes great responsibility.

## Requirements
- Computer with SSH (Linux-type in this repository)
- Raspberry Pi (i will use a RPi4)
- SD card for RPi (8GB and more are prefered, Pwnagotchi wants UHS-I speed and up)
- USB cables (USB-A, USB-C)
- Internet Connection to download packages

Optional:
- Network/LAN Cables
- Wifi antenna/module
- GPS module
- Display
- Power HAT
- Real Time Clock
- additional storage (SD/SSD/HDD adapter)

## Roadmap
You can follow the roadmap step by step or only do what you want. You are free to choose. For a fully built system all articles may be of interest, a more defined small one may only use parts.

Hint: code snippets which are in `<...>` should be replaced by own variables

- [x] [headless setup](headless.md) 
- [x] [configure swap](swap.md)
- [x] [configure wifi](wifi.md)
- [x] [increase the safety of your RPi](secure%20raspbian.md)
- [x] [connect via OTG](OTG.md)
- [x] [connect via Bluetooth](bluetooth.md)
- [x] [Add a power hat](power%20hat.md)
- [x] [Add an extra pair of wifi antennas](wifi%20driver.md)
- [x] [Add an GPS module](gps.md)
- [x] [Add a display (oled or eInk)](display.md)
- [x] [Add a real time clock](rtc.md)
- [x] [Add a camera](camera.md)
- NGNIX 
  - [x] [Create local server](static%20server.md)
  - [x] [Secure your local server](secure%20server.md)
- TOR
  - [x] [create .onion addresses](onion%20adress.md)
  - [x] [Create hidden services with TOR](hidden%20service.md)
  - [x] [share files trough TOR](onionshare.md)
- [x] [Wordlists get & create](wordlists.md)
- [x] [create backups online & offline](backup.md)
- Working with tools
  - Analyzing
    - [ ] Wireshark
    - [ ] Ncat-w32
    - [ ] netdiscover
    - [ ] bluesnarfer
    - [ ] btscanner
    - [ ] traceroute
    - [x] whois
  - Sniffing/Pawning
    - [x] [Bettercap](tools/bettercap.md)
    - [x] [Kismet](tools/kismet.md)
    - [x] [Pwnagotchi](tools/pwnagotchi.md) 
    - [ ] Pwncat
    - [ ] RouterSploit
    - [ ] wifi-honey
  - Hashing/Cracking
    - [x] [Hashcat](tools/hashcat.md)
    - [ ] Sipcrack
    - [x] [coWPAtty](tools/cowpatty.md)
    - [ ] John the Ripper
  - MITM
    - [x] [Wifipisher](tools/wifipisher.md)
    - [ ] sslsniff
    - [ ] dnscat2
    - [ ] websploit
    - [x] [XeroSploit](tools/xerosploit.md)
  - other
    - [ ] Godoh
    - [ ] Macchanger
    - [ ] Sniffjoke
    - [ ] Legion
    - [ ] webshells
    - [ ] Firewalld
    - [ ] Sqlmap
    - [ ] beEF (browser exploitation framework)

# Sources and more helpful informations
[RaspberryPi](https://www.raspberrypi.com/)

[Kali Tools](https://kali.org/tools)