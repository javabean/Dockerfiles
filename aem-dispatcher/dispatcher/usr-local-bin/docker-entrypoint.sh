#!/bin/sh
set -u
set -e
#set -o pipefail -o posix
#shopt -s failglob
#set -x


set_aem_endpoint() {
	. /usr/local/bin/httpd-environment.sh
	local DISPATCHER_ANY="${HTTPD_CONF_D}"/inc-renders.any
	local reset_e=0 ; internal_is_shell_attribute_set "e" && set +e && reset_e=1
	set +e
	if [ ! -f "$DISPATCHER_ANY" ] || ! grep -q "/hostname " "$DISPATCHER_ANY"; then DISPATCHER_ANY="${HTTPD_CONF_D}"/dispatcher.any; fi
	[ "$reset_e" -eq 1 ] && set -e
	sed -i --follow-symlinks -e "s%/hostname \".*\"%/hostname \"${AEM_ENDPOINT}\"%" \
		"$DISPATCHER_ANY"
}

# check for the expected command
if [ "${1:-}" = 'httpd-foreground' ]; then

	if [ -n "${AEM_ENDPOINT:-}" ]; then
		echo "Setting AEM endpoint to: ${AEM_ENDPOINT}"
		set_aem_endpoint
	fi

	# If publish, execute dispatcher-add-domain.sh with user-defined data

	if [ -n "${DISPATCHER_ADD_DOMAIN:-}" ]; then
		echo "${DISPATCHER_ADD_DOMAIN}" | tr "|" "\n" | while IFS=$'\n' read -r DAD_OPTS; do
			echo "Executing: dispatcher-add-domain.sh ${DAD_OPTS}"
			# shellcheck disable=SC2086
			/usr/local/bin/dispatcher-add-domain.sh ${DAD_OPTS}
		done
	fi

fi

# else default to run whatever the user wanted like "bash"
exec "$@"
