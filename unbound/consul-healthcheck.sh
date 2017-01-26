#!/bin/sh

# unbound process
num_processes=`pgrep -cx unbound`
if [ "$num_processes" -eq 0 ]; then
	echo "No unbound process!"
	return 2
fi

# unbound status
# Exit code 3 if not running (the  connection to the port is refused), 1 on error, 0 if running.
unbound-control -c /etc/unbound/unbound.conf -s 127.0.0.1 -q status

exit $?
