FROM ubuntu:focal
LABEL maintainer="Jesus Macias Portela <jesus.maciasportela@telefonica.com>"

#Docker build arguments
ARG APP_WEBDAV_USER_NAME="operator"
ARG APP_WEBDAV_PASSWORD="example_F17umLFNuL7cdXAK"
ARG APP_KDBX_FILE="sample.kdbx"
ARG KEEWEB_VERSION="1.15.7"

ENV DEBIAN_FRONTEND noninteractive

#Install requirements
RUN apt-get update && \
    apt-get install -y apache2 wget nano apache2-utils openssl unzip && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

#Enable Apache2 modules
RUN a2enmod dav && \
    a2enmod dav_fs && \
    a2enmod auth_digest && \
    a2enmod rewrite && \
    a2enmod headers && \
    a2enmod ssl

#Copy Apache2 config files
COPY files/000-default.conf /etc/apache2/sites-available
COPY files/default-ssl.conf /etc/apache2/sites-available

#Enable SSL VirtualHost
RUN a2ensite default-ssl

#Create Apache2 certificate
RUN mkdir /etc/apache2/ssl && \
    cd /etc/apache2/ssl && \
    openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -keyout cert.key -out cert.pem -subj "/C=ES/ST=CyL/L=Valladolid/O=FM/OU=IT Department/CN="

#Create webdav user for keeweb
RUN htpasswd -cb /etc/apache2/.htpasswd ${APP_WEBDAV_USER_NAME} ${APP_WEBDAV_PASSWORD}

#Deploy KeeWeb
RUN cd /var/www/html && \
    rm -fr * && \
    wget https://github.com/keeweb/keeweb/releases/download/v${KEEWEB_VERSION}/KeeWeb-${KEEWEB_VERSION}.html.zip && \
    unzip KeeWeb-${KEEWEB_VERSION}.html.zip && \
    rm KeeWeb-${KEEWEB_VERSION}.html.zip && \
    chown -R www-data:www-data /var/www/

RUN touch /var/www/html/blank.html

RUN cd /var/www/html/ && \
    mkdir webdav
COPY files/${APP_KDBX_FILE} /var/www/html/webdav

COPY files/config.json /var/www/html/config.json
RUN sed -i "s/KDBX_FILE/${APP_KDBX_FILE}/" /var/www/html/config.json && \
    sed -i "s/WEBDAV_USER/${APP_WEBDAV_USER_NAME}/" /var/www/html/config.json && \
    sed -i "s/WEBDAV_PASSWORD/${APP_WEBDAV_PASSWORD}/" /var/www/html/config.json

RUN chown -R www-data:www-data /var/www/html

COPY files/init.sh /init.sh
RUN ["chmod", "+x", "/init.sh"]

EXPOSE 80 443

CMD [ "/init.sh" ]