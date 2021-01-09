#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# copy backup of conf dirs if mounted volume is empty

if [ -z "$(ls -AUq -- "/var/www/" 2> /dev/null)" ]; then
	cp -a /var/www.bak/. /var/www/
fi
