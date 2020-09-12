#!/bin/sh
set -e
set -u
#(set -o | grep -q pipefail) && set -o pipefail
#(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# Checks if a new RewriteMap is available on AEM author, and if so update Apache httpd's RewriteMap with the new version.

##############################################################################

print_usage() {
	cat << EOT
Usage
    ${0##*/} -d <domain>] -u <author acs commons rewrite map url>
    Update Apache httpd RewriteMap rules from AEM author with the following options:
    -d domain
    -u url where this script will fetch the RewriteMap
    -c credentials to fetch url
    E.g.: ${0##*/} -d example.com -c admin:admin -u http://author.example:4502/etc/acs-commons/redirect-maps/\${MAP_FILE}/jcr:content.redirectmap.txt
EOT
}

##############################################################################

main() {
	local PRIMARY_DOMAIN=
	local REWRITE_MAP_URL=
	local REWRITE_MAP_URL_CREDENTIALS=

	# Options
	while getopts "d:u:c:" option; do
		case "$option" in
			d) PRIMARY_DOMAIN="$OPTARG" ;;
			u) REWRITE_MAP_URL="$OPTARG" ;;
			c) REWRITE_MAP_URL_CREDENTIALS="$OPTARG" ;;
			*) print_usage; exit 1 ;;
		esac
	done
	shift $((OPTIND - 1))  # Shift off the options and optional --
	
	# Require both domain name and URL
	if [ -z "$PRIMARY_DOMAIN" ] || [ -z "$REWRITE_MAP_URL" ]; then
		print_usage
		exit 1
	fi
	
	# $# should be at least 1 (the command to execute), however it may be strictly
	# greater than 1 if the command itself has options.
	#if [ $# -eq 0 ]; then
	#	print_usage
	#	exit 1
	#fi

	. /usr/local/bin/httpd-environment.sh

	if [ -n "$REWRITE_MAP_URL_CREDENTIALS" ]; then
		REWRITE_MAP_URL_CREDENTIALS="-u $REWRITE_MAP_URL_CREDENTIALS"
	fi

	rm -f /tmp/farm_"${PRIMARY_DOMAIN}".txt
	# shellcheck disable=SC2086
	curl -fsSLRo /tmp/farm_"${PRIMARY_DOMAIN}".txt $REWRITE_MAP_URL_CREDENTIALS "${REWRITE_MAP_URL}"
	set +e
	if ! diff -q /tmp/farm_"${PRIMARY_DOMAIN}".txt "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".txt; then
		set -e
		mv /tmp/farm_"${PRIMARY_DOMAIN}".txt "${HTTPD_CONF}"/
		# httxt2dbm: If the output file already exists, it will not be truncated. New keys will be added and existing keys will be updated.
		# The looked-up keys are cached by httpd until the mtime (modified time) of the mapfile changes, or the httpd server is restarted.
		# We thus need to truncate the database file first.
		> "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".dbm.dir
		> "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".dbm.pag
		httxt2dbm -i "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".txt -o "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".dbm
		chmod a+r "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".*
		chown "${HTTPD_USER}": "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".*
	else
		set -e
		rm -f /tmp/farm_"${PRIMARY_DOMAIN}".txt
	fi
}
main "$@"
