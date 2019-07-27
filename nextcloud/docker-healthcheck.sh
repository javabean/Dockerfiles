#!/bin/sh
set -eu
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


# httpd process
num_processes=`pgrep -cx apache2`
if [ "$num_processes" -eq 0 ]; then
	echo "No httpd process!"
	exit 1
fi

[ -s /etc/environment ] && . /etc/environment
[ -r /usr/local/bin/httpd-environment.sh ] && . /usr/local/bin/httpd-environment.sh

#bash -c "</dev/tcp/127.0.0.1/80" || exit 1
curl -fsS -o /dev/null --connect-timeout 1 --max-time 5 http://localhost:80/status.php || exit 1

exit 0
