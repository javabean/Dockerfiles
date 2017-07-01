#!/bin/bash
set -eu -o pipefail -o posix
shopt -s failglob
#set -x

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- dovecot "$@"
fi

# check for the expected command
if [ "$1" = 'dovecot' -o "$1" = '/usr/sbin/dovecot' ]; then
	if [ "$(stat -c %u /srv/dovecot)" != "$(id -u mail)" ] || [ "$(stat -c %g /srv/dovecot)" != "$(id -g mail)" ]; then
		chown -R mail:mail /srv/dovecot
	fi

	# Read-only file system...
	#[ -e /opt/dovecot/local.conf ] && chown dovecot:dovecot /opt/dovecot/local.conf
	#[ -e /opt/dovecot/passwd ] && chown dovecot:dovecot /opt/dovecot/passwd

    exec "$@" -F -c /etc/dovecot/dovecot.conf
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

