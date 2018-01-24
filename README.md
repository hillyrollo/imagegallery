# README
A simple and rough app that stores and serves tagged images.

### Requirements
- imagemagick: `apt-get install imagemagick`
- ffmpeg: `apt-get install ffmpeg`
- ffmpegthumbnailer: `apt-get install ffmpegthumbnailer` - https://github.com/dirkvdb/ffmpegthumbnailer

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

### AutoHotKey
There is an included AutoHotKey script to be able to add an image/video directly from the a web browser. See `autohotkey/download.ahk`.
#### Usage
First, replace the `<HOST>`value at the end of the script to match your server. Once you load up the script, press `CTRL+SHIFT+W` when your current tab is open to a SankakuChannel post. The image/video should be downloaded on your server and added to the database.
