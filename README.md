# README
A simple and rough app that stores and serves tagged images.

### Requirements
- imagemagick: `apt-get install imagemagick`
- ffmpeg: `apt-get install ffmpeg`
- ffmpegthumbnailer: `apt-get install ffmpegthumbnailer` - https://github.com/dirkvdb/ffmpegthumbnailer

### Sample httpd setup
```
apt-get install apache2
a2enmod proxy
a2enmod proxy_httpd
```

### Sample httpd config
```
# /etc/apache2/sites-enables/000-default.conf
<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        DocumentRoot /var/www/imagegallery/public
        ProxyPass /images !

        ProxyPass / http://0.0.0.0:9292/
        ProxyPassReverse / http://0.0.0.0:9292/

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

Listen 9282
<VirtualHost *:9282>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        DocumentRoot /var/www/imagegallery3d/public
        ProxyPass /images !

        ProxyPass / http://0.0.0.0:9291/
        ProxyPassReverse / http://0.0.0.0:9291/

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog ${APACHE_LOG_DIR}/error1.log
        CustomLog ${APACHE_LOG_DIR}/access1.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>
```

### AutoHotKey
There is an included AutoHotKey script to be able to add an image/video directly from the a web browser. See `autohotkey/download.ahk`.
#### Usage
First, replace the `<HOST>`value at the end of the script to match your server. Once you load up the script, press `CTRL+SHIFT+W` when your current tab is open to a SankakuChannel post. The image/video should be downloaded on your server and added to the database.

### TamperMonkey
Included in the `tampermonkey` directory is a set of scripts to make life easier when browsing sites.
#### sankaku_hightlight.js
Marks images you already have in your local app directly in browser when using the Sankaku channel. To use, simply change the URL in the file to point to your image gallery and add it to TamperMonkey. It will draw a green background behind any images you're browsing that you already have.
#### sankaku_add.js
Adds a button to any post on the Sankaku channel to add that image to your image gallery instance. To use, replace the URL to point to your instance.
