#!/bin/bash
set -e

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- ziproxy "$@"
fi

trap "shut_down" HUP INT QUIT KILL TERM

shut_down() {  
	ziproxy -p /var/run/ziproxy.pid -k
}

# check for the expected command
if [ "$1" = 'ziproxy' -o "$1" = '/usr/bin/ziproxy' ]; then
	[ -d /var/log/ziproxy ] || ( mkdir /var/log/ziproxy && chown ziproxy:ziproxy /var/log/ziproxy )
	# Can not exec "$@" since Ziproxy forks...
	"$@" -c /etc/ziproxy/ziproxy.conf -u ziproxy -g ziproxy -d -p /var/run/ziproxy.pid
	# it seems we can't read from stdin here; default to eternal sleep...
	#read _
	#line
	while true; do sleep 999; done
	shut_down
	exit $0
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

