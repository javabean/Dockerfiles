#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# dovecot process
num_processes=`pgrep -cx dovecot`
if [ "$num_processes" -eq 0 ]; then
	echo "No dovecot process!"
	exit 2
fi

exit 0
