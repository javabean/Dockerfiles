FROM php:7.4-apache
LABEL org.opencontainers.image.authors="Cédrik LIME"

############### FIXME  change depending on base OS / version! ###############
ARG MYSQL_VERSION=8.0


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
# && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
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
  && sed -i'.bak' -e 's/\(SSLProtocol all -SSLv3\)$/\1 -TLSv1 -TLSv1.1/' ${APACHE_CONFDIR}/mods-available/ssl.conf \
\
# MySQL client
# https://dev.mysql.com/downloads/repo/apt/
# https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/#repo-qg-apt-repo-manual-setup
# http://dev.mysql.com/doc/refman/5.7/en/checking-gpg-signature.html
\
#RUN gpg --keyserver keys.gnupg.net --recv-keys 5072E1F5  &&  gpg --export -a 5072E1F5 | apt-key add -
  && savedAptMark="$(apt-mark showmanual)" \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
    lsb-release gnupg \
# If behind a restrictive firewall, use: apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --keyserver-options http-proxy="http://<username>:<password>@<proxy_server_addr>:<proxy_port>" --recv-keys 5072E1F5
  && apt-key adv --keyserver ipv4.pool.sks-keyservers.net --recv-keys 5072E1F5 \
  && echo "deb https://repo.mysql.com/apt/debian/ `lsb_release -cs` mysql-${MYSQL_VERSION}" > /etc/apt/sources.list.d/mysql.list \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
  && apt-mark auto '.*' > /dev/null && apt-mark manual $savedAptMark > /dev/null \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false  lsb-release gnupg \
  && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests mysql-client \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# PHP configuration

#COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions \
  && if ! test -f /usr/src/apc.php; then curl -fsSL http://pecl.php.net/get/APCu | tar xz -C /usr/src/ --strip-components=1 --wildcards apcu*/apc.php; fi \
  && cp -a ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini \
  && mkdir -p --mode=1733 /var/lib/php/sessions \
  && echo 'session.save_path = "/var/lib/php/sessions"' > ${PHP_INI_DIR}/conf.d/session.ini \
\
# Possible values for ext-name:
# bcmath bz2 calendar dba enchant exif ffi gd gettext gmp imap intl ldap mysqli oci8 odbc opcache pcntl pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pgsql pspell shmop snmp soap sockets sysvmsg sysvsem sysvshm tidy xmlrpc xsl zend_test zip
# Already installed in 7.4 Docker image:
# ctype curl dom fileinfo filter ftp hash iconv json mbstring pdo pdo_sqlite phar posix readline reflection session simplexml sodium spl standard tokenizer xml xmlreader xmlwriter
\
#	&& docker-php-ext-configure gd --with-webp --with-jpeg --with-xpm \
#	&& docker-php-ext-install -j$(nproc) calendar intl mysqli pdo_mysql gd soap zip curl ldap \
# igbinary & msgpack are dependencies of memcached
# exif is a dependency of gd
  && install-php-extensions bz2 calendar exif gd gettext intl mysqli opcache pcntl pdo_mysql soap xmlrpc zip apcu igbinary msgpack memcached redis \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && docker-php-source delete


HEALTHCHECK --interval=5m --timeout=10s --start-period=5s --retries=2 \
	CMD ["/usr/local/bin/docker-healthcheck.sh"]
# Should you need to disable health checks in an inherited Dockerfile:
#HEALTHCHECK NONE

#VOLUME /var/www/html /var/lib/php/sessions
#VOLUME ["/var/log"]

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "docker-php-entrypoint"]
CMD ["apache2-foreground"]
