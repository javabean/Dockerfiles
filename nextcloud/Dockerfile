ARG DOCKER_FROM_TAG=production-apache
#ARG DOCKER_FROM_TAG=stable-apache
FROM nextcloud:${DOCKER_FROM_TAG}
ARG DOCKER_FROM_TAG=production-apache
LABEL org.opencontainers.image.title="Nextcloud" \
      org.opencontainers.image.version="${DOCKER_FROM_TAG}" \
      org.opencontainers.image.authors="Cédrik LIME"

# https://github.com/nextcloud/docker
# https://github.com/nextcloud/docker/tree/master/.examples
# https://docs.nextcloud.com/server/23/admin_manual/installation/source_installation.html#prerequisites-label


ARG NEWRELIC_PHP_AGENT_URL=https://download.newrelic.com/php_agent/release/newrelic-php5-9.21.0.311-linux.tar.gz
ARG NEWRELIC_LICENSE_KEY=
ARG NEWRELIC_APPLICATION_NAME=Nextcloud


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


# Nextcloud

COPY nextcloud.conf ${APACHE_CONFDIR}/conf-enabled/
COPY logrotate-nextcloud-dump /etc/logrotate.d/nextcloud-dump
COPY --chown=www-data:www-data config/* /usr/src/nextcloud/config/

# Install PHP bz2 module
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests libbz2-dev \
#  && echo "newrelic.logfile=/dev/null" > ${PHP_INI_DIR}/conf.d/zz_newrelic_tmp.ini \
#  && docker-php-ext-install bz2 \
#  && rm -f ${PHP_INI_DIR}/conf.d/zz_newrelic_tmp.ini \
#  && apt-get purge -y libbz2-dev \
#  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fix "Module php-imagick in this instance has no SVG support. For better compatibility it is recommended to install it."
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests libmagickcore-6.q16-6-extra \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# rm -f /usr/src/nextcloud/AUTHORS /usr/src/nextcloud/COPYING \
# min[0-59] hour[0-23] dom[1-31] month[1-12] dow[0-7]  command
RUN echo " 0  *  *  *  *    php -f /var/www/html/occ activity:send-mails hourly > /dev/null 2>&1"  >> /var/spool/cron/crontabs/www-data \
  && echo "30  7  *  *  *    php -f /var/www/html/occ activity:send-mails daily"  >> /var/spool/cron/crontabs/www-data \
  && echo "30  7  *  *  MON  php -f /var/www/html/occ activity:send-mails weekly"  >> /var/spool/cron/crontabs/www-data \
  && echo "03  0  *  *  *    /usr/local/bin/nextcloud-sqlite-dump.sh"  >> /var/spool/cron/crontabs/www-data \
# using Redis session handler, not a FS-based one
# Nextcloud Docker image comes with its own "opcache-recommended.ini"
  && rm ${PHP_INI_DIR}/conf.d/session.ini ${PHP_INI_DIR}/conf.d/opcache.ini \
  && echo 'source <(/var/www/html/occ _completion --generate-hook --program occ)' | tee -a ~www-data/.bash_profile ~www-data/.zshrc > /dev/null 2>&1 \
  && a2enmod proxy proxy_http proxy_wstunnel \
  && a2disconf remoteip \
  && a2dissite 000-default \
  # upgrade is based on existence of file version.php; it is backed up in config/
  && ln -s config/version.php /var/www/html/ \
  # we don't persist Nextcloud core files: enable starting from a new (empty) container
  # note this will force an upgrade on each container startup :-(
  && sed -i --follow-symlinks 's%if version_greater "$image_version" "$installed_version"; then%if version_greater "$image_version" "$installed_version" || [ "$image_version" = "$installed_version" ]; then%' /entrypoint.sh \
# PHP statistics tool
#  && if ! test -f /usr/src/nextcloud/apc.php; then cp -a /usr/src/apc.php /usr/src/nextcloud/; fi \
  && sed -i \
       -e "s/newrelic.appname = \"PHP Application\"/newrelic.appname = \"${NEWRELIC_APPLICATION_NAME}\"/" \
       ${PHP_INI_DIR}/conf.d/newrelic.ini \
  && sed -i \
       -e "s/_NEWRELIC_APPLICATION_NAME_/${NEWRELIC_APPLICATION_NAME}/" \
       ${APACHE_CONFDIR}/conf-enabled/nextcloud.conf \
  # required for startup script which calls php and parses output
  && sed -i \
      -e 's%newrelic.logfile =.*%newrelic.logfile=/dev/null%' \
      -e 's%newrelic.logfile=.*%newrelic.logfile=/dev/null%' \
    ${PHP_INI_DIR}/conf.d/newrelic.ini

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 \
  CMD ["/usr/local/bin/docker-healthcheck.sh"]

#ENV NEXTCLOUD_UPDATE=1
#ENV APACHE_DISABLE_REWRITE_IP=1

#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["apache2-foreground"]

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/entrypoint.sh"]
CMD ["apache2-pre-foreground.sh"]
