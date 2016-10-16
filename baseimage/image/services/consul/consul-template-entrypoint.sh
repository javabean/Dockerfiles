#!/bin/bash
set -e

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
	set -- consul-template "$@"
fi

CONSUL_TEMPLATE_CONFIG_DIR=/usr/local/etc/consul-template
#-dedup -wait="5s:10s"
CONSUL_TEMPLATE_ARGS="-once -pid-file= -reload-signal== -dump-signal= -kill-signal=SIGTERM config=/usr/local/etc/consul-template -exec-splay=2s"

# check for the expected command
if [ "$1" = 'consul-template' -o "$1" = '/usr/local/bin/consul-template' ]; then
	#exec gosu consul "$@" ${CONSUL_TEMPLATE_ARGS} -template="in:out(:command)" -exec="..." -exec-kill-signal="SIGTERM" -exec-kill-timeout="30s" -exec-reload-signal="" $CONSUL_TEMPLATE_OPTS
	if [ -x /usr/bin/authbind ]; then
		exec gosu consul /usr/bin/authbind --deep "$@" ${CONSUL_TEMPLATE_ARGS} $CONSUL_TEMPLATE_OPTS
	else
		exec gosu consul "$@" ${CONSUL_TEMPLATE_ARGS} $CONSUL_TEMPLATE_OPTS
	fi
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

