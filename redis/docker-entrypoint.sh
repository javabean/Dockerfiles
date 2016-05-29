#!/bin/bash
set -e

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- redis "$@"
fi

# check for the expected command
if [ "$1" = 'redis' -o "$1" = '/usr/bin/redis-server' ]; then
	#exec /sbin/setuser redis "$@" /etc/redis/redis.conf --daemonize no --logfile "" --maxmemory ${MAX_MEMORY:-64mb} --maxmemory-policy noeviction
	exec "$@" /etc/redis/redis.conf --daemonize no --logfile "" --maxmemory ${MAX_MEMORY:-64mb} --maxmemory-policy noeviction
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

