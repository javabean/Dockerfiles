#!/bin/dash
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# Converts a Consul health check into a Docker one.

# Consul
# https://learn.hashicorp.com/tutorials/consul/service-registration-health-checks
# https://www.consul.io/docs/discovery/checks#check-scripts
# 
# If the command exits with a non-zero exit code, then the node will be flagged unhealthy.
# The only limitations placed are that the exit codes must obey this convention:
# 
# Exit code 0 - Check is passing
# Exit code 1 - Check is warning
# Any other code - Check is failing (critical)

# Docker
# https://docs.docker.com/engine/reference/builder/#healthcheck
# 
# The command's exit status indicates the health status of the container. The possible values are:
# 
# 0: success - the container is healthy and ready for use
# 1: unhealthy - the container is not working correctly
# 2: reserved - do not use this exit code

if [ -x /usr/local/bin/consul-healthcheck.sh ]; then
	#/usr/local/bin/hc-ping.sh -s -u "${DOCKER_HC_PING_URL:-}"
	result_out=$(/usr/local/bin/consul-healthcheck.sh 2>&1)
	consul_result=$?
	# Keep stdout result for Docker health log (would be better to also keep stderr...)
	echo -n "${result_out}"
	/usr/local/bin/hc-ping.sh -u "${DOCKER_HC_PING_URL:-}" -n $consul_result -l "${result_out}"
	case $consul_result in
	0) exit 0
		;;
	1) exit 1
		;;
	*) exit 1
		;;
	esac
fi

exit 0
