# OnionShare
OnionShare is an open source tool that lets you securely and anonymously share files, host websites, and chat with friends using the Tor network.

Add repository and install packages
```bash
sudo add-apt-repository ppa:micahflee/ppa
sudo apt update
sudo apt install -y onionshare tor python3 python3-pip
# install the cli
pip3 install --user onionshare-cli
# add path to shell
echo "PATH=\$PATH:~/.local/bin" >> ~/.bashrc
source ~/.bashrc
# run it
onionshare-cli --help
```

There are different options like running a chat server
```bash
onionshare-cli --chat
```
Load the shown OnionShare address in Tor Browser to make sure it works

## persistent anonymous dropbox
Let people anonymously upload files to your RPi, make the adress persistent and make it public (without password protection). With this setup everybody can share files with the RPi.
```bash
onionshare-cli --receive --persistent ~/anon-dropbox.session --public
```
Be aware that users now can upload malicious content to your RPi so make sure the directory is not executable.

## multiplex your screen
The onionshare service will stop as the SSH connection is closed or command is stopped. To prevent that use a terminal multiplexer like `screen`
```bash
sudo apt install -y screen
# run it
screen
```
At the bottom of the screen is a new bar with `0 bash` highlighted. This means we are in a screen session. 
Now running onionshare and exiting the SSH session should not end the onionshare service.

After logging in again reconnect to the session with `screen -x`

# Sources and more
[https://github.com/onionshare/onionshare](https://github.com/onionshare/onionshare)