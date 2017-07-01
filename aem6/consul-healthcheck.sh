#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# java process
num_processes=`pgrep -cx java`
#num_processes=`pgrep -cF "$CQ_QUICKSTART/conf/cq.pid"`
if [ "$num_processes" -eq 0 ]; then
	echo "No java process!"
	exit 2
fi

[ -s /run/environment ] && . /run/environment
[ -r /usr/local/etc/aem6 ] && . /usr/local/etc/aem6

curl -fsS -o /dev/null -A "Mozilla/5.0 Gecko/20100101 Firefox/99.0" http://localhost:${CQ_PORT} || exit 2

exit 0
