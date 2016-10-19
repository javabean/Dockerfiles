#FROM prestashop/prestashop:1.6
#FROM php:5.6-apache
FROM cedrik/php5-base:latest
MAINTAINER Cédrik LIME

# https://hub.docker.com/r/prestashop/prestashop/
# http://doc.prestashop.com/display/PS16/Getting+Started
# http://doc.prestashop.com/display/PS16/System+Administrator+Guide

############### FIXME  change version here! ###############
ARG PRESTASHOP_VERSION=1.6.0.14

COPY prestashop.conf /etc/apache2/conf-enabled/
COPY backup_conf_local.sh restore_conf_local.sh  /usr/local/bin/
COPY GeoIP.conf /etc/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	#php5.6-mysql mysql-client=${MYSQL_VERSION}.* mysql-common=${MYSQL_VERSION}.* wget curl unzip xz-utils \
	libmcrypt4 libjpeg62 libjpeg-turbo8 libpng12-0 libfreetype6 libxml2 wget curl unzip xz-utils \
	php5.6-curl libxml2 php5.6-mcrypt php5.6-gd openssl php5.6-soap gzip \
	curl wget openssl unzip libmcrypt4 \
	php5.6-gd php5.6-curl php5.6-mcrypt \
	php5.6-json php5.6-intl php5.6-imagick \
	php5.6-memcache php5.6-memcached \
	php5.6-apcu \
	php5.6-geoip \
	#geoipupdate geoip-bin mmdb-bin\
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& for m in "rewrite headers env mime"; do a2enmod $m; done \
	# PHP configuration
	&& sed -i'.bak' \
		-e 's%\(memory_limit\) = .*M%\1 = 64M%' \
		-e 's%\(upload_max_filesize\) = .*M%\1 = 8M%' \
		/etc/php/5.6/apache2/php.ini

#RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
#	&& docker-php-ext-install iconv mcrypt pdo mysql pdo_mysql mbstring soap gd

RUN curl -fsSLR -o /tmp/prestashop.zip https://www.prestashop.com/download/old/prestashop_${PRESTASHOP_VERSION}.zip \
	&& unzip -q /tmp/prestashop.zip -d /tmp/ \
	&& rm -r /tmp/prestashop/*.md /tmp/prestashop/docs \
	&& mv /var/www/html/index.html /var/www/html/index.html.bak \
	&& mv /tmp/prestashop/* /var/www/html/ \
	&& if [ ! -z "$PS_FOLDER_INSTALL" ]; then mv -v /var/www/html/install "/var/www/html/$PS_FOLDER_INSTALL"; fi \
	&& if [ ! -z "$PS_FOLDER_ADMIN" ]; then mv -v /var/www/html/admin "/var/www/html/$PS_FOLDER_ADMIN"; fi \
	&& cd /var/www/html/tools/geoip && curl -fsSLRO http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.xz && unxz -f GeoLiteCity.dat.xz && cd - \
	#&& geoipupdate \
	&& chown www-data:www-data -R /var/www/html/ \
# statistics tool
	&& if test -f /usr/share/php5/apcu/apc.php; then ln -s /usr/share/php5/apcu/apc.php "/var/www/html/${PS_FOLDER_ADMIN:-admin}/"; fi \
	&& if test -f /usr/share/doc/php-apcu/apc.php; then ln -s /usr/share/doc/php-apcu/apc.php "/var/www/html/${PS_FOLDER_ADMIN:-admin}/"; fi \
	&& rm -rf /tmp/* \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh

#ADD https://raw.githubusercontent.com/PrestaShop/docker/master/config_files/docker_updt_ps_domains.php  /var/www/html/

#VOLUME /var/www/html
#VOLUME ["/var/log"]
#VOLUME ["/var/www/html/modules", "/var/www/html/themes", "/var/www/html/override"]

EXPOSE 80 443

#ADD https://raw.githubusercontent.com/PrestaShop/docker/master/config_files/docker_run.sh  /
#ENTRYPOINT ["/docker_run.sh"]

ENTRYPOINT ["/usr/local/sbin/dumb-init", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/apache2ctl"]
