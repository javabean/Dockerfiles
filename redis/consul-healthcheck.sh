#!/bin/sh

# redis-server process
num_processes=`pgrep -cx redis-server`
if [ "$num_processes" -eq 0 ]; then
	echo "No redis-server process!"
	exit 2
fi

ping="$(redis-cli --raw ping)" && [ "$ping" = 'PONG' ] || exit 2

exit 0
