#FROM owncloud:latest
#FROM php:5.6-apache
FROM cedrik/php5-base:latest
MAINTAINER Cédrik LIME

# see https://github.com/docker-library/owncloud/blob/master/9.0/apache/Dockerfile
# https://doc.owncloud.org/server/9.0/admin_manual/installation/source_installation.html#prerequisites
# https://doc.owncloud.org/server/9.0/admin_manual/configuration_server/performance_tuning.html


COPY owncloud.conf /etc/apache2/conf-enabled/
COPY logrotate-owncloud-dump /etc/logrotate.d/owncloud-dump
COPY backup_conf_local.sh restore_conf_local.sh  /usr/local/bin/

############### FIXME  change depending on base OS / version! ###############
#ARG OWNCLOUD_VERSION=9.0
ARG OWNCLOUD_VERSION=stable

RUN echo "deb https://download.owncloud.org/download/repositories/${OWNCLOUD_VERSION}/`lsb_release --id | cut -f 2`_`lsb_release --release | cut -f 2`/ /" >> /etc/apt/sources.list.d/owncloud.list
RUN curl -sRL https://download.owncloud.org/download/repositories/${OWNCLOUD_VERSION}/`lsb_release --id | cut -f 2`_`lsb_release --release | cut -f 2`/Release.key | apt-key add -

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	curl bzip2 openssl file sqlite3 \
	libapache2-mod-xsendfile \
	php5.6-gd php5.6-json php5.6-mysql php5.6-curl php5.6-intl php5.6-mcrypt php5.6-imagick php5.6-xml \
	php5.6 php5.6-cli php5.6-ldap php5.6-memcached php5.6-readline php5.6-sqlite php5.6-mbstring \
	#php5.6-pgsql libapache2-mod-php5.6 \
	php5.6-apcu php5.6-redis \
	owncloud-files \
# we need sudo to upgrade DB between OwnCloud versions
	sudo \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
# allow LetsEncrypt.org
	#&& sed -i'.bak' -e 's@\(RewriteEngine on\)$@\1\n  RewriteCond expr "%{REQUEST_URI} !~ m#^\.well-known/acme-challenge/.+#"\n@' /var/www/owncloud/.htaccess \
	#&& sed -i'.bak' -e 's@\(RewriteEngine on\)$@\1\n  RewriteCond "%{REQUEST_URI}" !"^\.well-known/acme-challenge/.+"\n@' /var/www/owncloud/.htaccess \
	&& sed -i'.bak' -e 's@\(RewriteEngine on\)$@\1\n  RewriteRule "^\.well-known/acme-challenge/" - [L]@' /var/www/owncloud/.htaccess \
	&& for m in "remoteip rewrite headers env dir mime"; do a2enmod $m; done \
	&& a2dissite 000-default \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh \
# PHP configuration
	&& echo "\n\n\napc.enable_cli=1" >> /etc/php/5.6/cli/php.ini \
#	&& sed -i'.bak' \
#		-e 's%\(max_file_uploads\) = 20%\1 = 200%' \
#		  /etc/php/5.6/apache2/php.ini \
# statistics tool
	&& if test -f /usr/share/php5/apcu/apc.php; then ln -s /usr/share/php5/apcu/apc.php /var/www/owncloud/; fi \
	&& if test -f /usr/share/doc/php-apcu/apc.php; then ln -s /usr/share/doc/php-apcu/apc.php /var/www/owncloud/; fi

#RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#	&& docker-php-ext-install gd intl mbstring mcrypt mysql pdo_mysql pdo_pgsql pgsql zip

# PECL extensions
#RUN pecl install APCu-beta redis memcached \
#	&& docker-php-ext-enable apcu redis memcached

RUN mkdir -p /opt/owncloud /srv/owncloud/data /srv/owncloud/backup \
	&& chown www-data /opt/owncloud /srv/owncloud/data

COPY autoconfig.php /var/www/owncloud/config/autoconfig.php

# helper script to upgrade ownCloud via command-line
COPY ownCloudUpgrade.sh /

# min[0-59] hour[0-23] dom[1-31] month[1-12] dow[0-7]  command
#RUN crontab -u www-data -l | { cat; echo "*/15  *  *  *  * php -f /var/www/owncloud/cron.php > /dev/null 2>&1"; } | crontab -u www-data -
RUN echo "53  *  *  *  * php -f /var/www/owncloud/cron.php > /dev/null 2>&1" | crontab -u www-data -


#VOLUME /var/www/html
#VOLUME ["/var/log"]

EXPOSE 80 443

CMD ["/sbin/my_init"]
