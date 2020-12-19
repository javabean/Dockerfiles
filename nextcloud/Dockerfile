ARG DOCKER_FROM_TAG=production-apache
#ARG DOCKER_FROM_TAG=stable-apache
FROM nextcloud:${DOCKER_FROM_TAG}
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

# https://github.com/nextcloud/docker
# https://docs.nextcloud.com/server/17/admin_manual/installation/source_installation.html#prerequisites-label


# Install PHP bz2 module
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests apt-utils \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libbz2-dev \
	&& docker-php-ext-install bz2 \
	&& apt-get purge -y libbz2-dev \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Apache httpd
RUN for m in "rewrite headers env dir mime expires setenvif remoteip reqtimeout info" ; do a2enmod $m; done \
	# php-fpm: a2enmod proxy_fcgi setenvif && a2enconf php7.3-fpm
	&& for m in "deflate" ; do a2dismod -f $m; done \
	&& a2disconf serve-cgi-bin \
	&& a2dissite 000-default default-ssl \
	&& sed -i'.bak' -e 's/^\(ServerTokens \)$/#\1\nServerTokens Prod/' \
		-e 's/^#\(ServerSignature Off\)/\1/' \
		-e 's/^\(ServerSignature On\)/#\1/' \
		-e 's/^#Header set \(X-Content-Type-Options:? "nosniff"\)/Header setifempty \1/' \
		# X-Frame-Options and X-XSS-Protection have been superseded by Content Security Policy (CSP)
		# X-Frame-Options and X-XSS-Protection are set by Nextcloud's .htaccess
		-e 's/^\(#Header set X-Frame-Options.*\)$/\1\nHeader setifempty Content-Security-Policy "frame-ancestors '\''self'\'' example.com *.example.net ; object-src '\''self'\'' ; connect-src '\''self'\'' * ;"/' \
		/etc/apache2/conf-available/security.conf \
	&& echo "\n\n\n# https://httpoxy.org\nRequestHeader unset Proxy early\n" >> /etc/apache2/conf-available/security.conf \
#	&& sed -i'.bak' -e 's/SSLProtocol all$/SSLProtocol all -SSLv3/' /etc/apache2/mods-available/ssl.conf \
	&& mkdir -p /usr/src/nextcloud/.well-known/acme-challenge && chown -R www-data: /usr/src/nextcloud/.well-known \
	&& a2disconf remoteip

# PHP configuration
RUN cp -a /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
	&& sed -i'.bak' \
  	-e 's%;?\(session.cookie_secure\) =.*%\1 = 1%' \
  	-e 's%\(session.cookie_httponly\) =.*%\1 = 1%' \
  	-e 's%\(session.use_strict_mode\) =.*%\1 = 1%' \
		/usr/local/etc/php/php.ini \
	&& echo "upload_max_filesize=512M\npost_max_size=512M" > /usr/local/etc/php/conf.d/upload-max-filesize.ini \
	&& echo "max_input_time=3600\nmax_execution_time=3600" > /usr/local/etc/php/conf.d/max-input-execution-time.ini
# See also https://github.com/nextcloud/docker/blob/master/17.0/apache/Dockerfile#L90

# Nextcloud
# rm -f /usr/src/nextcloud/AUTHORS /usr/src/nextcloud/COPYING \
# min[0-59] hour[0-23] dom[1-31] month[1-12] dow[0-7]  command
RUN echo " 0  *  *  *  *    php -f /var/www/html/occ activity:send-mails hourly > /dev/null 2>&1"  >> /var/spool/cron/crontabs/www-data \
  && echo "30  7  *  *  *    php -f /var/www/html/occ activity:send-mails daily"  >> /var/spool/cron/crontabs/www-data \
  && echo "30  7  *  *  MON  php -f /var/www/html/occ activity:send-mails weekly"  >> /var/spool/cron/crontabs/www-data \
  && echo "03  0  *  *  *    /usr/local/bin/nextcloud-sqlite-dump.sh"  >> /var/spool/cron/crontabs/www-data \
  && echo 'source <(/var/www/html/occ _completion --generate-hook --program occ)' | tee -a ~www-data/.bash_profile ~www-data/.zshrc > /dev/null 2>&1 \
  # upgrade is based on existence of file version.php; it is backed up in config/
  && ln -s config/version.php /var/www/html/ \
  # we don't persist Nextcloud core files: enable starting from a new (empty) container
  # note this will force an upgrade on each container startup :-(
  && sed -i --follow-symlinks 's%if version_greater "$image_version" "$installed_version"; then%if version_greater "$image_version" "$installed_version" || [ "$image_version" = "$installed_version" ]; then%' /entrypoint.sh
# PHP statistics tool
#	&& if ! test -f /usr/src/nextcloud/apc.php; then curl -fsSL http://pecl.php.net/get/APCu | tar xz -C /usr/src/nextcloud/ --strip-components=1 --wildcards apcu*/apc.php; fi

COPY nextcloud.conf /etc/apache2/conf-enabled/
COPY logrotate-nextcloud-dump /etc/logrotate.d/nextcloud-dump
COPY apache2-pre-foreground.sh docker-healthcheck.sh hc-ping.sh nextcloudUpgrade.sh nextcloud-sqlite-dump.sh  /usr/local/bin/
COPY --chown=www-data:www-data config/* /usr/src/nextcloud/config/

HEALTHCHECK --interval=5m --timeout=10s --start-period=30s --retries=3 \
	CMD ["/usr/local/bin/docker-healthcheck.sh"]

#ENV NEXTCLOUD_UPDATE=1
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-pre-foreground.sh"]
