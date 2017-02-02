#FROM memcached:1.4
FROM cedrik/baseimage:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

COPY docker-entrypoint.sh consul-healthcheck.sh  /usr/local/bin/

ARG MEMCACHED_VERSION=1.4.34

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends memcached curl \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& curl -fsSL http://www.memcached.org/files/memcached-${MEMCACHED_VERSION}.tar.gz | tar xz -C /usr/local/bin --strip-components=2 memcached-${MEMCACHED_VERSION}/scripts/memcached-tool
# memcached does not read itself its configuration file!
#	&& sed -i'.bak' -e 's/^-d$/#-d/' -e 's/^-m [0-9]*$/-m 96/' -e 's/^\(-l 127.0.0.1\)/#\1/' -e 's/^# -c 1024$/-c 256/' /etc/memcached.conf

#VOLUME ["/var/log"]

#USER memcache

EXPOSE 11211

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/memcached"]
