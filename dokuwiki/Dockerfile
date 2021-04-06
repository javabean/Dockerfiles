#FROM php:7.4-apache
FROM cedrik/php7-apache:latest

############### FIXME  change version here! ###############
#ARG DOKUWIKI_VERSION=2020-07-29
ARG DOKUWIKI_VERSION=stable
# Languages to keep (delete all others)
ARG STRIP_LANGS_KEEP=

LABEL org.opencontainers.image.title="Dokuwiki" \
      org.opencontainers.image.version="${DOKUWIKI_VERSION}" \
      org.opencontainers.image.authors="Cédrik LIME"

# https://www.dokuwiki.org/


COPY dokuwiki.conf /etc/apache2/conf-enabled/
COPY bin/* /usr/local/bin/
COPY init.d/* /usr/local/etc/init.d/

RUN a2enmod rewrite \
  && install-php-extensions gd openssl xml \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && docker-php-source delete \
  && { \
       echo '; https://www.dokuwiki.org/install:php'; \
       echo ''; \
       echo 'short_open_tag = Off'; \
       echo 'output_buffering = Off'; \
       echo 'output_handler ='; \
       echo 'zlib.output_compression = Off'; \
       echo 'implicit_flush = Off'; \
       echo 'allow_call_time_pass_reference = Off'; \
       echo 'max_execution_time = 30'; \
       echo 'max_input_time = 60'; \
       echo 'max_input_vars = 10000'; \
       echo 'memory_limit = 32M'; \
       echo 'error_reporting = E_ALL & ~E_NOTICE'; \
       echo 'display_errors = Off'; \
       echo 'display_startup_errors = Off'; \
       echo 'log_errors = On'; \
       echo 'error_log = /dev/stdout'; \
       echo 'variables_order = “EGPCS”'; \
       echo 'register_argc_argv = Off'; \
       echo 'magic_quotes_gpc = Off'; \
       echo 'magic_quotes_runtime = Off'; \
       echo 'magic_quotes_sybase = Off'; \
       echo 'file_uploads = On'; \
       echo 'upload_max_filesize = 16M'; \
       echo 'upload_max_filesize = 32M'; \
       echo 'session.use_cookies = 1'; \
       echo 'session.use_only_cookies = 1'; \
       echo 'session.cache_limiter = private_no_expire'; \
    } > ${PHP_INI_DIR}/conf.d/dokuwiki.ini

RUN curl -fsSL https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}.tgz | tar xz -C /var/www/html/ --strip-components=1 \
	&& cp -a /var/www/html/.htaccess.dist /var/www/html/.htaccess \
	&& chmod +x /var/www/html/bin/*.php \
	&& find /var/www/html -name '_dummy' -delete \
	&& rm /var/www/html/README /var/www/html/COPYING \
	&& if [ -n "${STRIP_LANGS_KEEP}" ]; then /var/www/html/bin/striplangs.php -k "${STRIP_LANGS_KEEP}" ; fi \
	&& chown www-data:www-data -R /var/www/html/data /var/www/html/lib/plugins /var/www/html/lib/tpl /var/www/html/conf \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf_local.sh

#COPY --chown=www-data:www-data preload.php /var/www/html/inc/preload.php

# min[0-59] hour[0-23] dom[1-31] month[1-12] dow[0-7]  command
#RUN busybox crontab -u www-data -l | { cat; echo "7  0  *  *  * /usr/local/bin/cleanup.sh > /dev/null 2>&1"; } | busybox crontab -u www-data -
RUN echo "7  0  *  *  * /usr/local/bin/cleanup.sh > /dev/null 2>&1" | busybox crontab -u www-data -

#VOLUME ["/var/log"]
#VOLUME ["/var/www/html/data", "/var/www/html/conf", "/var/www/html/lib/plugins", "/var/www/html/lib/tpl"]
