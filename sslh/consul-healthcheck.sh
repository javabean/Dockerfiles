#!/bin/sh
#set -e
set -u
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# sslh process
num_processes_fork1=$(pgrep -cx sslh)
num_processes_fork2=$(pgrep -cx sslh-fork)
num_processes_select=$(pgrep -cx sslh-select)
num_processes=$(expr $num_processes_fork1 + $num_processes_fork2 + $num_processes_select)
if [ "$num_processes" -eq 0 ]; then
	echo "No sslh process!"
	exit 2
fi

exit 0
