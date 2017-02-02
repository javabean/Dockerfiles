#!/bin/sh

# java process
num_processes=`pgrep -cx java`
if [ "$num_processes" -eq 0 ]; then
	echo "No java process!"
	exit 2
fi

curl -fsS -o /dev/null http://localhost:8080 || exit 2

exit 0
