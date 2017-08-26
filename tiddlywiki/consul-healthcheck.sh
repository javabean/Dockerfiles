#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# node process
num_processes=`pgrep -cx node`
if [ "$num_processes" -eq 0 ]; then
	echo "No node process!"
	exit 2
fi

curl -fsS -o /dev/null http://localhost:8080 || exit 2

exit 0
