#!/bin/bash
set -eu -o pipefail -o posix
#shopt -s failglob
#set -x

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1#-}" != "$1" ]; then
    set -- apache2-foreground "$@"
fi

# check for the expected command
if [ "$1" = 'apache2ctl' -o "$1" = '/usr/sbin/apache2ctl' -o "$1" = 'apache2-foreground' -o "$1" = '/usr/local/bin/apache2-foreground' ]; then
	# copy backup of conf dirs if mounted volume is empty
	/usr/local/bin/restore_conf.sh

	rm -f /usr/local/apache2/logs/httpd.pid /var/run/apache2/apache2.pid
	# ssl_scache shouldn't be here if we're just starting up.
	# (this is bad if there are several apache2 instances running)
	rm -f ${APACHE_RUN_DIR:-/var/run/apache2}/*ssl_scache*

	#exec apache2 -D FOREGROUND -k start
	#exec "$@" -D FOREGROUND -k start
	exec "$@"
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

