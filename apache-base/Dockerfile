FROM buildpack-deps:22.04 as builder

ARG MOD_MAXMINDDB_VERSION=1.2.0

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils software-properties-common \
  && LC_ALL=C.UTF-8  add-apt-repository --no-update -y ppa:ondrej/apache2 \
  && LC_ALL=C.UTF-8  add-apt-repository --no-update -y ppa:maxmind/ppa \
  && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apache2 apache2-dev libmaxminddb0 libmaxminddb-dev \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && curl -fsSL https://github.com/maxmind/mod_maxminddb/releases/download/${MOD_MAXMINDDB_VERSION}/mod_maxminddb-${MOD_MAXMINDDB_VERSION}.tar.gz | tar xz -C /usr/src \
  && cd /usr/src/mod_maxminddb* \
  && ./configure \
  && make install



FROM cedrik/baseimage:18.04
LABEL org.opencontainers.image.authors="Cédrik LIME"

ENV APACHE_CONFDIR=/etc/apache2
ENV APACHE_ENVVARS=${APACHE_CONFDIR}/envvars

#RUN echo "Apachai Hopachai" > /etc/container_environment/MY_NAME

#RUN ln -sf /bin/sv /etc/init.d/apache2
COPY runit_apache2 /etc/service/apache2/run
#COPY runit_apache2 /etc/my_init.d/apache2
#COPY apache2.conf /etc/apache2.conf

COPY consul-healthcheck.sh backup_conf.sh restore_conf.sh docker-entrypoint.sh  /usr/local/bin/

COPY security-add.conf /tmp/

ADD https://raw.githubusercontent.com/docker-library/php/master/8.2/bullseye/apache/apache2-foreground  /usr/local/bin/

RUN chmod +x /usr/local/bin/apache2-foreground \
  && LC_ALL=C.UTF-8  add-apt-repository -y --no-update ppa:ondrej/apache2 \
  && LC_ALL=C.UTF-8  add-apt-repository -y --no-update ppa:maxmind/ppa \
	&& apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apache2 apache2-utils openssl libapache2-mod-xsendfile \
	#libapache2-mod-geoip geoip-database geoip-bin geoipupdate \
	mmdb-bin \
	&& a2enmod unique_id auth_digest authz_host expires headers info reqtimeout rewrite remoteip slotmem_shm socache_shmcb \
#	&& a2dismod \
#	&& a2enconf \
	&& a2disconf serve-cgi-bin \
#	&& a2ensite \
	&& a2dissite default-ssl \
	&& sed -i'.bak' -e 's/^\(ServerTokens OS\)$/#\1\nServerTokens Prod/' \
		-e 's/^#\(ServerSignature Off\)/\1/' \
		-e 's/^\(ServerSignature On\)/#\1/' \
		/etc/apache2/conf-available/security.conf \
	&& cat /tmp/security-add.conf >> /etc/apache2/conf-available/security.conf \
	&& rm /tmp/security-add.conf \
#	&& sed -i'.bak' -e 's/\(SSLProtocol all -SSLv3\)$/\1 -TLSv1 -TLSv1.1/' /etc/apache2/mods-available/ssl.conf \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& mkdir -p /var/www/html/.well-known/acme-challenge && chown -R www-data: /var/www/html/.well-known \
#	&& geoipupdate \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh

COPY --from=builder /usr/lib/apache2/modules/mod_maxminddb.so /usr/lib/apache2/modules/
COPY --from=builder /etc/apache2/mods-available/maxminddb.load /etc/apache2/mods-available/
COPY maxminddb.conf /etc/apache2/conf-available/

#VOLUME ["/var/log"]

#USER www-data

EXPOSE 80 443

HEALTHCHECK --interval=5m --timeout=10s --start-period=5s --retries=2 \
	CMD ["/usr/local/bin/docker-healthcheck.sh"]

#ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
#CMD ["/usr/local/bin/apache2-foreground"]

#ENTRYPOINT ["/usr/local/sbin/docker-init.sh"]
