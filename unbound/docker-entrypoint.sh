#!/bin/bash
set -e

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- unbound "$@"
fi

# check for the expected command
if [ "$1" = 'unbound' -o "$1" = '/usr/sbin/unbound' ]; then
	# copy backup of conf dirs if mounted volume is empty
	/usr/local/bin/restore_conf.sh
	unbound-checkconf
	if [ -z "$ENABLE_CONSUL" ]; then
		# Standalone launch
		exec "$@" -c /etc/unbound/unbound.conf
	else
		# Runit-managed launch (with Consul)
		#CONSUL_TEMPLATE_OPTS=
		#export CONSUL_TEMPLATE_OPTS
		# wait for local Consul agent
		wait_for.sh -n "Consul" -- curl -fsS -o /dev/null http://127.0.0.1:8500/
		#-log-level=debug|info|warn|err
		exec consul-template.sh -log-level=info -exec="$@ -c /etc/unbound/unbound.conf" -exec-kill-timeout="5s" -template="/etc/unbound/unbound.conf.d/forward-zone.conf.ctmpl:/etc/unbound/unbound.conf.d/forward-zone.conf:unbound-control -c /etc/unbound/unbound.conf -s 127.0.0.1 reload"
	fi
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

