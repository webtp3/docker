FROM ubuntu:bionic
MAINTAINER Thomas Ruta

#set lang tzdata
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
ENV LANG de_DE.utf8
ENV DEBIAN_FRONTEND noninteractive

#prepair Server
#RUN sudo -s
#RUN sudo passwd root
RUN apt-get update && \
    apt-get -yq install ssh openssh-server nano vim-nox

# Install packages
RUN apt-get update && \
    apt-get -yq --force-yes install mysql-client git curl imagemagick apache2 apache2-doc apache2-utils libapache2-mod-php  php7.2 php7.2-common php7.2-gd php7.2-mysql \
    php7.2-imap php7.2-cli php7.2-cgi libapache2-mod-fcgid apache2-suexec-pristine php-pear mcrypt  imagemagick graphicsmagick libruby libapache2-mod-python \
    php7.2-curl php7.2-intl php7.2-pspell php7.2-recode php7.2-sqlite3 php7.2-tidy php7.2-xmlrpc php7.2-xsl memcached php-memcache php-imagick php-gettext php7.2-zip php7.2-mbstring \
    php7.2-soap  php7.2-json php7.2-opcache php-apcu libapache2-mod-fcgid php7.2-fpm


# config apache
RUN a2enmod rewrite ssl actions include cgi
RUN a2enmod dav_fs dav auth_digest headers
#RUN apt-get install php7.2-opcache php-apcu libapache2-mod-fastcgi php7.2-fpm
RUN a2enmod actions alias
ADD typo3.conf /etc/apache2/sites-enabled/000-default.conf
RUN mkdir /var/www/html/php-fcgi-scripts && mkdir /var/www/tmp && mkdir /var/www/cgi-bin

ADD .php-fcgi-starter /var/www/php-fcgi-scripts/
RUN useradd -m -p $6$PuiliFOPUCXV$ZRMim2oiMzecjfw0EtUq3dLEbfyogKRvHze1028pCRV5UKcWMLEF4hi6bQM32eLP.U.P30wCBpib3Hyr5Rdtv1 -s /bin/bash typo3
RUN echo AllowUsers typo3 >> /etc/ssh/sshd_config

#cert for cag_tests
ADD id_rsa  /root/.ssh/
ADD id_rsa.pub  /root/.ssh/
RUN chmod 600 /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa.pub
RUN eval `ssh-agent`
#&& ssh-add /root/.ssh/id_rsa.pub

# Adjust some php settings
ADD typo3.php.ini /etc/php/7.2/cgi/conf.d/

#remove default
RUN rm -fr /var/www/html

#add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN chmod 755 composer.phar
RUN cd /var/www/ && mkdir html
#RUN php composer.phar --stability dev --dev  create-project web-tp3/tp3_installer html


#create dirs for typo3 install
VOLUME [ "/var/www/html/uploads", "/var/www/html/fileadmin" ,"/var/www/html/error" ]

#letscrypt for ssl
RUN apt-get -yq install letsencrypt

# Expose environment variables
ENV DB_HOST **LinkMe**
ENV DB_PORT **LinkMe**
ENV DB_NAME typo3
ENV DB_USER admin
ENV DB_PASS **ChangeMe**
ENV INSTALL_TOOL_PASSWORD password
RUN service apache2 restart
RUN service ssh start

#CMD ["/bin/bash", "-c", "/run-typo3.sh"]
CMD ["/bin/bash", "-c", "/var/www/cgi-bin/run-typo3.sh"]
ADD AdditionalConfiguration.php /var/www/html/typo3conf/

EXPOSE 80
EXPOSE 22