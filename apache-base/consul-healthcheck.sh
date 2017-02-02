#!/bin/sh

# apache2 process
num_processes=`pgrep -cx apache2`
if [ "$num_processes" -eq 0 ]; then
	echo "No apache2 process!"
	exit 2
fi

curl -fsS -o /dev/null http://localhost || exit 2

exit 0
