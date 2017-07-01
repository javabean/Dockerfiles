#!/usr/local/sbin/dumb-init /bin/bash
##!/usr/local/sbin/tini -g /bin/bash

# A simple ini system semi-compatible with Phusion's baseimage-docker's my_init:
# * run startup items in /etc/my_init.d/ and /etc/rc.local
# * executes the executable given in argument, or "runit" if none
# This implementation will not take care of environment variables defined in /etc/container_environment/,
# but will dump runtime environment variables in /run/environment for sub-processes to pick up

set -eu -o pipefail -o posix
shopt -s failglob
#set -x

export_envvars() {
#	echo "Writing run-time environment variables in /run/environment"
	# read-only filesystem...
	#env | grep -v ... > /etc/environment
	env | grep -v -e 'HOME' -e 'USER' -e 'LOGNAME' -e 'GROUP' -e 'UID' -e 'GID' -e 'SHELL' -e 'PWD' -e 'SHLVL' > /run/environment
	chown root:docker_env /run/environment
	chmod 640 /run/environment
}

run_startup_files() {
	# Run /etc/my_init.d/*
#	echo "Running /etc/my_init.d/..."
	run-parts --report --lsbsysinit /etc/my_init.d

	# Run /etc/rc.local.
#	echo "Running /etc/rc.local..."
	[ -x /etc/rc.local ] && /etc/rc.local
}

export SVDIR=/var/lib/runit-sv

shutdown_runit_services() {
#	echo "Begin shutting down runit services..."
	/usr/bin/sv stop ${SVDIR}/*
}

start_runit() {
#	echo "Booting runit daemon..."
	
	# As we want to run this image with a r/o root, we need to move runit's files to a mounted r/w filesystem
	# see http://smarden.org/runit/faq.html#readonlyfs
	
	# /run is noexec, so mount a tmpfs at ${SVDIR}
	if [ ! -d "${SVDIR}" ]; then
		mkdir -p "${SVDIR}"
	fi
	cp -a /etc/service/* "${SVDIR}"
	
	# beware that cron logs to syslog
	ENABLE_SYSLOG=${ENABLE_SYSLOG:-}
	ENABLE_CRON=${ENABLE_CRON:-}
	ENABLE_SSH=${ENABLE_SSH:-}
	ENABLE_CONSUL=${ENABLE_CONSUL:-}
	#[ -z "$ENABLE_SYSLOG" -a -z "$ENABLE_CRON" ] && rm -rf ${SVDIR}/syslog-ng ${SVDIR}/syslog-forwarder
	[ -z "$ENABLE_SYSLOG" ] && rm -rf ${SVDIR}/syslog-ng ${SVDIR}/syslog-forwarder
	[ -z "$ENABLE_CRON" ] && rm -rf ${SVDIR}/cron
	[ -z "$ENABLE_SSH" ] && rm -rf ${SVDIR}/sshd
	[ -z "$ENABLE_CONSUL" ] && rm -rf ${SVDIR}/consul
	
	# Signals
	# If runsvdir receives a TERM signal, it exits with 0 immediately.
	# If runsvdir receives a HUP signal, it sends a TERM signal to each runsv(8) process it is monitoring and then exits with 111.
	# -> keeping the default TERM signal, and relying on tini to send SIGTERM to all runsv instances, does not work as intended.
	# -> we can not 'exec runsvdir' since our 'trap' wouldn't be executed...
	trap "shutdown_runit_services; exit $?" TERM HUP
	
	#exec /usr/bin/runsvdir -P ${SVDIR}
	/usr/bin/runsvdir -P ${SVDIR}
	
	process_pid=$!
	# it seems we can't read from stdin here; default to eternal sleep...
	#read _
	#line
	#while true; do sleep 9999; done
	# wait "indefinitely"
	while [ -e /proc/$process_pid ]; do
		wait $process_pid # Wait for any signals or end of execution of process
	done
	# Stop container properly
	shutdown_runit_services
	exit $?
}

wait_for_runit_services() {
#	echo "Waiting for runit services to exit..."
	while `/usr/bin/sv status ${SVDIR}/* | grep -q '^run:'`; do
		sleep 1
	done
}

main() {
	# /run/lock is mounted
	if [ "$(id -u)" = "0" ]; then
		chmod a+rwx,+t /run/lock
	fi

	export_envvars

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
