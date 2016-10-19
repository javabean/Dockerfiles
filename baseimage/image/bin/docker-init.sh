#!/usr/local/sbin/dumb-init /bin/bash
##!/usr/local/sbin/tini -g /bin/bash

# A simple ini system semi-compatible with Phusion's baseimage-docker's my_init:
# * run startup items in /etc/my_init.d/ and /etc/rc.local
# * executes the executable given in argument, or "runit" if none
# This implementation will not take care of environment variables (/etc/container_environment*)

set -e

run_startup_files() {
	# Run /etc/my_init.d/*
	# TODO sort in lexicographical order
#	echo "Running {}..."
	find /etc/my_init.d -maxdepth 0 -type f -executable -exec "{}" ';'

	# Run /etc/rc.local.
#	echo "Running /etc/rc.local..."
	[ -x /etc/rc.local ] && /etc/rc.local
}

start_runit() {
#	echo "Booting runit daemon..."

	# Signals
	# If runsvdir receives a TERM signal, it exits with 0 immediately.
	# If runsvdir receives a HUP signal, it sends a TERM signal to each runsv(8) process it is monitoring and then exits with 111.
	# -> keep default TERM signal, and rely on dumb-init to send SIGTERM to all runsv instances
	
	[ -z "$ENABLE_SYSLOG" ] && rm -rf /etc/service/syslog-ng /etc/service/syslog-forwarder
	[ -z "$ENABLE_SSH" ] && rm -rf /etc/service/sshd
	[ -z "$ENABLE_CRON" ] && rm -rf /etc/service/cron
	[ -z "$ENABLE_CONSUL" ] && rm -rf /etc/service/consul
	
	# As we want to run this image with a r/o root, we need to move runit's files to a mounted r/w filesystem
	# see http://smarden.org/runit/faq.html#readonlyfs
	
	FIXME /run is noexec!
	
	cp -a /etc/service /run/runit-sv
	exec /usr/bin/runsvdir -P /run/runit-sv
}

shutdown_runit_services() {
#	echo "Begin shutting down runit services..."
	/usr/bin/sv down /run/runit-sv/*
}

wait_for_runit_services() {
#	echo "Waiting for runit services to exit..."
	while `/usr/bin/sv status /run/runit-sv/* | grep -q '^run:'`; do
		sleep 1
	done
}

main() {
	# /run/lock is mounted
	mkdir -p --mode=555 /run/mount /run/systemd
	chmod a+rwx,+t /run/lock

	run_startup_files

	if [ $# -eq 0 ]; then
		start_runit
	else
#		echo "Running $@..."
		exec "$@"
	fi
}
main "$@"
