ARG DOCKER_FROM_TAG=6.1.1-apache
FROM wordpress:${DOCKER_FROM_TAG}
ARG DOCKER_FROM_TAG=6.1.1-apache
LABEL org.opencontainers.image.title="WordPress" \
      org.opencontainers.image.version="${DOCKER_FROM_TAG}" \
      org.opencontainers.image.authors="Cédrik LIME"

# https://hub.docker.com/_/wordpress/
# https://wordpress.org/support/article/editing-wp-config-php/
# https://wordpress.org/support/article/administration-over-ssl/
# https://wordpress.org/support/article/hardening-wordpress/


ARG NEWRELIC_PHP_AGENT_URL=https://download.newrelic.com/php_agent/release/newrelic-php5-10.11.0.3-linux.tar.gz
ARG NEWRELIC_LICENSE_KEY=
ARG NEWRELIC_APPLICATION_NAME=Wordpress


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
    echo "Header setifempty Permissions-Policy \"geolocation=(self 'https://example.com') gyroscope=(self 'https://example.com') magnetometer=(self 'https://example.com')\""; \
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


# WordPress

COPY wordpress.conf ${APACHE_CONFDIR}/conf-enabled/

# https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions
# igbinary & msgpack are dependencies of memcached
# exif is a dependency of gd
RUN echo "newrelic.logfile=/dev/null" > ${PHP_INI_DIR}/conf.d/zz_newrelic_tmp.ini \
  && install-php-extensions json mysqli \
    curl dom exif fileinfo hash imagick mbstring openssl pcre xml zip \
    bcmath filter gd iconv intl mcrypt simplexml sodium xmlreader zlib \
    opcache pcntl \
  && rm -f ${PHP_INI_DIR}/conf.d/zz_newrelic_tmp.ini \
# bash is needed for 'wp shell'
# less is needed for 'wp help'
  && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests bash less imagemagick ghostscript \
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
  && if test -d /etc/bash_completion.d; then curl -fsSLR -o /etc/bash_completion.d/wp-completion.bash https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash; fi \
\
  && sed -i \
       -e "s/newrelic.appname = \"PHP Application\"/newrelic.appname = \"${NEWRELIC_APPLICATION_NAME}\"/" \
       ${PHP_INI_DIR}/conf.d/newrelic.ini \
  && sed -i \
       -e "s/_NEWRELIC_APPLICATION_NAME_/${NEWRELIC_APPLICATION_NAME}/" \
       ${APACHE_CONFDIR}/conf-enabled/wordpress.conf

# https://wordpress.org/support/article/hardening-wordpress/#file-permissions
# https://wordpress.org/support/article/updating-wordpress/#file-ownership
#  && chown -R root:www-data /usr/src/wordpress/*.php /usr/src/wordpress/wp-admin /usr/src/wordpress/wp-includes \
#  && chown -R www-data:www-data -R /usr/src/wordpress/.htaccess /usr/src/wordpress/wp-content \

HEALTHCHECK --interval=5m --timeout=10s --start-period=5s --retries=2 \
	CMD ["/usr/local/bin/docker-healthcheck.sh"]

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "docker-entrypoint.sh"]
CMD ["apache2-foreground"]
