FROM buildpack-deps:stable-scm as build

RUN cd /usr/src \
  && git clone --depth=1 https://git.tt-rss.org/fox/tt-rss.git tt-rss \
  && cd tt-rss/plugins.local \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-api-resize.git api_resize_media \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-perceptual-image-hash.git af_img_phash \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-mailer-smtp.git mailer_smtp \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-nginx-xaccel.git nginx_xaccel \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-time-to-read.git time_to_read \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-data-migration.git data_migration \
#  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-video-fill-poster.git af_video_fill_poster \
#  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-hotkeys-ru.git hotkeys_ru \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-enclosure-fix-type af_enclosure_fix_type \
  && git clone --depth=1 https://github.com/joshp23/ttrss-to-wallabag-v2 wallabag_v2 \
  && git clone --depth=1 https://github.com/DigitalDJ/tinytinyrss-fever-plugin fever


#FROM php:7.3-apache
FROM cedrik/php7-base:latest
LABEL org.opencontainers.image.title="Tiny Tiny RSS" \
      org.opencontainers.image.authors="Cédrik LIME"

# https://tt-rss.org/wiki/InstallationNotes
# https://tt-rss.org/wiki/PhpCompatibilityNotes
# https://tt-rss.org/wiki/UpdatingFeeds
# https://git.tt-rss.org/fox/ttrss-docker-compose


RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	curl \
#	git \
	php7.3-cli php7.3-curl php7.3-mbstring \
	php7.3-json php7.3-intl php7.3-gd php7.3-xml php7.3-opcache \
	php7.3-common php7.3 \
	#php7.3-pgsql libapache2-mod-php7.3 \
	#php7.3-mysql mysql-client=${MYSQL_VERSION}.* mysql-common=${MYSQL_VERSION}.* \
	php7.3-apcu \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& for m in "remoteip headers env dir mime expires setenvif"; do a2enmod $m; done \
	&& a2dissite 000-default \
	&& rm -f /var/www/html/index.html \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh \
# PHP configuration
	&& echo "\n\n\napc.enable_cli=1" >> /etc/php/7.3/cli/php.ini \
#	&& sed -i'.bak' \
#		-e 's%\(memory_limit\) = .*M%\1 = 256M%' \
#		-e 's%\(max_file_uploads\) = 20%\1 = 200%' \
#		  /etc/php/7.3/apache2/php.ini \
# statistics tool
	&& if test -f /usr/share/doc/php*-apcu/apc.php; then ln -s /usr/share/doc/php*-apcu/apc.php /var/www/html/; fi

#RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#	&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
#	&& docker-php-ext-install exif gd intl ldap mbstring mcrypt mysql opcache pdo_mysql pdo_pgsql pgsql zip

# PECL extensions
#RUN pecl install APCu-beta redis memcached \
#	&& docker-php-ext-enable apcu redis memcached

# min[0-59] hour[0-23] dom[1-31] month[1-12] dow[0-7]  command
RUN echo "*/30  *  *  *  *  php /var/www/html/update.php --feeds --quiet > /dev/null 2>&1" | crontab -u www-data -

COPY tt-rss.conf /etc/apache2/conf-enabled/
COPY backup_conf_local.sh restore_conf_local.sh  /usr/local/bin/

COPY --from=build --chown=www-data:www-data /usr/src/tt-rss /usr/src/tt-rss

#VOLUME ["/var/www/html"]
#VOLUME ["/var/log"]

EXPOSE 80

ENTRYPOINT ["/usr/local/sbin/docker-init.sh"]
