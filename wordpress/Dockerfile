ARG DOCKER_FROM_TAG=5.6.2-php7.4-apache
FROM wordpress:${DOCKER_FROM_TAG}
ARG DOCKER_FROM_TAG=5.6.2-php7.4-apache
LABEL org.opencontainers.image.title="WordPress" \
      org.opencontainers.image.version="${DOCKER_FROM_TAG}" \
      org.opencontainers.image.authors="Cédrik LIME"

# https://hub.docker.com/_/wordpress/
# https://wordpress.org/support/article/editing-wp-config-php/
# https://wordpress.org/support/article/administration-over-ssl/
# https://wordpress.org/support/article/hardening-wordpress/


# OS, Apache httpd & MySQL configuration

COPY bin/* /usr/local/bin/
COPY sbin/* /usr/local/sbin/
COPY init.d/* /usr/local/etc/init.d/
COPY php.ini.d/* ${PHP_INI_DIR}/conf.d/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
  apt-utils \
  busybox-static curl zip unzip \
  libapache2-mod-rpaf libapache2-mod-encoding libapache2-mod-xsendfile \
# libapache2-mod-bw libapache2-mod-log-slow libapache2-mod-security2 \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && mkdir -p /var/spool/cron/crontabs \
  && a2enmod unique_id expires rewrite headers env setenvif dir mime info reqtimeout remoteip slotmem_shm socache_shmcb \
# && a2dismod \
# && a2enconf \
  && a2disconf serve-cgi-bin \
# && a2ensite \
  && a2dissite default-ssl \
  && sed -i'.bak' -e 's/^\(ServerTokens OS\)$/#\1\nServerTokens Prod/' \
    -e 's/^#\(ServerSignature Off\)/\1/' \
    -e 's/^\(ServerSignature On\)/#\1/' \
    ${APACHE_CONFDIR}/conf-available/security.conf \
  && { \
    echo "\n\n\n"; \
    echo "# https://httpoxy.org"; \
    echo "RequestHeader unset Proxy early"; \
    echo ""; \
    echo "# https://developer.chrome.com/blog/floc/#how-can-websites-opt-out-of-the-floc-computation"; \
    echo "Header setifempty Permissions-Policy \"interest-cohort=() geolocation=(self 'https://example.com')\""; \
  } >> ${APACHE_CONFDIR}/conf-available/security.conf \
  && echo "SetEnvIf x-forwarded-proto https HTTPS=on" > ${APACHE_CONFDIR}/conf-available/reverse-proxy.conf \
  && a2enconf reverse-proxy \
  && sed -i'.bak' -e 's/\(SSLProtocol all -SSLv3\)$/\1 -TLSv1 -TLSv1.1/' ${APACHE_CONFDIR}/mods-available/ssl.conf


# PHP configuration

#COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions \
  && if ! test -f /usr/src/apc.php; then curl -fsSL http://pecl.php.net/get/APCu | tar xz -C /usr/src/ --strip-components=1 --wildcards apcu*/apc.php; fi \
  && cp -a ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini \
  && mkdir -p --mode=1733 /var/lib/php/sessions \
  && echo 'session.save_path = "/var/lib/php/sessions"' > ${PHP_INI_DIR}/conf.d/session.ini


# WordPress

# https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions
# igbinary & msgpack are dependencies of memcached
# exif is a dependency of gd
RUN install-php-extensions curl dom exif fileinfo hash json mbstring mysqli sodium openssl pcre imagick xml zip \
    filter gd iconv mcrypt simplexml xmlreader zlib \
    opcache pcntl \
# bash is needed for 'wp shell'
  && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests bash imagemagick ghostscript \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && docker-php-source delete \
  && rm -f ${PHP_INI_DIR}/conf.d/opcache-recommended.ini \
\
  && a2enmod rewrite expires headers env dir mime \
  && a2dismod -f deflate \
  && a2dissite 000-default \
\
  && rm -f /usr/src/wordpress/index.html /usr/src/wordpress/readme.html /usr/src/wordpress/license.txt \
  && mkdir -p /usr/src/wordpress/wp-content/uploads \
  && { \
    echo "# Kill PHP execution"; \
    echo "<Files *.php>"; \
    echo "	Require all denied"; \
    echo "</Files>"; \
  } >> /usr/src/wordpress/wp-content/uploads/.htaccess \
  && chown -R www-data:www-data /usr/src/wordpress/wp-content/uploads \
\
# https://make.wordpress.org/cli/handbook/installing/
  && curl -fsSLR -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x /usr/local/bin/wp \
  && if test -d /etc/bash_completion.d; then curl -fsSLR -o /etc/bash_completion.d/wp-completion.bash https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash; fi

# https://wordpress.org/support/article/hardening-wordpress/#file-permissions
# https://wordpress.org/support/article/updating-wordpress/#file-ownership
#  && chown -R root:www-data /usr/src/wordpress/*.php /usr/src/wordpress/wp-admin /usr/src/wordpress/wp-includes \
#  && chown -R www-data:www-data -R /usr/src/wordpress/.htaccess /usr/src/wordpress/wp-content \

COPY wordpress.conf /etc/apache2/conf-enabled/

HEALTHCHECK --interval=5m --timeout=10s --start-period=5s --retries=2 \
	CMD ["/usr/local/bin/docker-healthcheck.sh"]

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "docker-entrypoint.sh"]
CMD ["apache2-foreground"]
