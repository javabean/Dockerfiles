#FROM php:7.0-apache
FROM cedrik/php7-base:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

# https://www.dokuwiki.org/

############### FIXME  change version here! ###############
#ARG DOKUWIKI_VERSION=2017-02-19a
ARG DOKUWIKI_VERSION=stable
# Languages to keep (delete all others)
ARG STRIP_LANGS_KEEP=


COPY dokuwiki.conf /etc/apache2/conf-enabled/
COPY backup_conf_local.sh restore_conf_local.sh upgrade-dokuwiki.sh cleanup.sh  /usr/local/bin/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	libapache2-mod-xsendfile \
	php7.0-zip php7.0-bz2 \
	libpng12-0 libjpeg62 libjpeg-turbo8 php7.0-gd \
	php7.0-curl libxml2 php7.0-xml php7.0-mcrypt openssl php7.0-soap \
	php7.0-json php7.0-intl \
# we need sudo to upgrade DokuWiki via CLI
	sudo \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& for m in "rewrite"; do a2enmod $m; done \
	# PHP configuration: https://www.dokuwiki.org/install:php
	&& sed -i'.bak' \
		-e 's%\(register_globals\) = .*%\1 = Off%' \
		-e 's%\(zlib.output_compression\) = .*%\1 = Off%' \
		-e 's%\(implicit_flush\) = .*%\1 = Off%' \
		-e 's%\(allow_call_time_pass_reference\) = .*%\1 = Off%' \
		-e 's%\(max_execution_time\) = .*%\1 = 30%' \
		-e 's%\(max_input_time\) = .*%\1 = 60%' \
		-e 's%; \(max_input_vars\) = .*%\1 = 10000%' \
		-e 's%\(memory_limit\) = .*M%\1 = 32M%' \
		-e 's%\(error_reporting\) = .*%\1 = E_ALL \& ~E_NOTICE%' \
		-e 's%\(display_errors\) = .*%\1 = Off%' \
		-e 's%\(display_startup_errors\) = .*%\1 = Off%' \
#		-e 's%\(log_errors\) = .*%\1 = On%' \
		-e 's%\(variables_order\) = .*%\1 = "EGPCS"%' \
		-e 's%\(register_argc_argv\) = .*%\1 = Off%' \
		-e 's%\(magic_quotes_gpc\) = .*%\1 = Off%' \
		-e 's%\(magic_quotes_runtime\) = .*%\1 = Off%' \
		-e 's%\(magic_quotes_sybase\) = .*%\1 = Off%' \
		-e 's%\(file_uploads\) = .*%\1 = On%' \
		-e 's%\(upload_max_filesize\) = .*M%\1 = 15M%' \
		-e 's%\(post_max_size\) = .*M%\1 = 15M%' \
		-e 's%\(session.use_cookies\) = .*%\1 = 1%' \
#		-e 's%\(session.cache_limiter\) = .*%\1 = nocache%' \
		/etc/php/7.0/apache2/php.ini

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
#	&& docker-php-ext-install gd

RUN curl -fsSL https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}.tgz | tar xz -C /var/www/html/ --strip-components=1 \
	&& mv /var/www/html/index.html /var/www/html/index.html.bak \
	&& cp -a /var/www/html/.htaccess.dist /var/www/html/.htaccess \
	&& chown www-data:www-data -R /var/www/html/ \
	&& chmod +x /var/www/html/bin/*.php \
	&& find /var/www/html -name '_dummy' -delete \
	&& rm /var/www/html/README /var/www/html/COPYING \
	&& if [ -n "$STRIP_LANGS_KEEP" ]; then /var/www/html/bin/striplangs.php -k "${STRIP_LANGS_KEEP}" ; fi \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh

#COPY --chown=www-data:www-data preload.php /var/www/html/inc/preload.php

# min[0-59] hour[0-23] dom[1-31] month[1-12] dow[0-7]  command
#RUN crontab -u www-data -l | { cat; echo "7  0  *  *  * /usr/local/bin/cleanup.sh > /dev/null 2>&1"; } | crontab -u www-data -
RUN echo "7  0  *  *  * /usr/local/bin/cleanup.sh > /dev/null 2>&1" | crontab -u www-data -

#VOLUME ["/var/log"]
#VOLUME ["/var/www/html/data", "/var/www/html/conf", "/var/www/html/lib/plugins", "/var/www/html/lib/tpl"]

EXPOSE 80 443

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/bin/apache2-foreground"]
