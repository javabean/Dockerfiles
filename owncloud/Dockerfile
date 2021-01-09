#FROM owncloud:latest
#FROM php:7.3-apache
FROM cedrik/php7-base:latest
LABEL org.opencontainers.image.authors="Cédrik LIME"

# see https://github.com/docker-library/owncloud/blob/master/9.1/apache/Dockerfile
# https://doc.owncloud.org/server/10.0/admin_manual/installation/source_installation.html#prerequisites
# https://doc.owncloud.com/server/10.0/admin_manual/configuration/server/oc_server_tuning.html


COPY owncloud.conf /etc/apache2/conf-enabled/
COPY logrotate-owncloud-dump /etc/logrotate.d/owncloud-dump
COPY backup_conf_local.sh restore_conf_local.sh ownCloudUpgrade.sh  /usr/local/bin/

############### FIXME  change depending on base OS / version! ###############
# https://owncloud.org/release-channels/
#ARG OWNCLOUD_VERSION=10.5.0
#ARG OWNCLOUD_VERSION=stable
ARG OWNCLOUD_VERSION=production

#RUN echo "deb https://download.owncloud.org/download/repositories/${OWNCLOUD_VERSION}/prod/`lsb_release -is`_`lsb_release -rs`/ /" >> /etc/apt/sources.list.d/owncloud.list
#RUN curl -fsSL https://download.owncloud.org/download/repositories/${OWNCLOUD_VERSION}/prod/`lsb_release -is`_`lsb_release -rs`/Release.key | apt-key add -
RUN echo "deb https://download.owncloud.org/download/repositories/${OWNCLOUD_VERSION}/`lsb_release -is`_`lsb_release -rs`/ /" >> /etc/apt/sources.list.d/owncloud.list
RUN curl -fsSL https://download.owncloud.org/download/repositories/${OWNCLOUD_VERSION}/`lsb_release -is`_`lsb_release -rs`/Release.key | apt-key add -

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	curl bzip2 openssl file sqlite3 \
	libapache2-mod-xsendfile \
	php7.3-common php7.3-gd php7.3-json php7.3-mysql php7.3-curl php7.3-intl php7.3-imagick php7.3-xml \
	php7.3 php7.3-cli php7.3-readline php7.3-sqlite3 php7.3-mbstring php7.3-zip php7.3-bz2 \
	#php7.3-pgsql libapache2-mod-php7.3 php7.3-ldap php7.3-imap php-smbclient php-ssh2 php7.3-gmp \
	#php7.3-mysql mysql-client=${MYSQL_VERSION}.* mysql-common=${MYSQL_VERSION}.* \
	php7.3-apcu php7.3-memcached php7.3-redis \
	owncloud-files \
# we need sudo to upgrade DB between OwnCloud versions
	sudo \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
# allow LetsEncrypt.org
	#&& sed -i'.bak' -e 's@\(RewriteEngine on\)$@\1\n  RewriteCond expr "%{REQUEST_URI} !~ m#^\.well-known/acme-challenge/.+#"\n@' /var/www/owncloud/.htaccess \
	#&& sed -i'.bak' -e 's@\(RewriteEngine on\)$@\1\n  RewriteCond "%{REQUEST_URI}" !"^\.well-known/acme-challenge/.+"\n@' /var/www/owncloud/.htaccess \
	&& sed -i'.bak' -e 's@\(RewriteEngine on\)$@\1\n  RewriteRule "^\.well-known/acme-challenge/" - [L]@' /var/www/owncloud/.htaccess \
	&& for m in "remoteip rewrite headers env dir mime unique_id expires setenvif"; do a2enmod $m; done \
	&& a2dissite 000-default \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh \
# PHP configuration
	&& echo "\n\n\napc.enable_cli=1" >> /etc/php/7.3/cli/php.ini \
#	&& sed -i'.bak' \
#		-e 's%\(memory_limit\) = .*M%\1 = 256M%' \
#		-e 's%\(max_file_uploads\) = 20%\1 = 200%' \
#		  /etc/php/7.3/apache2/php.ini \
# statistics tool
	&& if test -f /usr/share/doc/php*-apcu/apc.php; then ln -s /usr/share/doc/php*-apcu/apc.php /var/www/owncloud/; fi

#RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#	&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
#	&& docker-php-ext-install exif gd intl ldap mbstring mcrypt mysql opcache pdo_mysql pdo_pgsql pgsql zip

# PECL extensions
#RUN pecl install APCu-beta redis memcached \
#	&& docker-php-ext-enable apcu redis memcached

RUN mkdir -p /opt/owncloud /srv/owncloud/data /srv/owncloud/backup \
	&& chown www-data /opt/owncloud /srv/owncloud/data

COPY --chown=www-data:www-data autoconfig.php /var/www/owncloud/config/autoconfig.php

# min[0-59] hour[0-23] dom[1-31] month[1-12] dow[0-7]  command
#RUN crontab -u www-data -l | { cat; echo "*/15  *  *  *  * php -f /var/www/owncloud/cron.php > /dev/null 2>&1"; } | crontab -u www-data -
# ownCloud < 10.3:
#RUN echo "53  *  *  *  * php -f /var/www/owncloud/cron.php > /dev/null 2>&1\n43  1  *  *  * ( cd /var/www/owncloud && php occ dav:cleanup-chunks ) > /dev/null 2>&1" | crontab -u www-data -
# ownCloud >= 10.3:
RUN echo "53  *  *  *  * ( cd /var/www/owncloud && php occ system:cron ) > /dev/null 2>&1\n43  1  *  *  * ( cd /var/www/owncloud && php occ dav:cleanup-chunks ) > /dev/null 2>&1" | crontab -u www-data -

#VOLUME /var/www/html
#VOLUME ["/var/log"]

EXPOSE 80 443

ENTRYPOINT ["/usr/local/sbin/docker-init.sh"]
