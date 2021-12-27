# Static Server with NGINX
NGINX is a very powerful web server. You can do a ton of things with it, such as setting up reverse proxies or load balancing. It can also be used to host your static website.

## Installation
Install the NGINX package
```bash
sudo apt update
sudo apt install nginx
```

Install from source
```bash
sudo apt install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev -y
wget http://nginx.org/download/nginx-1.21.4.tar.gz
tar -zxvf nginx-1.21.4.tar.gz
sudo rm -r nginx-1.21.4.tar.gz
git clone https://github.com/GetPageSpeed/ngx_security_headers.git
cd nginx-1.21.4
./configure --prefix=/var/www/html \
   --sbin-path=/usr/sbin/nginx \
   --conf-path=/etc/nginx/nginx.conf \
   --http-log-path=/var/log/nginx/access.log \
   --error-log-path=/var/log/nginx/error.log \
   --with-pcre  \
   --lock-path=/var/lock/nginx.lock \
   --pid-path=/var/run/nginx.pid \
   --with-http_ssl_module \
   --with-http_image_filter_module=dynamic \
   --modules-path=/etc/nginx/modules \
   --with-http_v2_module \
   --with-stream=dynamic \
   --with-http_addition_module \
   --with-http_mp4_module \
   --add-module=../ngx_security_headers
make
make install
```

## Move your website’s static files to the server
By default, NGINX expects your static files to be in a specific directory. You can override this in the configuration. Defaults assume that you’ll be putting your website’s static files in the `/var/www/` directory.

Hint: <mywebsite> consists of the domain name and domain extension, e.g. `example.com`

Create a directory in `/var/www/` names as you like. This is where your static website’s files will go.
```bash
sudo mkdir /var/www/<websitename>
```

Copy or create your website’s static files into that folder. cd into your website’s directory and run:
```bash
# creating files
touch /var/www/<mywebsite>/index.html
sudo nano /var/www/<mywebsite>/index.html
# copy/move files
cp ./index.html /var/www/<mywebsite>/
mv ./index.html /var/www/<mywebsite>/
# safe copy to network destination
scp -r * <username>@<ip>:/var/www/<mywebsite>
```

## Configure NGINX to serve your website
The NGINX configuration files are located at `/etc/nginx/`. We need to tell NGINX about the website and how to serve it.
The two directories we are interested in are sites-available and sites-enabled.
- `sites-available` contains individual configuration files for all possible static websites
- `sites-enabled` contains links to the configuration files that NGINX will actually read and run

To enable a website, we create a configuration file in `sites-available` and create a symbolic link of that file in `sites-enabled` to tell NGINX to run it.
```bash
sudo nano /etc/nginx/sites-available/<mywebsite>
```
Add the following text to it
```bash
server {
  listen 80 default_server;
  listen [::]:80 default_server;  
  root /var/www/<mywebsite>;  
  index index.html;  
  server_name <mywebsite> www.<mywebsite>;  
  location / {
    try_files $uri $uri/ =404;
  }
}
```
This file tells NGINX several things:
- Deliver files from the folder `/var/www/<mywebsite>`
- The main index page is called `index.html`
- Requests that are requesting `<mywebsite>` should be served by this server block
- Note the www is also listed separately. This tells nginx to also route requests starting with www to the site. There’s actually nothing special about the www — it’s treated like any other subdomain

Now that the file is created, we’ll add it to the sites-enabled folder to tell NGINX to enable it.
```bash
# use like: ln -s <SOURCE_FILE> <DESTINATION_FILE>
ln -s /etc/nginx/sites-available/<mywebsite> /etc/nginx/sites-enabled/<mywebsite>
```

Now restart NGINX and you should see your site at your localhost port
```bash
sudo systemctl restart nginx
```

If it gives you an error, there’s likely a syntax error.

## Enable HTTPS
With free SSL certs from LetsEncrypt, you can enable HTTPS for your website. In addition to the improved security, there’s significant performance opportunities it allows via HTTP/2, you’ll increase user confidence and you’ll even rank higher in SEO.

### Acquire an SSL cert
There’s multiple ways to do this. You can buy a single-domain certification or a wildcard certification if you plan on securing subdomains.

You can also go the free route via LetsEncrypt:
```bash
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx
sudo certbot --nginx certonly
```
Follow the instructions. This will install certs in `/etc/letsencrypt/live/<mywebsite>/`

To enable auto-renewal for certificates, edit the crontab and create a CRON job to run the renewal command:
```bash
sudo crontab -e
```
And add the following line:
```
17 7 * * * certbot renew --post-hook "systemctl reload nginx"
```

