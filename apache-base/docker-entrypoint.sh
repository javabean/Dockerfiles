#!/bin/bash
set -eu -o pipefail -o posix
shopt -s failglob
#set -x

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- apache2ctl "$@"
fi

# check for the expected command
if [ "$1" = 'apache2ctl' -o "$1" = '/usr/sbin/apache2ctl' ]; then
	# copy backup of conf dirs if mounted volume is empty
	/usr/local/bin/restore_conf.sh

	rm -f /usr/local/apache2/logs/httpd.pid /var/run/apache2/apache2.pid
	#exec gosu www-data /usr/sbin/apache2 -DFOREGROUND -k start
	exec "$@" -D FOREGROUND -k start
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

