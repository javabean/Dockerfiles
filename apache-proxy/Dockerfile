FROM cedrik/httpd-base:latest
LABEL org.opencontainers.image.authors="Cédrik LIME"

COPY backup_conf_local.sh restore_conf_local.sh  /usr/local/bin/
COPY http2.conf acme.conf /etc/apache2/conf-enabled/

# libapache2-mod-evasive depends on mailx, and thus loads quite a few dependencies
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libapache2-mod-evasive \
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libcurl4 libjansson4 libmaxminddb0 \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
# watchdog module is statically linked \
	&& for m in "http2 ssl md maxminddb setenvif proxy proxy_ajp proxy_balancer proxy_http proxy_wstunnel lbmethod_bybusyness lbmethod_byrequests lbmethod_bytraffic lbmethod_heartbeat autoindex dav_fs auth_digest" ; do a2enmod $m; done \
	&& for m in "remoteip" ; do a2dismod $m; done \
	&& for m in "maxminddb" ; do a2enconf $m; done \
#	&& a2disconf serve-cgi-bin \
	&& a2dissite default-ssl \
	&& a2dissite 000-default.conf \
	&& mkdir -p /opt/http-proxy/mods-enabled /opt/http-proxy/conf-enabled /opt/http-proxy/conf-include /opt/http-proxy/sites-enabled \
	&& ln -s /opt/http-proxy/conf-include /etc/apache2/ \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh

COPY zzzz_mods.conf /etc/apache2/mods-enabled/
COPY zzzz_conf.conf /etc/apache2/conf-enabled/
COPY zzzz_sites.conf /etc/apache2/sites-enabled/

#VOLUME ["/var/log", "/opt/http-proxy/mods-enabled", "/opt/http-proxy/conf-enabled", "/opt/http-proxy/conf-include", "/opt/http-proxy/sites-enabled"]

#USER www-data

EXPOSE 80 443

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/bin/apache2-foreground"]
