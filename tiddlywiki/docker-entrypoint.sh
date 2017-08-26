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

# check for the expected command
if [ "$1" = "tiddlywiki" ]; then
	WIKI_FOLDER=${WIKI_FOLDER:-wiki}
	PORT=${PORT:-8080}
	ROOT_TIDDLER=${ROOT_TIDDLER:-'$:/core/save/all'}
	RENDER_TYPE=${RENDER_TYPE:-"text/plain"}
	SERVE_TYPE=${SERVE_TYPE:-"text/html"}
	USERNAME=${USERNAME:-}
	PASSWORD=${PASSWORD:-}
	PATH_PREFIX=${PATH_PREFIX:-}

	# if [ ! "$(ls -A "${d}")" ]; then
	if ! ls -A /srv/${WIKI_FOLDER} > /dev/null 2>&1; then
		echo "Creating new wiki: \"${WIKI_FOLDER}\""
		gosu www-data tiddlywiki /srv/${WIKI_FOLDER} --init server
	fi

	# http://tiddlywiki.com/static/ServerCommand.html
	# tiddlywiki --server <port> <roottiddler> <rendertype> <servetype> <username> <password> <host> <pathprefix>
	exec gosu www-data "$@" /srv/${WIKI_FOLDER} --server ${PORT} "${ROOT_TIDDLER}" "${RENDER_TYPE}" "${SERVE_TYPE}" "${USERNAME}" "${PASSWORD}" "0.0.0.0" "${PATH_PREFIX}"
fi

# else default to run whatever the user wanted like "bash"
exec "$@"

