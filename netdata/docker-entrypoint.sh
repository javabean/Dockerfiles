#!/bin/bash
set -eu -o pipefail -o posix
#shopt -s failglob
#set -x

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- netdata "$@"
fi

# check for the expected command
if [ "$1" = 'netdata' -o "$1" = '/usr/sbin/netdata' ]; then
	# if [ ! "$(ls -A "${d}")" ]; then
	if ! ls -A /etc/netdata/* > /dev/null 2>&1; then
		tar xzf /etc/netdata.tgz -C /etc
	fi
	exec gosu netdata "$@" -D -s /mnt
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

