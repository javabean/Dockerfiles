FROM cedrik/baseimage:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

COPY docker-entrypoint.sh  /usr/local/bin/

COPY 60-redis.conf /etc/sysctl.d/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends redis-server \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& sed -i'.bak' \
		-e 's/\(daemonize\) yes/\1 no/' \
		-e 's/\(bind 127.0.0.1\)/# \1/' \
		-e 's/# \(maxclients\) 10000/\1 200/' \
		-e 's/# \(maxmemory\) <bytes>/\1 64mb/' \
		-e 's/# \(maxmemory-policy noeviction\)/\1/' \
		-e 's%^\(logfile /var/log/redis/redis-server.log\)%#\1%' \
		/etc/redis/redis.conf

#VOLUME ["/var/lib/redis/" "/var/log"]

USER redis

EXPOSE 6379

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/redis-server"]
