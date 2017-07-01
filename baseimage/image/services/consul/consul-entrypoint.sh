#!/bin/bash
#set -u
set -e -o pipefail -o posix
shopt -s failglob
#set -x

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
	set -- consul "$@"
fi

CONSUL_BIND="-bind 0.0.0.0"
CONSUL_CLIENT="-client 0.0.0.0"

CONSUL_DATA_DIR=/srv/consul/data
CONSUL_CONFIG_FILE=/usr/local/etc/consul.json
CONSUL_CONFIG_DIR=/usr/local/etc/consul.d
#CONSUL_UI_DIR=/usr/local/share/consul/ui

CONSUL_DNS=
if [ -z "$CONSUL_NO_DNS_53" ] && [ -x /usr/bin/authbind ]; then
	CONSUL_DNS="-dns-port=53"
else
	CONSUL_DNS="-dns-port=8600"
fi


# Look for Consul subcommands.
if [ "$1" = 'consul' -o "$1" = '/usr/local/bin/consul' ]; then
	shift
fi
if [ "$1" = 'agent' ]; then
	shift
	set -- consul agent \
		-data-dir="$CONSUL_DATA_DIR" \
		-config-file="$CONSUL_CONFIG_FILE" \
		-config-dir="$CONSUL_CONFIG_DIR" \
		-ui \
		$CONSUL_BIND \
		$CONSUL_CLIENT \
		$CONSUL_DNS \
		"$@"
#		-ui-dir="$CONSUL_UI_DIR" \
elif [ "$1" = 'version' ]; then
	# This needs a special case because there's no help output.
	set -- consul "$@"
elif consul --help "$1" 2>&1 | grep -q "consul $1"; then
	# We can't use the return code to check for the existence of a subcommand, so
	# we have to use grep to look for a pattern in the help output.
	set -- consul "$@"
fi

# check for the expected command
if [ "$1" = 'consul' -o "$1" = '/usr/local/bin/consul' ]; then
	mkdir -p /tmp/consul/data
	chown -R consul: /tmp/consul
	# If the data or config dirs are bind mounted then chown them.
	# Note: This checks for root ownership as that's the most common case.
	if [ "$(stat -c %u $CONSUL_DATA_DIR)" != "$(id -u consul)" ]; then
		chown -R consul:consul "$CONSUL_DATA_DIR"
	fi
	if [ "$(stat -c %u $CONSUL_CONFIG_FILE)" != "$(id -u consul)" ]; then
		chown consul:consul "$CONSUL_CONFIG_FILE"
	fi
	if [ "$(stat -c %u $CONSUL_CONFIG_DIR)" != "$(id -u consul)" ]; then
		chown -R consul:consul "$CONSUL_CONFIG_DIR"
	fi
	
	# Forward DNS queries to Consul
	# Useless, since we use authbind to enable Consul to bind on port 53
#	iptables -t nat -C PREROUTING -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600 || {
#		iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
#	}
#	iptables -t nat -C PREROUTING -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600 || {
#		iptables -t nat -A PREROUTING -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
#	}
#	iptables -t nat -C OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600 || {
#		iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
#	}
#	iptables -t nat -C OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600 || {
#		iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
#	}

	#exec gosu consul "$@" $CONSUL_OPTS
	if [ -x /usr/bin/authbind ]; then
		exec gosu consul /usr/bin/authbind --deep "$@" $CONSUL_OPTS
	else
		exec gosu consul "$@" $CONSUL_OPTS
	fi
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

