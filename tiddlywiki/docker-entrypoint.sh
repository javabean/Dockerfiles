#!/bin/bash
set -eu -o pipefail -o posix
shopt -s failglob
#set -x

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- "tiddlywiki" "$@"
fi

# https://tiddlywiki.com/static/WebServer.html

# check for the expected command
if [ "$1" = "tiddlywiki" ]; then
	# https://tiddlywiki.com/static/WebServer%2520Parameters.html
	# See also https://tiddlywiki.com/static/Environment%2520Variables%2520on%2520Node.js.html
	WIKI_FOLDER="${WIKI_FOLDER:-wiki}"
	PATH_PREFIX="${PATH_PREFIX:-}"
	PORT="${PORT:-8080}"
	CREDENTIALS="${CREDENTIALS:-}"
	ANON_USERNAME="${ANON_USERNAME:-}"
	USERNAME="${USERNAME:-}"
	PASSWORD="${PASSWORD:-}"
	AUTHENTICATED_USER_HEADER="${AUTHENTICATED_USER_HEADER:-}"
	READERS="${READERS:-(anon)}"
	WRITERS="${WRITERS:-(authenticated)}"
	CSRF_DISABLE="${CSRF_DISABLE:-no}"
	ROOT_TIDDLER=${ROOT_TIDDLER:-'$:/core/save/all'}
	ROOT_RENDER_TYPE="${ROOT_RENDER_TYPE:-text/plain}"
	ROOT_SERVE_TYPE="${ROOT_SERVE_TYPE:-text/html}"
	TLS_CERT="${TLS_CERT:-}"
	TLS_KEY="${TLS_KEY:-}"
	DEBUG_LEVEL="${DEBUG_LEVEL:-none}"

	# if [ ! "$(ls -U "${d}")" ]; then
	if ! ls -U /srv/"${WIKI_FOLDER}" > /dev/null 2>&1; then
		echo "Creating new wiki: \"${WIKI_FOLDER}\""
		tiddlywiki /srv/"${WIKI_FOLDER}" --init server
		# https://tiddlywiki.com/static/Using%2520the%2520integrated%2520static%2520file%2520server.html
		mkdir /srv/"${WIKI_FOLDER}"/files
	fi

	# https://tiddlywiki.com/static/ListenCommand.html
	"$@" /srv/"${WIKI_FOLDER}" --listen host=0.0.0.0 path-prefix="${PATH_PREFIX}" port="${PORT}" credentials="${CREDENTIALS}" anon-username="${ANON_USERNAME}" username="${USERNAME}" password="${PASSWORD}" authenticated-user-header="${AUTHENTICATED_USER_HEADER}" readers="${READERS}" writers="${WRITERS}" csrf-disable="${CSRF_DISABLE}" root-tiddler="${ROOT_TIDDLER}" root-render-type="${ROOT_RENDER_TYPE}" root-serve-type="${ROOT_SERVE_TYPE}" tls-cert="${TLS_CERT}" tls-key="${TLS_KEY}" debug-level="${DEBUG_LEVEL}"
fi

# else default to run whatever the user wanted like "bash"
exec "$@"
