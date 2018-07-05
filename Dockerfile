FROM ubuntu:bionic
MAINTAINER Thomas Ruta

#set lang tzdata
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
ENV LANG de_DE.utf8

#prepair Server
#RUN sudo -s
#RUN sudo passwd root
RUN apt-get update && \
    apt-get -yq install ssh openssh-server nano vim-nox

# Install packages
RUN apt-get update && \
    apt-get -yq --force-yes install mysql-client git curl imagemagick apache2 apache2-doc apache2-utils libapache2-mod-php  php7.2 php7.2-common php7.2-gd php7.2-mysql \
    php7.2-imap php7.2-cli php7.2-cgi libapache2-mod-fcgid apache2-suexec-pristine php-pear php-auth php7.2-mcrypt mcrypt  imagemagick libruby libapache2-mod-python \
    php7.2-curl php7.2-intl php7.2-pspell php7.2-recode php7.2-sqlite3 php7.2-tidy php7.2-xmlrpc php7.2-xsl memcached php-memcache php-imagick php-gettext php7.2-zip php7.2-mbstring \
    php7.2-soap  php7.2-json php7.2-opcache php-apcu libapache2-mod-fastcgi php7.2-fpm


# config apache
RUN a2enmod suexec rewrite ssl actions include cgi
RUN a2enmod dav_fs dav auth_digest headers
#RUN apt-get install php7.2-opcache php-apcu libapache2-mod-fastcgi php7.2-fpm
RUN a2enmod actions fastcgi alias
ADD typo3.conf /etc/apache2/sites-enabled/000-default.conf
RUN mkdir /var/www/html/php-fcgi-scripts && mkdir /var/www/tmp && mkdir /var/www/cgi-bin
ADD .php-fcgi-starter /var/www/php-fcgi-scripts

# Adjust some php settings
ADD typo3.php.ini /etc/php/cgi/conf.d/

#remove default
RUN rm -fr /var/www/html

#add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN chmod 755 composer.phar
RUN cd /var/www/
#RUN php composer.phar --stability dev --dev  create-project web-tp3/tp3_installer html

#create dirs for typo3 install
VOLUME [ "/var/www/html/uploads", "/var/www/html/fileadmin"]

#letscrypt for ssl
#RUN apt-get -yq install letsencrypt

# Expose environment variables
ENV DB_HOST **LinkMe**
ENV DB_PORT **LinkMe**
ENV DB_NAME typo3
ENV DB_USER admin
ENV DB_PASS **ChangeMe**
ENV INSTALL_TOOL_PASSWORD password

EXPOSE 80
CMD ["/bin/bash", "-c", "/run-typo3.sh"]

ADD AdditionalConfiguration.php /var/www/html/typo3conf/

# Install dependencies defined in composer.json
#ADD composer.json /var/www/html/
#ADD composer.lock /var/www/html/
#RUN composer install && cp typo3conf/ext/typo3_console/Scripts/typo3cms .
