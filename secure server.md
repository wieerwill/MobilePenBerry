# Secure NGINX server
After installing und setting up the NGINX server it should be secured. Here are the most popular steps. Implement all or only those you want.

## Default Config Files and Nginx Port
- `/usr/local/nginx/conf/` or `/etc/nginx/` - The nginx server configuration directory 
- `/usr/local/nginx/conf/nginx.conf` is main configuration file
- `/usr/local/nginx/html/` or `/var/www/html` - The default document location
- `/usr/local/nginx/logs/` or `/var/log/nginx` - The default log file location
- Nginx HTTP default port : TCP 80
- Nginx HTTPS default port : TCP 443

Test NGINX configuration changes by
```bash
/usr/local/nginx/sbin/nginx -t
# or
nginx -t
```
To load config changes, type `/usr/local/nginx/sbin/nginx -s reload` oder `nginx -s reload`

## Linux hardening
Configure the kernel and network settings at `/etc/sysctl.conf`
```bash
# Avoid a smurf attack
net.ipv4.icmp_echo_ignore_broadcasts = 1
 
# Turn on protection for bad icmp error messages
net.ipv4.icmp_ignore_bogus_error_responses = 1
 
# Turn on syncookies for SYN flood attack protection
net.ipv4.tcp_syncookies = 1
 
# Turn on and log spoofed, source routed, and redirect packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
 
# No source routed packets here
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
 
# Turn on reverse path filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
 
# Make sure no one can alter the routing tables
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
 
# Don't act as a router
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
 
# Turn on execshild
kernel.exec-shield = 1
kernel.randomize_va_space = 1
 
# Tune IPv6
net.ipv6.conf.default.router_solicitations = 0
net.ipv6.conf.default.accept_ra_rtr_pref = 0
net.ipv6.conf.default.accept_ra_pinfo = 0
net.ipv6.conf.default.accept_ra_defrtr = 0
net.ipv6.conf.default.autoconf = 0
net.ipv6.conf.default.dad_transmits = 0
net.ipv6.conf.default.max_addresses = 1
 
# Optimization for port usefor LBs
# Increase system file descriptor limit
fs.file-max = 65535
 
# Allow for more PIDs (to reduce rollover problems); may break some programs 32768
kernel.pid_max = 65536
 
# Increase system IP port limits
net.ipv4.ip_local_port_range = 2000 65000
 
# Increase TCP max buffer size setable using setsockopt()
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 87380 8388608
 
# Increase Linux auto tuning TCP buffer limits
# min, default, and max number of bytes to use
# set max to at least 4MB, or higher if you use very high BDP paths
# Tcp Windows etc
net.core.rmem_max = 8388608
net.core.wmem_max = 8388608
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_window_scaling = 1
```

## remove all unnecassery NGINX-modules
Reduce the number of modules, that compile into the NGINX binary file. This will minimise the risks, as the allowed functions are reduced. For example deactive the SSI and autoindex module:
```bash
./configure --without-http_autoindex_module --without-http_ssi_module
make
make install
```
Use the following command to list all activated and deactivated modules:
```bash
./configure --help | less
```
This only works if you configured and installed NGINX from source.

## limit available methods
GET and POST are the most common methods on the Internet. Web server methods are defined in RFC 2616. If a web server does not require the implementation of all available methods, they should be disabled. The following will filter and only allow GET, HEAD and POST methods. Add it to the website configuration.
```bash
## Only allow these request methods ##
     if ($request_method !~ ^(GET|HEAD|POST)$ ) {
         return 444;
     }
## Do not accept DELETE, SEARCH and other methods ##
```
More About HTTP Methods
- The GET method is used to request document
- The HEAD method is identical to GET except that the server MUST NOT return a message-body
- The POST method may involve anything, like storing or updating data, or ordering a product

## deny certain User-Agents
Add following to the website configuration.
Easily block user-agents i.e. scanners, bots and spammers who may abuse the server.
```bash
## Block download agents
     if ($http_user_agent ~* LWP::Simple|BBBike|wget) {
            return 403;
     }
##
```

Block robots called msnbot and scrapbot:
```bash
## Block some robots
     if ($http_user_agent ~* msnbot|scrapbot) {
            return 403;
     }
```

## block referral Spam
Referer spam is dangerouns. It can harm the SEO ranking via web-logs (if published) as referer field refer to their spammy site. Block access to referer spammers with these lines (in your config file)
```bash
## Deny certain Referers ###
     if ( $http_referer ~* (babes|forsale|girl|jewelry|love|nudit|organic|poker|porn|sex|teen) )
     {
         # return 404;
         return 403;
     }
##
```

## stop image hotlinking
Image or HTML hotlinking means someone creates a link to an images on one webpage but displays it on their own site. It will make content look like their own and pollute the bandwidth. This is often done on forums and blogs. Change it in your configuration
```bash
# Stop deep linking or hot linking
location /images/ {
  valid_referers none blocked www.example.com example.com;
   if ($invalid_referer) {
     return   403;
   }
}
```
Another example with link to a banned image
```bash
valid_referers blocked www.example.com example.com;
 if ($invalid_referer) {
  rewrite ^/images/uploads.*\.(gif|jpg|jpeg|png)$ http://www.examples.com/banned.jpg last
 }
```

# directory restrictions
Set access control for a specified directory. All web directories should be configured on a case-by-case basis, allowing access only where needed.
E.g. Limiting Access By Ip Address to /docs/ directory:
```bash
location /docs/ {
  ## block one workstation
  deny    192.168.1.1;
  ## allow anyone in 192.168.1.0/24
  allow   192.168.1.0/24;
  ## drop rest of the world
  deny    all;
}
```

To password protect the directory first create the password file and add a user
```bash
mkdir /usr/local/nginx/conf/.htpasswd/
htpasswd -c /usr/local/nginx/conf/.htpasswd/passwd <username>
```
Edit `nginx.conf` and protect the required directories as follows
```bash
# password protect /personal-images/ and /delta/ directories
location ~ /(personal-images/.*|delta/.*) {
  auth_basic  "Restricted";
  auth_basic_user_file   /usr/local/nginx/conf/.htpasswd/passwd;
}
```
Once a password file has been generated, subsequent users can be added with the following command:
```bash
htpasswd -s /usr/local/nginx/conf/.htpasswd/passwd <username>
```

## Limit connections per IP at firewall level
A webserver must keep an eye on connections and limit connections per second. This is serving 101. Iptables can throttle end users before accessing a NGINX server.

The following example will drop incoming connections if an IP make more than 15 connection attempts to port 80 within 60 seconds:
```bash
/sbin/iptables -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --set
/sbin/iptables -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --update --seconds 60  --hitcount 15 -j DROP
service iptables save
```

# Secure Apache/PHP/Nginx server
Edit `httpd.conf` file and add the following
```bash
ServerTokens Prod
ServerSignature Off
TraceEnable Off
Options all -Indexes
Header always unset X-Powered-By
```
Restart the httpd/apache2 server on Linux
```bash
sudo systemctl restart apache2.service`
# or
sudo systemctl restart httpd.service
```


# Sources and more
https://www.cyberciti.biz/tips/linux-unix-bsd-nginx-webserver-security.html