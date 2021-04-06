#FROM owncloud/server:${OWNCLOUD_VERSION}
#FROM php:7.4-apache
FROM cedrik/php7-apache

#ARG OWNCLOUD_VERSION=latest
ARG OWNCLOUD_VERSION=10.7.0

LABEL org.opencontainers.image.title="ownCloud" \
      org.opencontainers.image.version="${OWNCLOUD_VERSION}" \
      org.opencontainers.image.authors="Cédrik LIME"

# https://github.com/owncloud-docker/server
# https://doc.owncloud.org/server/10.6/admin_manual/installation/manual_installation/manual_installation_prerequisites.html
# https://doc.owncloud.org/server/10.6/admin_manual/installation/manual_installation/manual_installation_apache.html
# https://doc.owncloud.com/server/10.6/admin_manual/configuration/server/background_jobs_configuration.html
# https://doc.owncloud.com/server/10.6/admin_manual/configuration/server/caching_configuration.html
# https://doc.owncloud.com/server/10.6/admin_manual/configuration/server/oc_server_tuning.html

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	curl bzip2 openssl file sqlite3 \
	libapache2-mod-xsendfile \
# we need sudo to upgrade DB between ownCloud versions
	sudo \
  && a2enmod remoteip rewrite headers env dir mime unique_id expires setenvif \
	&& a2dissite 000-default \
	&& install-php-extensions ctype curl dom gd hash iconv intl json libxml mbstring openssl pdo pdo_mysql phar posix simplexml xmlwriter zip zlib bz2 fileinfo mcrypt openssl exif gmp apcu memcached redis pcntl \
#	&& install-php-extensions pdo_sqlite pdo_pgsql pgsql imagick ftp sftp imap ldap smbclient \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && docker-php-source delete

RUN curl -fsSL https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 | tar xj -C /var/www/ --owner=www-data --group=www-data \
	&& rm /var/www/owncloud/AUTHORS /var/www/owncloud/CHANGELOG.md /var/www/owncloud/COPYING /var/www/owncloud/README.md \
	&& mkdir -p /var/www/owncloud/apps-external /var/www/owncloud/data /opt/owncloud /srv/owncloud/data /srv/owncloud/backup \
	&& chown -R www-data: /var/www/owncloud/.htaccess /var/www/owncloud/.user.ini /var/www/owncloud/apps /var/www/owncloud/config /var/www/owncloud/updater /var/www/owncloud/apps-external /var/www/owncloud/data /opt/owncloud /srv/owncloud/data \
# statistics tool
	&& if test -f /usr/share/doc/php*-apcu/apc.php; then ln -s /usr/share/doc/php*-apcu/apc.php /var/www/owncloud/; fi

# min[0-59] hour[0-23] dom[1-31] month[1-12] dow[0-7]  command
#RUN busybox crontab -u www-data -l | { cat; echo "*/15  *  *  *  * php -f /var/www/owncloud/cron.php > /dev/null 2>&1"; } | busybox crontab -u www-data -
# ownCloud < 10.3:
#RUN echo "53  *  *  *  * php -f /var/www/owncloud/cron.php > /dev/null 2>&1\n43  1  *  *  * ( cd /var/www/owncloud && php occ dav:cleanup-chunks ) > /dev/null 2>&1" | busybox crontab -u www-data -
# ownCloud >= 10.3:
RUN echo "53  *  *  *  * ( cd /var/www/owncloud && php occ system:cron ) > /dev/null 2>&1\n43  1  *  *  * ( cd /var/www/owncloud && php occ dav:cleanup-chunks ) > /dev/null 2>&1" | busybox crontab -u www-data -

COPY --chown=www-data:www-data autoconfig.php /var/www/owncloud/config/autoconfig.php
COPY --chown=www-data:www-data owncloud.conf /etc/apache2/conf-enabled/
COPY logrotate-owncloud-dump /etc/logrotate.d/owncloud-dump
COPY ownCloudUpgrade.sh consul-healthcheck.sh  /usr/local/bin/
COPY owncloud.ini ${PHP_INI_DIR}/conf.d/
#COPY 60-init-upgrade  /usr/local/etc/init.d/

VOLUME /var/www/owncloud/config /var/www/owncloud/apps-external
#VOLUME ["/srv/owncloud", "/var/log"]
