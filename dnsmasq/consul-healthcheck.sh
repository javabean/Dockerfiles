#!/bin/sh
#set -e
set -u
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# dnsmasq process
num_processes=`pgrep -cx dnsmasq`
if [ "$num_processes" -eq 0 ]; then
	echo "No dnsmasq process!"
	exit 2
fi

exit 0
