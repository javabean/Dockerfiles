#!/bin/bash
set -e

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- unbound "$@"
fi

# check for the expected command
if [ "$1" = 'unbound' -o "$1" = '/usr/sbin/unbound' ]; then
	# copy backup of conf dirs if mounted volume is empty
	/usr/local/bin/restore_conf.sh
	unbound-checkconf
	exec "$@" -c /etc/unbound/unbound.conf
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

