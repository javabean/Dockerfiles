#!/bin/bash
set -eu -o pipefail -o posix
shopt -s failglob
#set -x

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- ziproxy "$@"
fi

shut_down() {  
	ziproxy -p /var/run/ziproxy.pid -k
}

trap "shut_down" HUP INT QUIT KILL TERM

# check for the expected command
if [ "$1" = 'ziproxy' -o "$1" = '/usr/bin/ziproxy' ]; then
	[ -d /var/log/ziproxy ] || ( mkdir /var/log/ziproxy && chown ziproxy:ziproxy /var/log/ziproxy )
	# Can not exec "$@" since Ziproxy forks...
	"$@" -c /etc/ziproxy/ziproxy.conf -u ziproxy -g ziproxy -d -p /var/run/ziproxy.pid
	process_pid=$!
	# it seems we can't read from stdin here; default to eternal sleep...
	#read _
	#line
	#while true; do sleep 9999; done
	# wait "indefinitely"
	while [ -e /proc/$process_pid ]; do
		wait $process_pid # Wait for any signals or end of execution of process
	done
	# Stop container properly
	shut_down
	exit $?
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

