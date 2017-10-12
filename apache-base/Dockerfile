FROM cedrik/baseimage:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

#RUN echo "Apachai Hopachai" > /etc/container_environment/MY_NAME

#RUN ln -sf /bin/sv /etc/init.d/apache2
COPY runit_apache2 /etc/service/apache2/run
#COPY runit_apache2 /etc/my_init.d/apache2
#COPY apache2.conf /etc/apache2.conf

COPY GeoIP.conf /etc/

COPY consul-healthcheck.sh backup_conf.sh restore_conf.sh docker-entrypoint.sh  /usr/local/bin/

ADD https://raw.githubusercontent.com/docker-library/php/master/7.1/apache/apache2-foreground  /usr/local/bin/

RUN chmod +x /usr/local/bin/apache2-foreground \
  && LC_ALL=C.UTF-8  add-apt-repository -y ppa:ondrej/apache2 \
	&& apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apache2 apache2-utils openssl libapache2-mod-xsendfile \
	#libapache2-mod-geoip geoip-database geoipupdate geoip-bin mmdb-bin \
	libapache2-mod-geoip geoip-database geoip-bin \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& for m in "auth_digest authz_host expires headers info reqtimeout rewrite remoteip slotmem_shm socache_shmcb" ; do a2enmod $m; done \
#	&& for m in "" ; do a2dismod $m; done \
	&& a2disconf serve-cgi-bin \
	&& a2dissite default-ssl \
	&& sed -i'.bak' -e 's/^\(ServerTokens OS\)$/#\1\nServerTokens Prod/' \
		-e 's/^#\(ServerSignature Off\)/\1/' \
		-e 's/^\(ServerSignature On\)/#\1/' \
		-e 's/^#Header set \(X-Content-Type-Options:? "nosniff"\)/Header setifempty \1/' \
		# X-Frame-Options and X-XSS-Protection have been superseded by Content Security Policy (CSP)
		-e 's/^\(#Header set X-Frame-Options.*\)$/\1\nHeader setifempty X-Frame-Options "sameorigin"\nHeader setifempty X-XSS-Protection "1; mode=block"\nHeader setifempty Content-Security-Policy "frame-ancestors '\''self'\'' example.com *.example.net ; object-src '\''none'\'' ; connect-src '\''self'\'' * ;"/' \
		/etc/apache2/conf-available/security.conf \
	&& echo "\n\n\n# https://httpoxy.org\nRequestHeader unset Proxy early\n" >> /etc/apache2/conf-available/security.conf \
#	&& sed -i'.bak' -e 's/SSLProtocol all$/SSLProtocol all -SSLv3/' /etc/apache2/mods-available/ssl.conf \
	&& mkdir -p /var/www/html/.well-known/acme-challenge && chown -R www-data: /var/www/html/.well-known \
	&& cd /usr/share/GeoIP && curl -fsSLRO http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz && gunzip -f GeoIP.dat.gz && cd - \
	#&& geoipupdate \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh

#VOLUME ["/var/log"]

#USER www-data

EXPOSE 80 443

HEALTHCHECK --interval=5m --timeout=10s --retries=2 \
	CMD ["/usr/local/bin/docker-healthcheck.sh"]

#ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
#CMD ["/usr/local/bin/apache2-foreground"]

#ENTRYPOINT ["/usr/local/sbin/docker-init.sh"]
