#!/bin/bash
# Bash needed to use arrays
set -u
set -e -o pipefail -o posix
#shopt -s failglob
#set -x

# Configures a new (set of) domain in dispatcher instance on RedHat | CentOS 7
# 
# For all set of domains (tenant), you will need to:
# * create `/etc/map` configuration on AEM instances (author + publish)
#   [AEM documentation](https://helpx.adobe.com/experience-manager/6-4/sites/deploying/using/resource-mapping.html)
#   [Sling documentation](https://sling.apache.org/documentation/the-sling-engine/mappings-for-resource-resolution.html)
# * create ACS Commons RewriteMap configuration page (`/miscadmin#/etc/acs-commons/redirect-maps`) (see `https://adobe-consulting-services.github.io/acs-aem-commons/features/redirect-map-manager/index.html`)
# * use this script on each publish dispatcher instance
# 
# This script will:
# * create an Apache httpd virtual host associated with given domain(s) (`/etc/httpd/conf.d/farm_${PRIMARY_DOMAIN}.conf`)
# * configure AEM dispatcher for this (those) domain(s) (`/etc/httpd/conf.d/*${PRIMARY_DOMAIN}.any`)
# * add a `root` cron job to update RewriteMap rules from author instance (`/etc/httpd/conf/farm_${PRIMARY_DOMAIN}.*`)
# 
# Implementation notes:
# 
# While we would like to automate creating `/etc/map` and AEM Commons configuration, this is made difficult since we don't know:
# * author IP (from publish dispatcher instance, to fetch updated RewriteMap files)
# * author admin credentials
# * publish admin credentials
# this is somehow mitigated by the knowledge of the associated instance IP (either publish in `inc-renders.any` or author in `dispatcher.any`), but without the credentials (except when dispatcher runs on the same server as AEM).
# 
# Reference: https://helpx.adobe.com/experience-manager/dispatcher/using/dispatcher-domains.html


##############################################################################

httpd_virtualhost_install() {
	local HTTPD_HTDOCS=$1
	local JCR_CONTENT_NODE_NAME=$2
	shift 2
	local DOMAINS=( "$@" )
	local PRIMARY_DOMAIN="${DOMAINS[0]}"
	# Compute ServerAlias directive
	local CONF_SERVER_ALIAS=
	for domain in "${DOMAINS[@]}"; do
		if [ "$domain" != "$PRIMARY_DOMAIN" ]; then
			if [ -z "$CONF_SERVER_ALIAS" ]; then
				CONF_SERVER_ALIAS="$domain"
			else
				CONF_SERVER_ALIAS="$CONF_SERVER_ALIAS $domain"
			fi
		fi
	done
	mkdir -p "${HTTPD_HTDOCS}/content/${JCR_CONTENT_NODE_NAME}"
	chown "${HTTPD_USER}": "${HTTPD_HTDOCS}/content" "${HTTPD_HTDOCS}/content/${JCR_CONTENT_NODE_NAME}"
	chmod a+rX "${HTTPD_HTDOCS}/content" "${HTTPD_HTDOCS}/content/${JCR_CONTENT_NODE_NAME}"
	cp -a "${HTTPD_CONF_D}"/farm-default.conf "${HTTPD_CONF_D}"/farm_"${PRIMARY_DOMAIN}".conf
	sed -i --follow-symlinks \
		-e "s%#ServerName .*%ServerName ${PRIMARY_DOMAIN}%" \
		-e "s%DocumentRoot \"\(.*\)\"%DocumentRoot \"\1/content/${JCR_CONTENT_NODE_NAME}\"%" \
		-e "s%<Directory \(.*\)>%<Directory \1/content/${JCR_CONTENT_NODE_NAME}>%" \
		-e "s%ErrorLog \"\${httpd_logs}/error_log\"%ErrorLog \"\${httpd_logs}/${PRIMARY_DOMAIN}_error_log\"%" \
		-e "s%CustomLog \"\${httpd_logs}/access_log\" \(.*\)%CustomLog \"\${httpd_logs}/${PRIMARY_DOMAIN}_access_log\" \1%" \
		"${HTTPD_CONF_D}"/farm_"${PRIMARY_DOMAIN}".conf
	if [ -n "$CONF_SERVER_ALIAS" ]; then
		sed -i --follow-symlinks \
			-e "s%#ServerAlias .*%ServerAlias ${CONF_SERVER_ALIAS}%" \
			"${HTTPD_CONF_D}"/farm_"${PRIMARY_DOMAIN}".conf
	fi
}

