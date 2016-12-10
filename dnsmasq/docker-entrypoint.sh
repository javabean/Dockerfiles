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
	DNSMASQ_ARGS="-k -u dnsmasq --no-dhcp-interface=eth0 --conntrack --conf-file=/etc/dnsmasq.conf --conf-dir=/etc/dnsmasq.d,*.conf,.dpkg-dist,.dpkg-old,.dpkg-new --domain-needed --dns-loop-detect --stop-dns-rebind --rebind-localhost-ok"
	CONSUL_TEMPLATE_OPTS=
	if [ -f /opt/dnsmasq/resolv.conf.ctmpl ]; then
		CONSUL_TEMPLATE_OPTS="$CONSUL_TEMPLATE_OPTS -template=/opt/dnsmasq/resolv.conf.ctmpl:/opt/dnsmasq/resolv.conf"
	fi
	export CONSUL_TEMPLATE_OPTS
	# wait for local Consul agent
	#wait_for.sh -n "Consul" -- curl -fsS -o /dev/null http://127.0.0.1:8500/
	#-log-level=debug|info|warn|err
	#exec consul-template.sh -log-level=info -exec="$@ ${DNSMASQ_ARGS} ${DNSMASQ_EXTRA_OPTS}" -exec-kill-timeout="5s" -template="/opt/dnsmasq/consul.json.ctmpl:/usr/local/etc/consul.d/dnsmasq.json:consul reload"
	exec "$@" ${DNSMASQ_ARGS} ${DNSMASQ_EXTRA_OPTS}
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

