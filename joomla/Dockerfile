#FROM joomla:3.6-apache
#FROM php:7.0-apache
FROM cedrik/php7-base:latest
MAINTAINER Cédrik LIME

# https://hub.docker.com/_/joomla/
# https://docs.joomla.org/J3.x:Installing_Joomla
# https://docs.joomla.org/Security_Checklist
# https://docs.joomla.org/Security_and_Performance_FAQs
# https://docs.joomla.org/Cache

############### FIXME  change version here! ###############
ARG JOOMLA_VERSION=3.6.0

COPY joomla.conf /etc/apache2/conf-enabled/
COPY backup_conf_local.sh restore_conf_local.sh  /usr/local/bin/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	libpng12-0 libjpeg62 libjpeg-turbo8 zip unzip php7.0-gd php7.0-mysql \
	#php7.0-mysql mysql-client=${MYSQL_VERSION}.* mysql-common=${MYSQL_VERSION}.* \
	php7.0-apcu \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& for m in "rewrite"; do a2enmod $m; done \
	# PHP configuration
	&& sed -i'.bak' \
		-e 's%\(memory_limit\) = .*M%\1 = 64M%' \
		-e 's%\(upload_max_filesize\) = .*M%\1 = 8M%' \
		-e 's%\(output_buffering\) = .*%\1 = Off%' \
		/etc/php/7.0/apache2/php.ini

# Install PHP extensions
#RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#	&& docker-php-ext-install gd
#RUN docker-php-ext-install mysqli

#VOLUME /var/www/html

# Download package and extract to web volume
RUN curl -fsSL https://github.com/joomla/joomla-cms/releases/download/${JOOMLA_VERSION}/Joomla_${JOOMLA_VERSION}-Stable-Full_Package.tar.bz2 | tar xj -C /var/www/html/ \
	# NOTE: The "Indexes" option is disabled in the php:apache base image so remove it as we enable .htaccess
	&& if [ ! -e /var/www/html/.htaccess ]; then sed -r 's/^(Options -Indexes.*)$/#\1/' /var/www/html/htaccess.txt > /var/www/html/.htaccess ; fi \
	&& if [ ! -e /var/www/html/robots.txt ]; then mv /var/www/html/robots.txt.dist /var/www/html/robots.txt ; fi \
	&& mv /var/www/html/index.html /var/www/html/index.html.bak \
# statistics tool
	&& if test -f /usr/share/php5/apcu/apc.php; then ln -s /usr/share/php5/apcu/apc.php "/var/www/html/administrator/"; fi \
	&& if test -f /usr/share/doc/php-apcu/apc.php; then ln -s /usr/share/doc/php-apcu/apc.php "/var/www/html/administrator/"; fi \
	&& chown -R www-data:www-data /var/www/html/ \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh

# min[0-59] hour[0-23] dom[1-31] month[1-12] dow[0-7]  command
#RUN echo "53  *  *  *  * php -f /var/www/cli/garbagecron.php > /dev/null 2>&1" | crontab -u www-data -
RUN crontab -u www-data -l | { cat; \
	# garbagecron.php: Purge expired cache files - https://docs.joomla.org/Purging_expired_cache_files
	echo "14  */12  *  *  * php -f /var/www/cli/garbagecron.php > /dev/null 2>&1"; \
	# update_cron.php: Check for extension updates
	echo "3  23  */10  *  * php -f /var/www/cli/update_cron.php > /dev/null 2>&1"; \
	# deletefiles.php: Delete old files after an update
	# php [-d memory_limit=256M] finder_indexer.php [--purge]: Manage Smart Search indexing - https://docs.joomla.org/Setting_up_automatic_Smart_Search_indexing
	} | crontab -u www-data -

# Copy init scripts and custom .htaccess
#ADD https://raw.githubusercontent.com/joomla/docker-joomla/master/apache/docker-entrypoint.sh  /entrypoint.sh
#ADD https://raw.githubusercontent.com/joomla/docker-joomla/master/apache/makedb.php  /makedb.php

#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["apache2-foreground"]

ENTRYPOINT ["/usr/local/sbin/docker-init.sh"]
