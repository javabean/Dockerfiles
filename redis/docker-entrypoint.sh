#!/bin/sh

exec /sbin/setuser redis /usr/bin/redis-server /etc/redis/redis.conf --daemonize no --maxmemory ${MAX_MEMORY:-64mb} --maxmemory-policy noeviction
#exec chpst -u redis /usr/bin/redis-server /etc/redis/redis.conf --daemonize no --maxmemory ${MAX_MEMORY:-64mb} --maxmemory-policy noeviction
