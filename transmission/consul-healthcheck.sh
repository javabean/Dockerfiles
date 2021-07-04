#!/bin/sh
#set -e
set -u
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# transmission-daemon process
# pgrep: The process name used for matching is limited to the 15 characters present in the output of /proc/pid/stat
num_processes=`pgrep -cx transmission-da`
if [ "$num_processes" -eq 0 ]; then
	echo "No transmission-daemon process!"
	exit 2
fi

# shellcheck disable=SC2086
curl -fsS -o /dev/null ${HC_CURL_TRANSMISSION_CREDENTIALS} http://localhost:9091/transmission/web/javascript/main.js || exit 2

exit 0
