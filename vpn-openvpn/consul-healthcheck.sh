#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# openvpn process
#num_processes=`pgrep -cx openvpn`
num_processes=`pgrep -cF /run/openvpn/server.pid`
if [ "$num_processes" -eq 0 ]; then
	echo "No openvpn process!"
	exit 2
fi

exit 0
