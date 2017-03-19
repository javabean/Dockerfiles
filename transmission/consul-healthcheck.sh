#!/bin/sh

# transmission-daemon process
# pgrep: The process name used for matching is limited to the 15 characters present in the output of /proc/pid/stat
num_processes=`pgrep -cx transmission-da`
if [ "$num_processes" -eq 0 ]; then
	echo "No transmission-daemon process!"
	exit 2
fi

curl -fsS -o /dev/null http://localhost:9091 || exit 2

exit 0
