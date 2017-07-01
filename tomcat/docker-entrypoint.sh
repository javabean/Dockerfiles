#!/bin/bash
set -eu -o pipefail -o posix
shopt -s failglob
#set -x

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' -o "$1" = "debug" -o "$1" = "jpda" -o "$1" = "run" -o "$1" = "start" -o "$1" = "stop" -o "$1" = "configtest" -o "$1" = "version" ]; then
    set -- "$CATALINA_HOME/bin/catalina.sh" "$@"
fi

# check for the expected command
if [ "$1" = "$CATALINA_HOME/bin/catalina.sh" ]; then
	if [ -x /usr/bin/authbind ]; then
		exec /usr/bin/authbind --deep gosu tomcat "$@" >> "$CATALINA_BASE/logs/catalina.out" 2>&1
	else
		exec gosu tomcat "$@" >> "$CATALINA_BASE/logs/catalina.out" 2>&1
	fi
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

