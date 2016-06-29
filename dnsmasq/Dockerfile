FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

COPY docker-entrypoint.sh backup_conf.sh restore_conf.sh  /usr/local/bin/

RUN mkdir -p /opt/dnsmasq/dnsmasq.d \
	&& touch /opt/dnsmasq/hosts /opt/dnsmasq/resolv.conf \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends dnsmasq dns-root-data \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#	&& curl -fsSL https://github.com/javabean/dnsmasq-antispy/archive/master.tar.gz | tar xz -C /etc/dnsmasq.d/ --strip-components=1 \
# copy conf dirs to enable populating empty volumes (see runit_dnsmasq)
	&& /usr/local/bin/backup_conf.sh

#VOLUME ["/var/log"]

#USER dnsmasq

EXPOSE 53/tcp 53/udp

#ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/local/bin/docker-entrypoint.sh"]
ENTRYPOINT ["/usr/local/bin/tini", "-g", "--", "/usr/local/bin/docker-entrypoint.sh"]
#ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["/usr/sbin/dnsmasq"]
