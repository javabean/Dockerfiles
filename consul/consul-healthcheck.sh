#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# consul process
num_processes=`pgrep -cx consul`
if [ "$num_processes" -eq 0 ]; then
	echo "No consul process!"
	exit 2
fi

curl -fsS -o /dev/null http://localhost:8500 || exit 2

exit 0
