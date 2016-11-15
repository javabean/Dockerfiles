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

RUNIT_SV_DIR=/var/lib/runit-sv

start_runit() {
#	echo "Booting runit daemon..."

	# Signals
	# If runsvdir receives a TERM signal, it exits with 0 immediately.
	# If runsvdir receives a HUP signal, it sends a TERM signal to each runsv(8) process it is monitoring and then exits with 111.
	# -> keep default TERM signal, and rely on tini to send SIGTERM to all runsv instances
	
	# As we want to run this image with a r/o root, we need to move runit's files to a mounted r/w filesystem
	# see http://smarden.org/runit/faq.html#readonlyfs
	
	# /run is noexec, so mount a tmpfs at ${RUNIT_SV_DIR}
	cp -a /etc/service/* ${RUNIT_SV_DIR}
	
	[ -z "$ENABLE_SYSLOG" ] && rm -rf ${RUNIT_SV_DIR}/syslog-ng ${RUNIT_SV_DIR}/syslog-forwarder
	[ -z "$ENABLE_SSH" ] && rm -rf ${RUNIT_SV_DIR}/sshd
	[ -z "$ENABLE_CRON" ] && rm -rf ${RUNIT_SV_DIR}/cron
	[ -z "$ENABLE_CONSUL" ] && rm -rf ${RUNIT_SV_DIR}/consul
	
	exec /usr/bin/runsvdir -P ${RUNIT_SV_DIR}
}

shutdown_runit_services() {
#	echo "Begin shutting down runit services..."
	/usr/bin/sv down ${RUNIT_SV_DIR}/*
}

wait_for_runit_services() {
#	echo "Waiting for runit services to exit..."
	while `/usr/bin/sv status ${RUNIT_SV_DIR}/* | grep -q '^run:'`; do
		sleep 1
	done
}

main() {
	# /run/lock is mounted
	if [ "$(id -u)" = "0" ]; then
		chmod a+rwx,+t /run/lock
	fi

	run_startup_files

	if [ $# -eq 0 ]; then
#		echo "Starting runit..."
		start_runit
	else
#		echo "Running $@..."
		exec "$@"
	fi
}
main "$@"
