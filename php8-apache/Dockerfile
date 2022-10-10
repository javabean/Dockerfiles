FROM php:8.0-apache
LABEL org.opencontainers.image.authors="Cédrik LIME"

############### FIXME  change depending on base OS / version! ###############
ARG MYSQL_VERSION=8.0
ARG NEWRELIC_PHP_AGENT_URL=https://download.newrelic.com/php_agent/release/newrelic-php5-10.2.0.314-linux.tar.gz
ARG NEWRELIC_LICENSE_KEY=


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
    echo "Header setifempty Permissions-Policy \"geolocation=(self 'https://example.com') gyroscope=(self 'https://example.com') magnetometer=(self 'https://example.com')\""; \
  } >> ${APACHE_CONFDIR}/conf-available/security.conf \
  && echo "SetEnvIf x-forwarded-proto https HTTPS=on" > ${APACHE_CONFDIR}/conf-available/reverse-proxy.conf \
  && a2enconf reverse-proxy \
  && sed -i'.bak' -e 's/\(SSLProtocol all -SSLv3\)$/\1 -TLSv1 -TLSv1.1/' ${APACHE_CONFDIR}/mods-available/ssl.conf \
\
# MySQL client
# https://dev.mysql.com/downloads/repo/apt/
# https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/#repo-qg-apt-repo-manual-setup
# http://dev.mysql.com/doc/refman/8.0/en/checking-gpg-signature.html
\
#RUN gpg --keyserver keys.gnupg.net --recv-keys 3A79BD29  &&  gpg --export -a 3A79BD29 | apt-key add -
  && savedAptMark="$(apt-mark showmanual)" \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
    lsb-release gnupg \
# If behind a restrictive firewall, use: apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --keyserver-options http-proxy="http://<username>:<password>@<proxy_server_addr>:<proxy_port>" --recv-keys 3A79BD29
  && apt-key adv --keyserver sks.pgpkeys.eu --recv-keys 3A79BD29 \
  && curl -fsL https://download.newrelic.com/548C16BF.gpg | apt-key add - \
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


# Newrelic
# https://docs.newrelic.com/docs/agents/php-agent/advanced-installation/docker-other-container-environments-install-php-agent/
# https://docs.newrelic.com/docs/agents/php-agent/advanced-installation/silent-mode-install-script-advanced/
RUN \
  #echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | sudo tee /etc/apt/sources.list.d/newrelic.list \
  #&& curl -fsL https://download.newrelic.com/548C16BF.gpg | apt-key add - \
  ##&& echo newrelic-php5 newrelic-php5/application-name string "My App Name" | debconf-set-selections \
  #&& echo newrelic-php5 newrelic-php5/license-key string "${NEWRELIC_LICENSE_KEY}" | debconf-set-selections \
  #&& apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends --no-install-suggests newrelic-php5 \
  #&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  curl -fsSL ${NEWRELIC_PHP_AGENT_URL} | tar -C /tmp -zx && \
  export NR_INSTALL_USE_CP_NOT_LN=1 && \
  export NR_INSTALL_SILENT=1 && \
  export NR_INSTALL_KEY=${NEWRELIC_LICENSE_KEY} && \
  /tmp/newrelic-php5-*/newrelic-install install && \
  rm -rf /tmp/newrelic-php5-* /tmp/nrinstall* && \
  # https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration/ \
  sed -i \
      -e "s/\"REPLACE_WITH_REAL_KEY\"/\"${NEWRELIC_LICENSE_KEY}\"/" \
      #-e 's/newrelic.appname = "PHP Application"/newrelic.appname = "YOUR_APPLICATION_NAME"/' \
      #-e 's/;newrelic.high_security =.*/newrelic.high_security=1/' \
      #-e 's/;newrelic.labels =.*/newrelic.labels="Server:One;Data Center:Primary"/' \
      #-e 's/;newrelic.distributed_tracing_enabled =.*/newrelic.distributed_tracing_enabled=1/' \
      #-e 's/;newrelic.browser_monitoring.auto_instrument =.*/newrelic.browser_monitoring.auto_instrument=false/' \
      -e 's/;newrelic.transaction_tracer.detail =.*/newrelic.transaction_tracer.detail=0/' \
      -e 's/;newrelic.transaction_tracer.max_segments_web =.*/newrelic.transaction_tracer.max_segments_web=100000/' \
      -e 's/;newrelic.transaction_tracer.max_segments_cli =.*/newrelic.transaction_tracer.max_segments_cli=100000/' \
      -e 's/;newrelic.distributed_tracing_exclude_newrelic_header =.*/newrelic.distributed_tracing_exclude_newrelic_header=true/' \
      #-e 's/;newrelic.enabled =.*/newrelic.enabled=false/' \
      -e 's/;newrelic.daemon.dont_launch =.*/newrelic.daemon.dont_launch=3/' \
      -e 's/;newrelic.daemon.address =.*/newrelic.daemon.address=newrelic-php-daemon:31339/' \
      -e 's/;newrelic.daemon.app_connect_timeout =.*/newrelic.daemon.app_connect_timeout=15s/' \
      -e 's/;newrelic.daemon.start_timeout =.*/newrelic.daemon.start_timeout=5s/' \
      -e 's/;newrelic.daemon.app_timeout =.*/newrelic.daemon.app_timeout=4h/' \
      -e 's%newrelic.logfile =.*%newrelic.logfile=/proc/self/fd/1%' \
    ${PHP_INI_DIR}/conf.d/newrelic.ini
# To build a docker image with New Relic, use:
#   echo "newrelic.logfile=/dev/null" > ${PHP_INI_DIR}/conf.d/zz_newrelic_tmp.ini \
#   install-php-extensions pdo pdo_mysql json xml intl mbstring fileinfo curl posix opcache  session dom pcntl zip openssl \
#   rm -f ${PHP_INI_DIR}/conf.d/zz_newrelic_tmp.ini \
# and set "newrelic.appname", either in newrelic.ini of via httpd: php_value newrelic.appname "PHP Application"


HEALTHCHECK --interval=5m --timeout=10s --start-period=5s --retries=2 \
	CMD ["/usr/local/bin/docker-healthcheck.sh"]
# Should you need to disable health checks in an inherited Dockerfile:
#HEALTHCHECK NONE

#VOLUME /var/www/html /var/lib/php/sessions
#VOLUME ["/var/log"]

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "docker-php-entrypoint"]
CMD ["apache2-foreground"]
