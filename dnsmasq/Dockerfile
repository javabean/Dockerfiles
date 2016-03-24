FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

RUN mkdir -p /etc/service/dnsmasq /opt/dnsmasq/dnsmasq.d
#RUN ln -sf /bin/sv /etc/init.d/dnsmasq
COPY runit_dnsmasq /etc/service/dnsmasq/run
#COPY runit_dnsmasq /etc/my_init.d/dnsmasq

COPY backup_conf.sh restore_conf.sh  /usr/local/bin/

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends dnsmasq dns-root-data \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
# copy conf dirs to enable populating empty volumes (see runit_dnsmasq)
#	&& curl -fsSL https://github.com/javabean/dnsmasq-antispy/archive/master.tar.gz | tar xz -C /etc/dnsmasq.d/ --strip-components=1 \
	&& /usr/local/bin/backup_conf.sh

#VOLUME ["/var/log"]

EXPOSE 53

CMD ["/sbin/my_init"]
