# Keeweb + WebDav

One Paragraph of project description goes here

## Getting Started

I looked for a way to share some credentials across our DevOps Team. Something like 1Password for Teams but self hosted. It is deployed inside our internal network, so we access the webapp throught VPN. File KDBX it protected itself with strong password and optional keyfile.

### Prerequisites

* Docker
* Docker Compose

### Preparing

Edit docker-compose.yml and adjust environment vars with your setting

```
version: '3'

services:
  keeweb:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: keeweb
    image: keeweb_container
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    environment:
      - EXTERNAL_URL=https://itteam-vault.company.local
      - PAGE_TITLE="IT Team Vault"
      - SERVER_FQDN=itteam-vault.company.local
      - APP_KDBX_FILE=it-db.kdbx
      - APP_WEBDAV_USER_NAME=operator
      - APP_WEBDAV_PASSWORD=example_111umLFNuL7cdXAK
    volumes:
      - /opt/certs/itteam-vault.company.local.crt:/etc/apache2/ssl/cert.pem
      - /opt/itteam-vault.company.local.key:/etc/apache2/ssl/cert.key
      - webdav-volume:/var/www/html/webdav
volumes:
  webdav-volume:
    driver: local
```

### Deploy

From the same folder where you have this project cloned

```
docker-compose up -d
```

### Copy your KDBX into the volume

From the same folder where you have this project cloned

```
docker cp your.kdbx keeweb:/var/www/html/webdav/it-db.kdbx
docker exec -ti chown -R www-data:/var/www/html/webdav/it-db.kdbx
```

### Stop

From the same folder where you have this project cloned

```
docker-compose down
```

### Rebuild

From the same folder where you have this project cloned

```
docker-compose build
```

### Backup KDBX

Add this line to your crontab and adjust the interval to have new backups.

```
00 0    * * *   root    docker cp keeweb:/var/www/html/webdav/it-db.kdbx /opt/keeweb_backup/it-db-$(date +\%Y\%m\%d\%H\%M\%S).kbdx
```

Should have another mechanism to backup the files on /opt/keeweb_backup folder to other external system.

NOTE: Maybe there is a better way to perform this, but is not possible to mount kdbx files as a volume because webdav fails because of a problem with write permissions.

## References

* https://keeweb.info/
* https://www.zaine.me/posts/keeweb-passwd-manager/
* https://www.digitalocean.com/community/tutorials/how-to-configure-webdav-access-with-apache-on-ubuntu-14-04
