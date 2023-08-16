#!/bin/sh
set -e
set -u
#(set -o | grep -q pipefail) && set -o pipefail
#(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# http://httpd.apache.org/docs/2.4/programs/rotatelogs.html

# If given, rotatelogs will execute the specified program every time a new log file is opened.
# The filename of the newly opened file is passed as the first argument to the program.
# If executing after a rotation, the old log file is passed as the second argument.
# rotatelogs does not wait for the specified program to terminate before continuing to operate, and will not log any error code returned on termination.
# The spawned program uses the same stdin, stdout, and stderr as rotatelogs itself, and also inherits the environment.

main() {
	if [ $# -eq 0 ]; then
		echo "This script should only be called by rotatelogs"
		exit 1
	fi

	local newly_opened_file="${1}"
	local old_log_file="${2:-}"
	local LOG_RETENTION_DAYS=${LOG_RETENTION_DAYS:-366}
	local compress_exit_code=0

	if [ -s "${old_log_file}" ]; then
		if [ -x "$(command -v pzstd)" ]; then
			pzstd -q --rm "${old_log_file}"
		elif [ -x "$(command -v zstd)" ]; then
			zstd -q --rm --rsyncable -T0 --adapt --exclude-compressed "${old_log_file}"
		elif [ -x "$(command -v pigz)" ]; then
			pigz --rsyncable "${old_log_file}"
		elif [ -x "$(command -v lz4)" ]; then
			lz4 -q --rm "${old_log_file}"
		elif [ -x "$(command -v gzip)" ]; then
			gzip -q -3 "${old_log_file}"
		elif [ -x "$(command -v xz)" ]; then
			xz -q -2 -T0 --memlimit-compress=50% "${old_log_file}"
		elif [ -x "$(command -v bzip2)" ]; then
			bzip2 -q "${old_log_file}"
		fi
		compress_exit_code=${?}
	fi

	find "$(dirname "${newly_opened_file}")" -type f -mtime +"${LOG_RETENTION_DAYS}" '(' \
		-name '*.lz4' -or -name '*.gz' -or -name '*.bz2' -or -name '*.xz' -or -name '*.zst' \
		')' -delete

	exit ${compress_exit_code}
}
main "$@"
