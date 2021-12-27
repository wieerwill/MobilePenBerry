# Wifipisher
Wifiphisher is a security tool that mounts automated phishing attacks against Wi-Fi networks in order to obtain credentials or infect the victims with ‘malware’. It is a social engineering attack that can be used to obtain WPA/WPA2 secret passphrases and unlike other methods, it does not require any brute forcing.
After achieving a man-in-the-middle position using the Evil Twin attack, Wifiphisher redirects all HTTP requests to an attacker-controlled phishing page.
From the victim’s perspective, the attack takes place in three phases:
- Victim is deauthenticated from their access point.
- Victim joins a rogue access point. Wifiphisher sniffs the area and copies the target access point settings.
- Victim is served a realistic specially-customized phishing page.

## install
Download the latest revision
```bash
git clone https://github.com/wifiphisher/wifiphisher.git 
# Switch to tool's directory
cd wifiphisher
# Install any dependencies
apt-get install libnl-3-dev libnl-genl-3-dev
pip3 install PyRic pbkdf2
sudo python3 setup.py install 
```

to use `wifiphisher -nJ --essid "FREE WI-FI" -p oauth-login -kB`

# Source and more informations
[Wifipisher](https://wifiphisher.org/docs.html)