#FROM memcached:1.4
FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

RUN mkdir -p /etc/service/memcached
#RUN ln -sf /bin/sv /etc/init.d/memcached
COPY runit_memcached /etc/service/memcached/run
#COPY runit_memcached /etc/my_init.d/memcached
COPY memcached.conf /etc/memcached.conf

ARG MEMCACHED_VERSION=1.4.25

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends memcached curl \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& curl -fsSL http://www.memcached.org/files/memcached-${MEMCACHED_VERSION}.tar.gz | tar xz -C /usr/local/bin --strip-components=2 memcached-${MEMCACHED_VERSION}/scripts/memcached-tool
#	&& sed -i'.bak' -e 's/^-d$/#-d/' -e 's/^-m [0-9]*$/-m 96/' -e 's/^\(-l 127.0.0.1\)/#\1/' -e 's/^# -c 1024$/-c 256/' /etc/memcached.conf

#VOLUME ["/var/log"]

#USER memcached

EXPOSE 11211

#ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD ["/sbin/my_init"]
# memcached does not read itself its configuration file!
#CMD ["/usr/bin/memcached", "-m", "96", "-p, "1121", "-c", "256", "-u", "root"]
