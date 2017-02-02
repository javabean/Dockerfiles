#!/bin/sh

# opendkim process
#num_processes=`pgrep -cx opendkim`
num_processes=`pgrep -cF /var/run/opendkim/opendkim.pid`
if [ "$num_processes" -eq 0 ]; then
	echo "No opendkim process!"
	exit 2
fi

exit 0
