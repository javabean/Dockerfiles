#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

SERVICE_NAME=${SERVICE_NAME:-service}

TIMEOUT=${TIMEOUT:-0}
TIMEOUT_KILL_AFTER=${TIMEOUT_KILL_AFTER:-10}

QUIET=${QUIET:-0}

printUsage() {
	cat << EOT
Usage
    ${0##*/} [-q] [-t timeout [-k kill delay]] [-n service name] [--] command
    Execute a command with an optional time-out.
    If no time-out, the given command will be run until it succeeds (exits 0).
    If time-out, upon time-out expiration SIGTERM (15) is sent to the process.
        If SIGTERM signal is blocked, then the subsequent SIGKILL (9)
        terminates it after -k delay.

    -q quiet
        Do not display anything.

    -t timeout (seconds)
        Number of seconds to wait for command completion.
        Default value: none.

    -k kill delay (seconds)
        Delay between posting the SIGTERM signal and destroying the
        process by SIGKILL.
        Default value: $TIMEOUT_KILL_AFTER seconds.

    -n name
        Name of service to display. Unused if -q specified.

    Some examples of commands:
    * TCP: (echo > /dev/tcp/\$HOST/\$PORT) >/dev/null 2>&1
    * TCP: nc -z -w 1 server port
    * HTTP(S): curl -fsS -o /dev/null http://server:port/
    * MySQL: mysqladmin --silent --no-beep [--wait=3] [--connect_timeout 10] -h \${MYSQL_HOST} -u "\${MYSQL_USER}" -p"\${MYSQL_PASSWORD}" ping
    * Elasticsearch: [ \$(curl -fsS -o /dev/null --write-out %{http_code} http://localhost:9200/_cat/health?h=st) = 200 ]
EOT
}

echoerr() { if [ "$QUIET" -ne 1 ]; then echo "$@" 1>&2; fi }

wait_for() {
	local start_ts=$(date +%s)
	local result=
	until $@; do
		result=$?
		sleep 1
		echoerr -n "."
	done
	local end_ts=$(date +%s)
	echoerr -n " OK ($((end_ts - start_ts)) seconds)"
	return $result
}

wait_for_timeout() {
	# In order to support SIGINT during timeout: http://unix.stackexchange.com/a/57692
	( timeout --kill-after=${TIMEOUT_KILL_AFTER} ${TIMEOUT} sh -e << EOS
		until $@; do sleep 1; if [ "$QUIET" -ne 1 ]; then echo -n "." 1>&2; fi; done
EOS
	) &
	local PID=$!
	trap "kill -INT $PID" INT
	wait $PID
	local result=$?
	if [ $result -ne 0 ]; then
		echoerr -n " error or timeout after waiting for ${TIMEOUT} seconds (return value $result)"
	fi
	return $result
}

main() {
	# Options
	while getopts "t:k:n:q" option; do
		case "$option" in
			t) TIMEOUT="$OPTARG" ;;
			k) TIMEOUT_KILL_AFTER="$OPTARG" ;;
			n) SERVICE_NAME="$OPTARG" ;;
			q) QUIET=1 ;;
			*) printUsage; exit 1 ;;
		esac
	done
	shift $((OPTIND - 1))  # Shift off the options and optional --
	
	# $# should be at least 1 (the command to execute), however it may be strictly
	# greater than 1 if the command itself has options.
	if [ $# -eq 0 ]; then
		printUsage
		exit 1
	fi

	if [ "${TIMEOUT}" -gt 0 ]; then
		echoerr -n "Waiting ${TIMEOUT} seconds for ${SERVICE_NAME}..."
		wait_for_timeout "$@"
	else
		echoerr -n "Waiting for ${SERVICE_NAME}..."
		wait_for "$@"
	fi
	local result=$?
	echoerr
	exit $result
}
main "$@"

