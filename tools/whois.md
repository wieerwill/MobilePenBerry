# Whois
This package provides a commandline client for the WHOIS (RFC 3912) protocol, which queries online servers for information such as contact details for domains and IP address assignments. It can intelligently select the appropriate WHOIS server for most queries.

The package also contains `mkpasswd`, a features-rich front end to the password encryption function crypt(3).

To install: `sudo apt install whois`

## whois 
Client for the whois directory service
```bash
# show help page
whois --help
# Usage: whois [OPTION]... OBJECT...
whois google.com
```

## mkpasswd
Overfeatured front end to crypt(3)
```bash
# show help page
mkpasswd -h
# Usage: mkpasswd [OPTIONS]... [PASSWORD [SALT]]
mkpasswd -S secretsalt -R 12 -P superstrongpassword1234
```