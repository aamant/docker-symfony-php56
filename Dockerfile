FROM debian:jessie

MAINTAINER Arnaud Amant <contact@arnaudamant.fr>

ENV DEBIAN_FRONTEND noninteractive

COPY sources.list /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y \
        vim php5-fpm php5-cli php5-mcrypt php5-json php5-intl php5-mysql php5-pgsql php5-curl php5-gd php5-apcu php5-xdebug \
        apache2 mysql-client libapache2-mod-fastcgi

RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

RUN a2enmod actions rewrite

COPY symfony.conf /etc/apache2/sites-available/symfony.conf
COPY fastcgi.conf /etc/apache2/mods-enabled/fastcgi.conf

COPY php/xdebug.ini /etc/php5/mods-available/xdebug.ini
COPY php/custom.ini /etc/php5/mods-available/custom.ini

RUN a2dissite 000-default
RUN a2ensite symfony

RUN php5enmod -s fpm custom
RUN php5enmod -s cli custom

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php  --install-dir=usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

EXPOSE 80

VOLUME /sources

WORKDIR /sources

CMD /etc/init.d/php5-fpm start && /usr/sbin/apache2ctl -D FOREGROUND