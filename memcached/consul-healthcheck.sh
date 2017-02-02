#!/bin/sh

# memcached process
num_processes=`pgrep -cx memcached`
if [ "$num_processes" -eq 0 ]; then
	echo "No memcached process!"
	exit 2
fi

exit 0
