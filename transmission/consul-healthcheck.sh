#!/bin/sh

# transmission-daemon process
num_processes=`pgrep -cx transmission-daemon`
if [ "$num_processes" -eq 0 ]; then
	echo "No transmission-daemon process!"
	exit 2
fi

curl -fsS -o /dev/null http://localhost:9091 || exit 2

exit 0
