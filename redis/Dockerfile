FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

RUN mkdir -p /etc/service/redis
#RUN ln -sf /bin/sv /etc/init.d/redis
COPY runit_redis /etc/service/redis/run
#COPY runit_redis /etc/my_init.d/redis
#COPY runit_redis_log /etc/service/redis/log/run

COPY 60-redis.conf /etc/sysctl.d/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends redis-server \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& sed -i'.bak' -e 's/\(daemonize\) yes/\1 no/' -e 's/\(bind 127.0.0.1\)/# \1/' -e 's/# \(maxclients\) 10000/\1 200/' -e 's/# \(maxmemory\) <bytes>/\1 64mb/' -e 's/# \(maxmemory-policy noeviction\)/\1/'  /etc/redis/redis.conf

#VOLUME ["/var/lib/redis/" "/var/log"]

EXPOSE 6379

#ENTRYPOINT /usr/bin/redis-server
#CMD ["/etc/redis/redis.conf", "--daemonize", "no"]
CMD ["/sbin/my_init"]