dispatcher_configure() {
	local JCR_CONTENT_NODE_NAME=$1
	shift
	local DOMAINS=( "$@" )
	local PRIMARY_DOMAIN="${DOMAINS[0]}"
	# The [dispatcher farm name] value can have include any alphanumeric (a-z, 0-9) character
	local DISPATCHER_FARM_NAME=$(echo "${PRIMARY_DOMAIN}"|tr -d -c "[:alnum:]")
	# Compute /virtualhosts directive
	local CONF_SERVER_NAMES=
	for domain in "${DOMAINS[@]}"; do
		if [ -z "$CONF_SERVER_NAMES" ]; then
			CONF_SERVER_NAMES="\"$domain\"\n"
		else
			CONF_SERVER_NAMES="$CONF_SERVER_NAMES\t\"$domain\"\n"
		fi
	done
	cp -a "${HTTPD_CONF_D}"/inc-virtualhosts.any   "${HTTPD_CONF_D}"/inc-virtualhosts_"${PRIMARY_DOMAIN}".any
	cp -a "${HTTPD_CONF_D}"/inc-cache.any          "${HTTPD_CONF_D}"/inc-cache_"${PRIMARY_DOMAIN}".any
	cp -a "${HTTPD_CONF_D}"/farm-unit.any.template "${HTTPD_CONF_D}"/farm_"${PRIMARY_DOMAIN}".any
	# ToDo also change inc-vanity_urls.any
	sed -i --follow-symlinks \
		-e "s%Cache invalidation farm entry%Farm entry: ${PRIMARY_DOMAIN}%" \
		-e "s%/website%/${DISPATCHER_FARM_NAME}%" \
		-e "s%inc-virtualhosts.any%inc-virtualhosts_${PRIMARY_DOMAIN}.any%" \
		-e "s%inc-cache.any%inc-cache_${PRIMARY_DOMAIN}.any%" \
		"${HTTPD_CONF_D}"/farm_"${PRIMARY_DOMAIN}".any
	# FIXME: 2: compute from original value (minus 2), e.g. 4-2=2
	sed -i --follow-symlinks --regexp-extended \
		-e "s%/docroot \"(.*)\"%/docroot \"\1/content/${JCR_CONTENT_NODE_NAME}\"%" \
		-e "s%/statfileslevel .*%/statfileslevel \"2\"%" \
		"${HTTPD_CONF_D}"/inc-cache_"${PRIMARY_DOMAIN}".any
	sed -i --follow-symlinks \
		-e "s%\"\\*\"%${CONF_SERVER_NAMES}%" \
		"${HTTPD_CONF_D}"/inc-virtualhosts_"${PRIMARY_DOMAIN}".any
}

httpd_rewritemap_configure() {
	local PRIMARY_DOMAIN=$1
	touch "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".txt
	httxt2dbm -i "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".txt -o "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".dbm
	chown "${HTTPD_USER}": "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".*
	chmod a+r "${HTTPD_CONF}"/farm_"${PRIMARY_DOMAIN}".*
	sed -i --follow-symlinks --regexp-extended \
		-e "s%#RewriteMap ([^ ]*) \".*%RewriteMap \1 \"dbm:${HTTPD_CONF}/farm_${PRIMARY_DOMAIN}.dbm\"%" \
		-e "s%#RewriteRule (.*)%RewriteRule \1%" \
		"${HTTPD_CONF_D}"/farm_"${PRIMARY_DOMAIN}".conf
}

