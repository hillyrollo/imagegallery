# README
A simple and rough app that stores and serves tagged images.

### Sample httpd setup
apt-get install apache2
a2enmod proxy
a2enmod proxy_httpd

### Sample httpd config
```
Alias /images /var/www/images
<Directory /var/www/images/>
        Order allow,deny
        Allow from all
</Directory>

DocumentRoot /path/to/app
ProxyPass /images !
ProxyPass / http://127.0.0.1:3000/
ProxyPassReverse / http://127.0.0.1:3000/
```
