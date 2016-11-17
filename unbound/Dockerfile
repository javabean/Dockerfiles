FROM cedrik/baseimage:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

COPY docker-entrypoint.sh backup_conf.sh restore_conf.sh  /usr/local/bin/

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends unbound unbound-anchor dns-root-data \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#	&& curl -fsSL https://github.com/javabean/dnsmasq-antispy/archive/master.tar.gz | tar xz -C /etc/dnsmasq.d/ --strip-components=1

COPY unbound-docker.conf /etc/unbound/unbound.conf.d/

# copy conf dirs to enable populating empty volumes (see runit_unbound)
RUN /usr/local/bin/backup_conf.sh


#VOLUME ["/var/log"]

#USER unbound

EXPOSE 53/tcp 53/udp
#EXPOSE 8953

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/unbound"]
