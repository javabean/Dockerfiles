FROM cedrik/baseimage:16.04
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

COPY docker-entrypoint.sh consul-healthcheck.sh backup_conf.sh restore_conf.sh dnsmasq-cache-statistics.sh  /usr/local/bin/
COPY runit_dnsmasq /etc/service/dnsmasq/run
COPY consul.json.ctmpl /opt/dnsmasq/

RUN mkdir -p /opt/dnsmasq \
	&& touch /opt/dnsmasq/hosts /opt/dnsmasq/resolv.conf \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends dnsmasq dns-root-data dnsutils \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#	&& curl -fsSL https://github.com/javabean/dnsmasq-antispy/archive/master.tar.gz | tar xz -C /etc/dnsmasq.d/ --strip-components=1 \
# copy conf dirs to enable populating empty volumes (see runit_dnsmasq)
	&& /usr/local/bin/backup_conf.sh

#VOLUME ["/var/log"]

#USER dnsmasq

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/local/sbin/docker-init.sh"]
#ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
#CMD ["/usr/sbin/dnsmasq"]
