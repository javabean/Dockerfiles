#!/bin/bash

# A very simple init system:
# * run startup items in "${ENV_INIT_DIRECTORY:-/usr/local/etc/init.d}" and "/usr/local/etc/rc.local"
# * executes the executable given in argument, or "apache2-foreground" if none
# 
# This implementation will dump runtime environment variables in "/run/environment" for sub-processes to pick up.
# 
# IMPORTANT: please use "init: true" in docker-compose.yml!

set -eu -o pipefail -o posix
shopt -s failglob
#set -x

ENV_INIT_DIRECTORY=${ENV_INIT_DIRECTORY:-/usr/local/etc/init.d}

export_envvars() {
#	echo "Writing run-time environment variables in /run/environment"
	# read-only filesystem...
	#env | grep -v ... > /etc/environment
	env | grep -v -e 'HOME' -e 'USER' -e 'LOGNAME' -e 'GROUP' -e 'UID' -e 'GID' -e 'SHELL' -e 'PWD' -e 'SHLVL' > /run/environment
	chown nobody /run/environment
	chgrp www-data /run/environment
	chmod 640 /run/environment
}

run_startup_files() {
	# Run ${ENV_INIT_DIRECTORY}/*
#	echo "Running ${ENV_INIT_DIRECTORY}/..."
	[ -d ${ENV_INIT_DIRECTORY} ] && run-parts --report --exit-on-error --lsbsysinit ${ENV_INIT_DIRECTORY}

	# Run /etc/rc.local.
#	echo "Running /etc/rc.local..."
	[ -x /etc/rc.local ] && /etc/rc.local
	[ -x /usr/local/etc/rc.local ] && /usr/local/etc/rc.local
	# Ubuntu 18.04: in case /etc/rc.local does not exist, need a noop to avoid crashing(!)
	:
}

main() {
	# /run/lock is mounted
	if [ "$(id -u)" = "0" ]; then
		chmod a+rwx,+t /run/lock || true
	fi

	export_envvars || true

	run_startup_files

	if [ $# -eq 0 ]; then
#		echo "Starting apache2-foreground..."
		#exec apache2 -D FOREGROUND -k start
		exec apache2-foreground "$@"
	else
#		echo "Running $@..."
		exec "$@"
	fi
}
main "$@"
