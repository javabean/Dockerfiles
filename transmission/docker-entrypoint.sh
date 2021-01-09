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

	TRANSMISSION_EXTRA_ARGS=

	if [ -z "$(ls -AUq -- "${TRANSMISSION_HOME}" 2> /dev/null)" ]; then
		tar xzf /var/lib/transmission-daemon.tgz -C /var/lib
		TRANSMISSION_EXTRA_ARGS="--log-info --blocklist --username transmission --password transmission --allowed 127.0.0.*,192.168.*.*,172.16.*.*,172.17.*.*,172.18.*.*,172.19.*.*,172.2*.*,172.30.*.*,172.31.*.*,10.*.*.* --dht --lpd --utp --no-portmap --encryption-preferred --watch-dir ${TRANSMISSION_HOME}/torrents --incomplete-dir ${TRANSMISSION_HOME}/incomplete --download-dir ${TRANSMISSION_HOME}/downloads"
	fi

	cd "${TRANSMISSION_HOME}/info"
	curl -fsSLR -o bt_level1.gz "https://list.iblocklist.com/?list=bt_level1&fileformat=p2p&archiveformat=gz" --time-cond bt_level1.gz
	cd blocklists
	[ ../bt_level1.gz -nt bt_level1 ] && gunzip -k ../bt_level1.gz && mv ../bt_level1 .
	chown debian-transmission: *
	cd "${TRANSMISSION_HOME}"

	#sysctl -w net.core.rmem_max = 4194304
	#sysctl -w net.core.wmem_max = 1048576

	modprobe -v tcp_lp || true
	#echo reno cubic lp > /proc/sys/net/ipv4/tcp_allowed_congestion_control

	# shellcheck disable=SC2086
	exec gosu debian-transmission "$@" --foreground --logfile /dev/stdout --config-dir "${TRANSMISSION_HOME}/info" ${TRANSMISSION_EXTRA_ARGS}
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

