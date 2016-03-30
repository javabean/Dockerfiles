#!/bin/bash
set -e

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- dnsmasq "$@"
fi

# check for the expected command
if [ "$1" = 'dnsmasq' -o "$1" = '/usr/sbin/dnsmasq' ]; then
	# copy backup of conf dirs if mounted volume is empty
	/usr/local/bin/restore_conf.sh
	exec "$@" -k -u dnsmasq --no-dhcp-interface=eth0 --conntrack --conf-file=/etc/dnsmasq.conf --conf-dir='/etc/dnsmasq.d,*.conf,.dpkg-dist,.dpkg-old,.dpkg-new' --domain-needed --dns-loop-detect --stop-dns-rebind --rebind-localhost-ok ${DNSMASQ_EXTRA_OPTS}
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

