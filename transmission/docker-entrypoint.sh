#!/bin/bash
set -eu -o pipefail -o posix
#shopt -s failglob
#set -x

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- transmission-daemon "$@"
fi

# check for the expected command
if [ "$1" = 'transmission-daemon' -o "$1" = '/usr/bin/transmission-daemon' ]; then

	# if [ ! "$(ls -U "${d}")" ]; then
	if ! ls -U "${TRANSMISSION_HOME}/*" > /dev/null 2>&1; then
		tar xzf /var/lib/transmission-daemon.tgz -C /var/lib
	fi

	cd "${TRANSMISSION_HOME}/info"
	curl -fsSLR -o bt_level1.gz "http://list.iblocklist.com/?list=bt_level1&fileformat=p2p&archiveformat=gz" --time-cond bt_level1.gz
	cd blocklists
	[ ../bt_level1.gz -nt bt_level1 ] && gunzip -k ../bt_level1.gz && mv ../bt_level1 .
	chown debian-transmission: *
	cd "${TRANSMISSION_HOME}"

	#sysctl -w net.core.rmem_max = 4194304
	#sysctl -w net.core.wmem_max = 1048576

	exec gosu debian-transmission "$@" --foreground --logfile /dev/stdout --log-info --config-dir "${TRANSMISSION_HOME}/info" --blocklist --no-auth --allowed '*' --dht --lpd --utp --no-portmap --encryption-preferred --watch-dir "${TRANSMISSION_HOME}/torrents" --incomplete-dir "${TRANSMISSION_HOME}/incomplete" --download-dir "${TRANSMISSION_HOME}/downloads"
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

