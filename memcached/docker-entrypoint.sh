#!/bin/bash
set -e

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- memcached "$@"
fi

# check for the expected command
if [ "$1" = 'memcached' -o "$1" = '/usr/bin/memcached' ]; then
	#exec /sbin/setuser memcache /usr/bin/memcached $MEMCACHED_OPTS >>/var/log/memcached.log 2>&1
	exec "$@" -u memcache -m ${MEM_SIZE:-64} -p 11211 -c 256
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

