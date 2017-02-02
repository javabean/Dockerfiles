#!/bin/sh

# ziproxy process
#num_processes=`pgrep -cx ziproxy`
num_processes=`pgrep -cF /var/run/ziproxy.pid`
if [ "$num_processes" -eq 0 ]; then
	echo "No ziproxy process!"
	exit 2
fi

exit 0
