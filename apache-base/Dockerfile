FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

#RUN echo "Apachai Hopachai" > /etc/container_environment/MY_NAME

RUN mkdir -p /etc/service/apache2
#RUN ln -sf /bin/sv /etc/init.d/apache2
COPY runit_apache2 /etc/service/apache2/run
#COPY runit_apache2 /etc/my_init.d/apache2
#COPY apache2.conf /etc/apache2.conf

COPY backup_conf.sh restore_conf.sh  /usr/local/bin/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apache2 apache2-utils openssl libapache2-mod-xsendfile \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& for m in "auth_digest authz_host expires headers info reqtimeout rewrite remoteip slotmem_shm socache_shmcb" ; do a2enmod $m; done \
#	&& for m in "" ; do a2dismod $m; done \
	&& a2disconf serve-cgi-bin \
	&& a2dissite default-ssl \
	&& sed -i'.bak' -e 's/^\(ServerTokens OS\)$/#\1\nServerTokens Prod/' \
		-e 's/^#\(ServerSignature Off\)/\1/' \
		-e 's/^\(ServerSignature On\)/#\1/' \
		-e 's/^\(#Header set X-Frame-Options.*\)$/\1\nHeader setifempty X-Frame-Options: "sameorigin"\nHeader setifempty Content-Security-Policy: "frame-ancestors 'self' example.com *.example.net ; object-src 'none' ; plugin-types 'none' ; connect-src 'self' * ;"/' \
		/etc/apache2/conf-available/security.conf \
#	&& sed -i'.bak' -e 's/SSLProtocol all$/SSLProtocol all -SSLv3/' /etc/apache2/mods-available/ssl.conf \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh

#VOLUME ["/var/log"]

#USER www-data

EXPOSE 80 443

#CMD ["/usr/sbin/apache2", "-DFOREGROUND", "-k", "start"]
CMD ["/sbin/my_init"]