cron_rewritemap_create() {
	local SCRIPTS_HOME=$1
	local PRIMARY_DOMAIN=$2
	local REWRITE_MAP_URL=$3
	local REWRITE_MAP_URL_CREDENTIALS=${4:-}
	if [ -n "$REWRITE_MAP_URL_CREDENTIALS" ]; then
		REWRITE_MAP_URL_CREDENTIALS="-c $REWRITE_MAP_URL_CREDENTIALS"
	fi
	cron_add "/httpd-rewritemap-update.sh -d $PRIMARY_DOMAIN " \
		"${SCRIPTS_HOME}/httpd-rewritemap-update.sh -d $PRIMARY_DOMAIN $REWRITE_MAP_URL_CREDENTIALS -u $REWRITE_MAP_URL > /dev/null 2>&1"
}

##############################################################################

print_usage() {
	cat << EOT
Configures a new (set of) domain in Apache httpd + AEM dispatcher
Usage
    ${0##*/} -n <base AEM node name> -d <domain> -d <domain> ... [-r <rewrite_map_url_author>]
    -n base AEM node name: JCR node name under which the AEM site resides; e.g. "mysite" for node /content/mysite
    -d domain; 1st will be the main one (other ones are aliases)
    -r URL of RewriteMap rules (acs-commons) on author instance
    -c credentials to fetch RewriteMap rules url
    E.g. (without rewrite map): ${0##*/} -n mysite -d example.com -d www.example.com
    E.g. (with a rewrite map):  ${0##*/} -n mysite -d example.com -d www.example.com -c admin:admin -r http://author.example:4502/etc/acs-commons/redirect-maps/\${MAP_FILE}/jcr:content.redirectmap.txt
EOT
}

##############################################################################

main() {
	local SCRIPTS_HOME=/usr/local/bin
	
	local JCR_CONTENT_NODE_NAME=
	local DOMAINS=( )
	local REWRITE_MAP_URL=
	local REWRITE_MAP_URL_CREDENTIALS=
	
	# Options
	while getopts "n:d:r:c:" option; do
		case "$option" in
			n) JCR_CONTENT_NODE_NAME=$OPTARG ;;
			d) DOMAINS[${#DOMAINS[*]}]=$OPTARG ;;
			r) REWRITE_MAP_URL=$OPTARG ;;
			c) REWRITE_MAP_URL_CREDENTIALS=$OPTARG ;;
			*) print_usage; exit 1 ;;
		esac
	done
	shift $((OPTIND - 1))  # Shift off the options and optional --
	
	# Require at least 1 domain
	if [ -z "${JCR_CONTENT_NODE_NAME}" ] || [ "${#DOMAINS[*]}" -eq 0 ]; then
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
	local PRIMARY_DOMAIN="${DOMAINS[0]}"
	if [ -f "${HTTPD_CONF_D}/farm_${PRIMARY_DOMAIN}.conf" ]; then
		echo "Error: configuration already exists for domain ${PRIMARY_DOMAIN}; aborting."
		exit 1
	fi
	echo "Creating httpd & dispatcher configuration for domains ${DOMAINS[*]}"
	httpd_virtualhost_install "${HTTPD_HTDOCS}" "${JCR_CONTENT_NODE_NAME}" "${DOMAINS[@]}"
	dispatcher_configure "${JCR_CONTENT_NODE_NAME}" "${DOMAINS[@]}"
	if [ -n "$REWRITE_MAP_URL" ]; then
		echo "Configuring RewriteMap cron job for domains ${DOMAINS[*]} from URL ${REWRITE_MAP_URL}"
		httpd_rewritemap_configure "$PRIMARY_DOMAIN"
		cron_rewritemap_create "${SCRIPTS_HOME}" "$PRIMARY_DOMAIN" "$REWRITE_MAP_URL" "$REWRITE_MAP_URL_CREDENTIALS"
	fi
	
	#httpd_restart
}
main "$@"
