#!/usr/local/sbin/dumb-init /bin/bash
##!/usr/local/sbin/tini -g /bin/bash

# A simple init system semi-compatible with Phusion's baseimage-docker's my_init:
# * run startup items in "${ENV_INIT_DIRECTORY:-/etc/my_init.d}" and "/etc/rc.local"
# * run shutdown items in "/etc/my_init.pre_shutdown.d" and "/etc/my_init.post_shutdown.d" (runit-managed processes only)
# * executes the executable given in argument, or "runit" if none
# 
# This implementation will not take care of environment variables defined in "/etc/container_environment/",
# but will dump runtime environment variables in "/run/environment" for sub-processes to pick up.
# 
# Also no support for ${KILL_PROCESS_TIMEOUT} and ${KILL_ALL_PROCESSES_TIMEOUT} environment variables;
# defaults to runit's 7 seconds timeout (for shorter timeout: use Docker's native timeout facility).

set -eu -o pipefail -o posix
shopt -s failglob
#set -x

ENV_INIT_DIRECTORY=${ENV_INIT_DIRECTORY:-/etc/my_init.d}

export_envvars() {
#	echo "Writing run-time environment variables in /run/environment"
	# read-only filesystem...
	#env | grep -v ... > /etc/environment
	env | grep -v -e 'HOME' -e 'USER' -e 'LOGNAME' -e 'GROUP' -e 'UID' -e 'GID' -e 'SHELL' -e 'PWD' -e 'SHLVL' > /run/environment
	chown root:docker_env /run/environment
	chmod 640 /run/environment
}

run_startup_files() {
	# Run ${ENV_INIT_DIRECTORY}/*
#	echo "Running ${ENV_INIT_DIRECTORY}/..."
	[ -d ${ENV_INIT_DIRECTORY} ] && run-parts --report --lsbsysinit ${ENV_INIT_DIRECTORY}

	# Run /etc/rc.local.
#	echo "Running /etc/rc.local..."
	[ -x /etc/rc.local ] && /etc/rc.local
}

run_pre_shutdown_scripts() {
#	echo "Running pre-shutdown scripts..."
	# Run /etc/my_init.pre_shutdown.d/*
	[ -d /etc/my_init.pre_shutdown.d ] && run-parts --report --lsbsysinit /etc/my_init.pre_shutdown.d
}

run_post_shutdown_scripts() {
#	echo "Running post-shutdown scripts..."
	# Run /etc/my_init.post_shutdown.d/*
	[ -d /etc/my_init.post_shutdown.d ] && run-parts --report --lsbsysinit /etc/my_init.post_shutdown.d
}

export SVDIR=/var/lib/runit-sv

shutdown_runit_services() {
#	echo "Begin shutting down runit services..."
#	/usr/bin/sv -w ${KILL_PROCESS_TIMEOUT:-5} down ${SVDIR}/* > /dev/null
	/usr/bin/sv stop ${SVDIR}/*
}

wait_for_runit_services() {
#	echo "Waiting for runit services to exit..."
	while `/usr/bin/sv status ${SVDIR}/* | grep -q '^run:'`; do
		sleep 1
	done
}

clean_shutdown_runit() {
	run_pre_shutdown_scripts
	shutdown_runit_services
	wait_for_runit_services
	run_post_shutdown_scripts
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
	local ENABLE_SYSLOG=${ENABLE_SYSLOG:-}
	local ENABLE_CRON=${ENABLE_CRON:-}
	local ENABLE_SSH=${ENABLE_SSH:-}
	local ENABLE_CONSUL=${ENABLE_CONSUL:-}
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
	trap "clean_shutdown_runit; exit $?" TERM HUP
	
	#exec /usr/bin/runsvdir -P ${SVDIR}
	/usr/bin/runsvdir -P ${SVDIR}
	
	#local process_pid=$!
	# it seems we can't read from stdin here; default to eternal sleep...
	#read _
	#line
	while true; do sleep 9999; done
	# wait "indefinitely"
	#while [ -e /proc/$process_pid ]; do
	#	wait $process_pid # Wait for any signals or end of execution of process
	#done
	# Stop container properly
	clean_shutdown_runit
	exit $?
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
