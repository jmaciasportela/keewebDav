#!/bin/bash

if [[ -n "${EXTERNAL_URL}" ]]; then
  sed -i "s@(no-config)@$EXTERNAL_URL/config.json@g" /var/www/html/index.html
fi

sed -i "s@<title>KeeWeb</title>@<title>$PAGE_TITLE</title>@g" /var/www/html/index.html
sed -i "s@SERVER_FQDN@$SERVER_FQDN@g" /etc/apache2/sites-enabled/000-default.conf
sed -i "s@SERVER_FQDN@$SERVER_FQDN@g" /etc/apache2/sites-enabled/default-ssl.conf

#Create webdav user for keeweb
htpasswd -cb /etc/apache2/.htpasswd $APP_WEBDAV_USER_NAME $APP_WEBDAV_PASSWORD
sed -i "s/KDBX_FILE/$APP_KDBX_FILE/" /var/www/html/config.json
sed -i "s/WEBDAV_USER/$APP_WEBDAV_USER_NAME/" /var/www/html/config.json
sed -i "s/WEBDAV_PASSWORD/$APP_WEBDAV_PASSWORD/" /var/www/html/config.json

service apache2 restart
tail -f /dev/null
