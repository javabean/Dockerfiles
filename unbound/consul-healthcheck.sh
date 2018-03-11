#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# unbound process
num_processes=`pgrep -cx unbound`
if [ "$num_processes" -eq 0 ]; then
	echo "No unbound process!"
	exit 2
fi

# unbound status
# Exit code 3 if not running (the  connection to the port is refused), 1 on error, 0 if running.
unbound-control -c /etc/unbound/unbound.conf -s 127.0.0.1 -q status

exit $?
