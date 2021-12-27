# run a hidden service.
Get yourself tor and a webserver like NGNIX
`sudo apt install nginx tor -y`

Enable and start the nginx service. Check if it runs correct
```bash
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx
```
It should promt "active". Do the same with tor
```bash
sudo systemctl enable tor
sudo systemctl start tor
sudo systemctl status tor
```

Create a html file at `/var/www/html`. More details are in [Static Server](static%20server.md). 
Restart NGNIX `sudo systemctl restart nginx`

# link website to tor
The `torrc` file describes the behavior of tor and has everything in it to run a hidden service.
Open it with a text editor: `sudo nano /etc/tor/torrc` and uncomment the following lines
```bash
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 127.0.0.1:80
```
Restart tor `sudo systemctl restart tor`

Now tor will host your webpage. To get your current onion address call
```bash
sudo cat /var/lib/tor/hidden_service/hostname
```

With the given url you can access your page from tor browser.

Read [onion addresses](onion%20adress.md) to create your own address.

# Sources and more
torproject.org