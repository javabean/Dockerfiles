#!/bin/dash
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# httpd process
num_processes=`pgrep -cx apache2`
if [ "$num_processes" -eq 0 ]; then
	echo "No httpd process!"
	exit 2
fi

[ -s /etc/environment ] && . /etc/environment
[ -r /usr/local/bin/httpd-environment.sh ] && . /usr/local/bin/httpd-environment.sh

#bash -c "</dev/tcp/127.0.0.1/80" || exit 1
curl -fsS -o /dev/null --connect-timeout 1 --max-time 5 http://localhost/wp-includes/wlwmanifest.xml 2>&1
curl_result=$?

exit $curl_result
