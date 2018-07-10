FROM ubuntu:xenial
MAINTAINER Thomas Ruta

#prepair Server
#RUN sudo -s
#RUN sudo passwd root
RUN apt-get update && \
    apt-get -yq install ssh openssh-server nano vim-nox

# Install packages
RUN apt-get update && \
    apt-get -yq --force-yes install mysql-client git curl  apache2 apache2-doc apache2-utils libapache2-mod-php  php7.0 php7.0-common php7.0-gd php7.0-mysql php7.0-imap php7.0-cli \
    php7.0-cgi libapache2-mod-fcgid apache2-suexec-pristine php-pear php-auth php7.0-mcrypt mcrypt graphicsmagick imagemagick libruby libapache2-mod-python php7.0-curl php7.0-intl php7.0-pspell php7.0-recode \
    php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl memcached php-memcache php-imagick php-gettext php7.0-zip php7.0-mbstring  php7.0-soap php-xdebug php7.0-json php7.0-opcache php-apcu libapache2-mod-fastcgi \
    php7.0-fpm

#RUN ufw enable &&  ufw allow from 0.0.0.0 to 127.0.0.1 port http && \
#    ufw allow from 0.0.0.0 to 127.0.0.1 port https && ufw allow from 0.0.0.0 to 127.0.0.1 port ssh

RUN a2enmod rewrite ssl actions include cgi
RUN a2enmod dav_fs dav auth_digest headers

#RUN apt-get install php7.0-opcache php-apcu libapache2-mod-fastcgi php7.0-fpm
RUN a2enmod actions fastcgi alias
RUN rm /etc/apache2/sites-enabled/000-default.conf -rf
RUN mkdir /var/www/php-fcgi-scripts && mkdir /var/www/tmp && mkdir /var/www/cgi-bin

ADD .php-fcgi-starter /var/www/php-fcgi-scripts/
RUN chmod 755 /var/www/php-fcgi-scripts/.php-fcgi-starter && chown www-data:www-data /var/www/php-fcgi-scripts/.php-fcgi-starter
RUN useradd -m -g www-data -s /bin/bash typo3user
RUN echo AllowUsers typo3user >> /etc/ssh/sshd_config && sed -i "s/.*PasswordAuthentication .*/PasswordAuthentication  yes/g" /etc/ssh/sshd_config

#cert for cag_tests
ADD id_rsa  /root/.ssh/
ADD id_rsa.pub  /root/.ssh/
RUN chmod 600 /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa.pub
RUN eval `ssh-agent`
#&& ssh-add /root/.ssh/id_rsa.pub

# Adjust some php settings
ADD typo3.php.ini /etc/php/7.0/cgi/conf.d/
# place run script
ADD run-typo3.sh /var/www/cgi-bin/
RUN chmod 755 /var/www/cgi-bin/

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN cp /composer.phar /var/www/composer.phar

RUN php /var/www/composer.phar --dev --stability=dev create-project web-tp3/tp3_installer:dev-8.x-dev typo3
RUN rm -R /var/www/html -rf && mv /typo3 /var/www/html

#ADD .htaccess  /var/www/html/web/
VOLUME [ "/var/www/html/web/uploads", "/var/www/html/web/fileadmin", "/var/www/html/web/typo3temp" ,"/var/www/html/web/error" ]
RUN chown typo3user:www-data -R /var/www/html/ && chmod 775 -R /var/www/html/web/

ADD typo3.conf /etc/apache2/sites-enabled/000-default.conf

# Expose environment variables
ENV DB_HOST **LinkMe**
ENV DB_PORT **LinkMe**
ENV DB_NAME typo3
ENV DB_USER root
ENV DB_PASS my-secret-pw
ENV INSTALL_TOOL_PASSWORD password
RUN service apache2 start
RUN service ssh start
RUN bash /var/www/cgi-bin/run-typo3.sh
#CMD ["/bin/bash", "-c", "/var/www/cgi-bin/run-typo3.sh"]

#ADD AdditionalConfiguration.php /var/www/html/web/typo3conf/
# Install dependencies defined in composer.json
#ADD composer.json /var/www/html/
#RUN cp /var/www/html/web/typo3conf/ext/typo3_console/Scripts/typo3cms/* /var/www/html/
#apache
EXPOSE 80
#ssh
EXPOSE 22
#Xdebug
EXPOSE 9000