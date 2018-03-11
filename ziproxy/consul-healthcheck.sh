#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# ziproxy process
#num_processes=`pgrep -cx ziproxy`
num_processes=`pgrep -cF /var/run/ziproxy.pid`
if [ "$num_processes" -eq 0 ]; then
	echo "No ziproxy process!"
	exit 2
fi

exit 0
