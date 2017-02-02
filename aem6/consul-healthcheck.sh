#!/bin/sh

# java process
num_processes=`pgrep -cx java`
#num_processes=`pgrep -cF "$CQ_QUICKSTART/conf/cq.pid"`
if [ "$num_processes" -eq 0 ]; then
	echo "No java process!"
	exit 2
fi

exit 0
