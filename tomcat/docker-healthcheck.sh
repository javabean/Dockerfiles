#!/bin/sh
#set -e
set -u
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# Docker health check
# https://docs.docker.com/engine/reference/builder/#healthcheck
# 
# The command's exit status indicates the health status of the container. The possible values are:
# 
# 0: success - the container is healthy and ready for use
# 1: unhealthy - the container is not working correctly
# 2: reserved - do not use this exit code


# java process
num_processes=`pgrep -cx java`
if [ "$num_processes" -eq 0 ]; then
	echo "No java process!"
	exit 1
fi

curl -fsS -o /dev/null http://localhost:8080 || exit 1

exit 0
