#!/bin/sh
#set -e
set -u
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# opendkim process
#num_processes=`pgrep -cx opendkim`
num_processes=`pgrep -cF /var/run/opendkim/opendkim.pid`
if [ "$num_processes" -eq 0 ]; then
	echo "No opendkim process!"
	exit 2
fi

exit 0
