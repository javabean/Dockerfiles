#!/usr/local/sbin/dumb-init /bin/bash
##!/usr/local/sbin/tini -g /bin/bash

# A simple ini system semi-compatible with Phusion's baseimage-docker's my_init:
# * run startup items in /etc/my_init.d/ and /etc/rc.local
# * executes the executable given in argument, or "runit" if none
# This implementation will not take care of environment variables defined in /etc/container_environment/,
# but will dump runtime environment variables in /run/environment for sub-processes to pick up

set -e

export_envvars() {
#	echo "Writing run-time environment variables in /run/environment"
	# read-only filesystem...
	#env | grep -v ... > /etc/environment
	env | grep -v -e 'HOME' -e 'USER' -e 'LOGNAME' -e 'GROUP' -e 'UID' -e 'GID' -e 'SHELL' -e 'PWD' > /run/environment
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
	if [ ! -d "${RUNIT_SV_DIR}" ]; then
		mkdir -p "${RUNIT_SV_DIR}"
	fi
	cp -a /etc/service/* "${RUNIT_SV_DIR}"
	
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
