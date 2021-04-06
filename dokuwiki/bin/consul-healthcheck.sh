#!/bin/sh
#set -e
set -u
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# apache2 process
num_processes=`pgrep -cx apache2`
if [ "$num_processes" -eq 0 ]; then
	echo "No apache2 process!"
	exit 2
fi

curl -fsS -o /dev/null --connect-timeout 1 --max-time 10 http://localhost/lib/tpl/dokuwiki/images/favicon.ico || exit 2

exit 0
