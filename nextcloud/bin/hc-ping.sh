#!/usr/bin/env dash
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

printUsage() {
	cat << EOT
Usage
    ${0##*/} [-s|-c] -u healthcheck_url [-n status] [-l command_output]
    Client for https://healthchecks.io/
    To signal a job start, use:
        ${0##*/} -s -u <healthcheck_url>
    Note: the job then must signal a success or failure within its configured "Grace Time", or it will get marked as "down".
    To signal a job completion, use:
        ${0##*/} [-c] -u <healthcheck_url> [-n status] [-l command_output]

    -s start
        Signal the start of a job. Mutually exclusive with -c.
        Only the healthcheck url is required; status and log will be silently ignored.

    -c complete
        Signal a job completion. Mutually exclusive with -s.
        Default value if neither -s or -c is specified.

    -u healthcheck URL
        This utility will silently abort (NOOP) if URL is empty.

    -n status (integer)
        0 is success
        any other value is failure
        Default value: 0

    -l command_output (UTF-8)
        Log a command output in the completion healthcheck ping.
       	Healthchecks.io will accept and store the first 10KB, so you can inspect it later.

    Examples:
    * ${0##*/} -s -u "\${HC_PING_URL}"
    * result_out=\$(do_some_work 2>&1) ; ${0##*/} -c -u "\${HC_PING_URL}" -n \$? -l "\${result_out}"
EOT
}

CURL_OPTS="-fsS -X POST --retry 3 --max-time 5 --retry-delay 1"

hc_ping_start() {
	local HC_PING_URL="$1"
	if [ -n "${HC_PING_URL}" ]; then
		# shellcheck disable=SC2086
		curl ${CURL_OPTS} "${HC_PING_URL}"/start > /dev/null || true
	fi
}
# e.g.: result_out=$(do_some_work 2>&1) ; hc_ping_status "${HC_PING_URL}" $? "${result_out}"
hc_ping_status() {
	local HC_PING_URL="$1"
	# 0 for success or any other value for fail
	local HC_STATUS="${2:-0}"
	# You can put extra diagnostic information in the request body.
	# If the request body looks like a valid UTF-8 string, Healthchecks.io will accept and store the first 10KB of the request body, so you can inspect it later.
	local HC_PAYLOAD="${3:-}"
	if [ -n "${HC_PING_URL}" ]; then
		if [ "${HC_STATUS}" -ne 0 ]; then HC_PING_URL="${HC_PING_URL}"/fail; fi
		if [ -n "${HC_PAYLOAD}" ]; then
			# shellcheck disable=SC2086
			curl ${CURL_OPTS} --data-raw "${HC_PAYLOAD}" "${HC_PING_URL}" > /dev/null || true
		else
			# shellcheck disable=SC2086
			curl ${CURL_OPTS} "${HC_PING_URL}" > /dev/null || true
		fi
	fi
}

main() {
	START=
	COMPLETION=
	HC_PING_URL=
	STATUS=
	LOG_MESSAGE=
	# Options
	while getopts "scu:n:l:" option; do
		case "$option" in
			s) START=1 ;;
			c) COMPLETION=1 ;;
			u) HC_PING_URL="$OPTARG" ;;
			n) STATUS="$OPTARG" ;;
			l) LOG_MESSAGE="$OPTARG" ;;
			*) printUsage; exit 1 ;;
		esac
	done
	shift $((OPTIND - 1))  # Shift off the options and optional --
	
	# $# should be at least 0 (no other parameters)
	if [ $# -gt 0 ]; then
		printUsage
		exit 1
	fi

	# Either -s xor -c, default to -c
	if [ -n "${START}" ] && [ -n "${COMPLETION}" ]; then
		printUsage
		exit 1
	fi
	if [ -z "${START}" ] && [ -z "${COMPLETION}" ]; then
		COMPLETION=1
	fi

	if [ -n "${START}" ]; then
		hc_ping_start "${HC_PING_URL}"
	else
		hc_ping_status "${HC_PING_URL}" "${STATUS}" "${LOG_MESSAGE}"
	fi
	local result=$?
	exit $result
}
main "$@"