### Tell NGINX to use the SSL cert
Modify the configuration file created before. Add the following text, changing the paths to point to the certificate file and the key file (usually stored in`/etc/nginx/certs/`):
```bash
server {
   # ...previous content
   ssl on;
   ssl_certificate /etc/letsencrypt/live/<mywebsite>/fullchain.pem;
   ssl_certificate_key /etc/letsencrypt/live/<mywebsite>/privkey.pem;
```

A problem now occurs as port 80 was used for HTTP no longer of use as HTTPS uses port 443. Change that in the configuration
```bash
server {
   listen 443 default_server;
   listen [::]:443 default_server;
   #... all other content
}
```
As this will prevent people to access your page over HTTP we need to redirect HTTP requests to HTTPS. Add the following code after the HTTPS server code into your configuration file of the webpage
```bash
server {
       listen 0.0.0.0:80;
       server_name <mywebsite> www.<mywebsite>;
       rewrite ^ https://$host$request_uri? permanent;
}
```

This will redirect all requests to <mywebsite> and www.<mywebsite> on port 80 to the HTTPS URL on port 443.
Restart NGINX to make the changes happen: `sudo systemctl restart nginx`

Test the configuration by going to the four variations of the URL, eg.:
- http://<mywebsite>
- https://<mywebsite>
- http://www.<mywebsite>
- https://www.<mywebsite>

They should all work and be secured via HTTPS.

## Improve performance
### Enable HTTP/2
HTTP/2 allows browsers to request files in parallel, greatly improving the speed of delivery. We need HTTPS enabled. Edit the browser configuration file, adding http2 to the listen directive, then restart NGINX:
```bash
server {
   listen 443 http2 default_server;
   listen [::]:443 http2 default_server;
   #... all other content
}
```

### Enable client-side caching
Some files never change or change rarely, so  users can prevent re-download too often. Set the cache control headers to provide hints to browsers to let those know what files they shouldn’t request again.
```bash
server {
   #...after the location / block
   location ~* \.(jpg|jpeg|png|gif|ico)$ {
       expires 30d;
    }
    location ~* \.(css|js)$ {
       expires 7d;
    }
}
```
Set the times after own experience. 

### Dynamically route subdomains
In the case of subdomains, you may not want to route every subdomain to the correct folder. Create a wildcard server to route matching names. Edit your website configuration therefore:
```bash
server {
       server_name ~^(www\.)(?<subdomain>.+).<mywebsite>$ ;
       root /var/www/<mywebsite>/$subdomain;
}
server {
        server_name ~^(?<subdomain>.+).<mywebsite>$ ;
        root /var/www/<mywebsite>/$subdomain;
}
```

Restart NGINX and route subdomains automatically to the same-named subfolder.

## remove the Server header
Security through obscurity isn’t the holy grail that will make any website secure completely. But as a complementary security measure, it can be used.

NGINX, by default, sends information about its use in the Server HTTP header as well as error pages, e.g.: nginx/1.16.1.

To confirm the currently emitted header, run `curl -IsL https://example.com/ | grep -i server`

### hide version information
The standard security solution is hiding NGINX version information. In the `/etc/nginx/nginx.conf`:
```bash
http {
   ...
   server_tokens off;
   ...
}
```
This only hides the specific version of NGINX from the Server header and error pages. 
The header becomes: `Server: nginx`

### hide server header
#### using ngx_security_headers module
Easiest method is using the package made to extend NGINX:
```bash
sudo apt install nginx-module-security-headers
```
Edit the `nginx.conf` like:
```bash
load_module modules/ngx_http_security_headers_module.so;

http {
    ...
    hide_server_tokens on;
    ...
}
```
Now the Server header is completely eliminated from the responses.

#### using Headers More module
Another module to use is:
```bash
sudo apt install nginx-module-headers-more
```
Edit the `nginx.conf` like:
```bash
load_module modules/ngx_http_headers_more_filter_module.so;

http {
    ...
    more_clear_headers Server;
    ...
}
```
Likewise, the Server header will be completely gone from the responses.

### hide the use of NGINX
Hiding the Server header is good but the default error pages by NGINX still output the "nginx" word in them.

An easy way to complete hiding of NGINX presence on the server is using NGINX-MOD.
Simply specify the following in the configuration: `server_tokens none;`

Alternatively hide the NGINX presence by recompiling it from the source (highly discouraged, see common pitfalls). Adjust NGINX sources to prevent the information disclosure of NGINX software.
```bash
sed -i 's@"nginx/"@"-/"@g' src/core/nginx.h
sed -i 's@r->headers_out.server == NULL@0@g' src/http/ngx_http_header_filter_module.c
sed -i 's@r->headers_out.server == NULL@0@g' src/http/v2/ngx_http_v2_filter_module.c
sed -i 's@<hr><center>nginx</center>@@g' src/http/ngx_http_special_response.c
```
Then recompile NGINX.
