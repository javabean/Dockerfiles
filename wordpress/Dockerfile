#FROM wordpress:latest
#FROM php:5.6-apache
FROM cedrik/php5-base:latest
MAINTAINER Cédrik LIME

# https://hub.docker.com/_/wordpress/
# https://codex.wordpress.org/Editing_wp-config.php
# https://codex.wordpress.org/Administration_Over_SSL
# http://codex.wordpress.org/Hardening_WordPress

############### FIXME  change version here! ###############
#ARG WORDPRESS_VERSION=wordpress-4.5.2
ARG WORDPRESS_VERSION=latest

COPY wordpress.conf /etc/apache2/conf-enabled/
COPY backup_conf_local.sh restore_conf_local.sh  /usr/local/bin/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	mysql-client \
	libpng12-0 libjpeg62 libjpeg-turbo8 php5.6-gd php5.6-mysql \
	php5.6-curl libxml2 php5.6-mcrypt openssl php5.6-soap \
	php5.6-json php5.6-intl \
	php5.6-memcache php5.6-memcached \
	php5.6-apcu \
	sudo \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& for m in "rewrite expires headers mime"; do a2enmod $m; done \
	# PHP configuration
	&& sed -i'.bak' \
		-e 's%\(memory_limit\) = .*M%\1 = 64M%' \
		-e 's%\(upload_max_filesize\) = .*M%\1 = 8M%' \
		/etc/php/5.6/apache2/php.ini

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
#RUN { \
#		echo 'opcache.memory_consumption=128'; \
#		echo 'opcache.interned_strings_buffer=8'; \
#		echo 'opcache.max_accelerated_files=4000'; \
#		echo 'opcache.revalidate_freq=60'; \
#		echo 'opcache.fast_shutdown=1'; \
#		echo 'opcache.enable_cli=1'; \
#	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

#RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#	&& docker-php-ext-install gd mysqli opcache

RUN curl -fsSL https://wordpress.org/${WORDPRESS_VERSION}.tar.gz | tar xz -C /var/www/html/ --strip-components=1 \
	&& mv /var/www/html/index.html /var/www/html/index.html.bak \
	&& chown www-data:www-data -R /var/www/html/ \
# https://wp-cli.org/docs/installing/
	&& curl -fsSLR -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /usr/local/bin/wp \
	&& curl -fsSLR -o /etc/bash_completion.d/wp-completion.bash https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash \
# statistics tool
	&& if test -f /usr/share/php5/apcu/apc.php; then ln -s /usr/share/php5/apcu/apc.php "/var/www/html/wp-admin/"; fi \
	&& if test -f /usr/share/doc/php-apcu/apc.php; then ln -s /usr/share/doc/php-apcu/apc.php "/var/www/html/wp-admin/"; fi \
	&& rm -rf /tmp/* \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh

#VOLUME /var/www/html
#VOLUME ["/var/log"]
#VOLUME ["/var/www/html/wp-content", "/var/www/wp-includes/languages"]

EXPOSE 80 443

#ADD https://raw.githubusercontent.com/docker-library/wordpress/master/apache/docker-entrypoint.sh  /usr/local/bin/
#ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

#ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/local/bin/docker-entrypoint.sh"]
ENTRYPOINT ["/usr/local/bin/tini", "-g", "--", "/usr/local/bin/docker-entrypoint.sh"]
#ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/apache2ctl"]
