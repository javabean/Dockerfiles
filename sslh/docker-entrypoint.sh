#!/bin/bash
set -eu -o pipefail -o posix
shopt -s failglob
#set -x

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- "sslh-select" "$@"
fi

# check for the expected command
if [ "$1" = "sslh" ] || [ "$1" = "sslh-select" ]; then
	# --transparent needs firewall support when proxying to lo; doesn't work with external hosts
	# To support OpenVPN connexions reliably, it is necessary to increase sslh’s timeout to 5 seconds
	exec "$@" -f -u sslh -t "${SSLH_TIMEOUT:-1}" -p 0.0.0.0:443
fi

# else default to run whatever the user wanted like "bash"
exec "$@"
