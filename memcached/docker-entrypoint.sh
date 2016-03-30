#!/bin/sh
set -e
. /etc/memcached.conf
#exec /sbin/setuser memcache /usr/bin/memcached >>/var/log/memcached.log 2>&1
#exec chpst -u memcache /usr/bin/memcached $MEMCACHED_OPTS >>/var/log/memcached.log 2>&1
exec /usr/bin/memcached $MEMCACHED_OPTS >>/var/log/memcached.log 2>&1

