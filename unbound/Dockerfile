FROM cedrik/baseimage:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

COPY docker-entrypoint.sh backup_conf.sh restore_conf.sh unbound-statistics.sh  /usr/local/bin/
COPY runit_unbound /etc/service/unbound/run
COPY consul.json /usr/local/etc/consul.d/unbound.json

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends unbound unbound-anchor dns-root-data \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#	&& curl -fsSL https://github.com/javabean/dnsmasq-antispy/archive/master.tar.gz | tar xz -C /etc/dnsmasq.d/ --strip-components=1 \
	&& if ! [ -f /etc/unbound/icannbundle.pem ]; then \
		curl -fsSL -o /etc/unbound/icannbundle.pem https://data.iana.org/root-anchors/icannbundle.pem ; \
	fi \
	&& if ! [ -f /var/lib/unbound/root.key ]; then \
		unbound-anchor -a /var/lib/unbound/root.key -v 2>&1 ; \
		chown unbound:unbound /var/lib/unbound/root.key ; \
	fi \
	&& if ! [ -f /etc/unbound/unbound_server.pem -o -f /etc/unbound/unbound_control.pem ]; then \
		unbound-control-setup ; \
	fi

COPY unbound.conf.d/* /etc/unbound/unbound.conf.d/

# copy conf dirs to enable populating empty volumes (see runit_unbound)
RUN /usr/local/bin/backup_conf.sh


#VOLUME ["/var/log", "/etc/unbound/unbound.conf.d"]

#USER unbound

EXPOSE 53/tcp 53/udp
#EXPOSE 8953

#ENTRYPOINT ["/usr/local/sbin/docker-init.sh"]
ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/unbound"]
