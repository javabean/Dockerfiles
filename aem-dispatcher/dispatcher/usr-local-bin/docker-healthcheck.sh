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


## httpd process
#num_processes=`pgrep -cx httpd`
#if [ "$num_processes" -eq 0 ]; then
#	echo "No httpd process!"
#	exit 1
#fi

[ -s /etc/environment ] && . /etc/environment
[ -r /usr/local/bin/httpd-environment.sh ] && . /usr/local/bin/httpd-environment.sh

#bash -c "</dev/tcp/127.0.0.1/80" || exit 1
# Beware Dispatcher may filter out http://localhost:80/libs/granite/core/content/login.nocache.html
curl -sS -o /dev/null --connect-timeout 1 --max-time 10 -A "Mozilla/5.0 Gecko/20100101 Firefox/99.0" http://localhost:80"${HEALTHCHECK_PATH:-/libs/granite/core/content/login.nocache.html}" || exit 1

exit 0
