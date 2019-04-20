#!/bin/sh
set -e
set -u
#(set -o | grep -q pipefail) && set -o pipefail
#(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# Install dispatcher instance

##############################################################################

# If TLS is terminated before httpd, use mod_proxy (with X-Forwarded-Proto / X-SSL / X-Forwarded-SSL: on / …)
# and follow the steps at https://helpx.adobe.com/experience-manager/kb/AEM-redirecting-back-to-http-on-accessed-via-SSL-terminated-Load-Balancer.html
httpd_install() {
	if [ -f "${HTTPD_MODULES}"/mod_dispatcher.so ]; then
		echo "httpd + dispatcher already installed. Skipping."
		return
	fi

	local AEM_AP_RUNMODE=${1}
	local AEM_ENDPOINT=${2}
	local DISPATCHER_TGZ_URL=${3}
	local reset_e=0

	# 1. install Apache httpd
	httpd_install_pre
	cp -a usr-local-bin/*  /usr/local/bin/

	# 2. install the dispatcher module
	curl -fsSL "${DISPATCHER_TGZ_URL}" | tar xz -C "${HTTPD_MODULES}"/ --wildcards "dispatcher-apache*.so"
	ln -s "${HTTPD_MODULES}"/dispatcher-apache*.so "${HTTPD_MODULES}"/mod_dispatcher.so

	# 3. configure the httpd dispatcher.conf
	cp -a conf.modules.d/* "${HTTPD_CONF_MODULES_D}"/
	cp -a conf.d/*.conf "${HTTPD_CONF_D}"/
	# activate run-mode specific configuration (tagged with '##@@${AEM_AP_RUNMODE}@@')
	internal_is_shell_attribute_set "e" && set +e && reset_e=1
	if [ -n "${AEM_AP_RUNMODE}" ] && [ -f "${HTTPD_CONF_D}"/farm-default.conf ] && grep -q -F "##@@${AEM_AP_RUNMODE}@@" "${HTTPD_CONF_D}"/farm-default.conf; then
		[ "$reset_e" -eq 1 ] && set -e
		sed -i --follow-symlinks \
			-e "s%##@@${AEM_AP_RUNMODE}@@%%" \
			"${HTTPD_CONF_D}"/farm-default.conf
	fi
	[ "$reset_e" -eq 1 ] && set -e
	sed -i --follow-symlinks \
		-e "s%@@\${HTTPD_CONF}@@%${HTTPD_CONF}%" \
		-e "s%@@\${HTTPD_ROTATELOGS}@@%$(command -v rotatelogs)%" \
		"${HTTPD_CONF_D}"/farm-default.conf
	sed -i --follow-symlinks\
		-e "s%Define documentroot .*%Define documentroot ${HTTPD_HTDOCS}%" \
		-e "s%Define httpd_logs .*%Define httpd_logs ${HTTPD_LOGS}%" \
		-e "s%@@\${HTTPD_ROTATELOGS}@@%$(command -v rotatelogs)%" \
		"${HTTPD_CONF_D}"/dispatcher.conf
#	[ -d /etc/logrotate.d ] && {
#		cp -a logrotate.d/httpd-logs /etc/logrotate.d/
#		sed -i --follow-symlinks "s%^/var/log/httpd/%${HTTPD_LOGS}/%" /etc/logrotate.d/httpd-logs
#	}

	# 4. configure dispatcher.any
	cp -a conf.d/"${AEM_AP_RUNMODE}"/* "${HTTPD_CONF_D}"/
	local DISPATCHER_ANY="${HTTPD_CONF_D}"/inc-cache.any
	local reset_e=0 ; internal_is_shell_attribute_set "e" && set +e && reset_e=1
	if [ ! -f "$DISPATCHER_ANY" ] || ! grep -q "/docroot " "$DISPATCHER_ANY"; then DISPATCHER_ANY="${HTTPD_CONF_D}"/dispatcher.any; fi
	[ "$reset_e" -eq 1 ] && set -e
	sed -i --follow-symlinks -e "s%/docroot .*%/docroot \"${HTTPD_HTDOCS}\"%" \
		"$DISPATCHER_ANY"
	# Setting AEM endpoint will also be done at runtime if $AEM_ENDPOINT is available
	DISPATCHER_ANY="${HTTPD_CONF_D}"/inc-renders.any
	set +e
	if [ ! -f "$DISPATCHER_ANY" ] || ! grep -q "/hostname " "$DISPATCHER_ANY"; then DISPATCHER_ANY="${HTTPD_CONF_D}"/dispatcher.any; fi
	[ "$reset_e" -eq 1 ] && set -e
	sed -i --follow-symlinks -e "s%/hostname \".*\"%/hostname \"${AEM_ENDPOINT}\"%" \
		"$DISPATCHER_ANY"

	# 6. SELinux configuration
	[ -x "$(command -v semanage)" ] && [ -x "$(command -v setsebool)" ] && [ -x "$(command -v chcon)" ] && {
		semanage fcontext -a -t httpd_modules_t "${HTTPD_MODULES}"/dispatcher-apache*.so
		setsebool -P httpd_can_network_connect on
		chcon -R --type httpd_sys_content_t "${HTTPD_HTDOCS}"
		semanage fcontext -a -t httpd_sys_content_t "${HTTPD_HTDOCS}(/.*)?"
	}

	chown -R "${HTTPD_USER}": "${HTTPD_HTDOCS}" "${HTTPD_LOGS}"
	chmod -R a+rX "${HTTPD_HTDOCS}" "${HTTPD_LOGS}"

	httpd_install_post
}

##############################################################################

print_usage() {
	cat << EOT
Install Apache httpd + AEM dispatcher
Usage
    ${0##*/} -a <aem author ip> | -p <aem publish ip>  -d <dispatcher url>
    -a AEM author instance IP
    -p AEM publish instance IP
    -d dispatcher download URL (.tar.gz)
    Note: -a and -p are mutually exclusive!
    E.g.: dispatcher for author instance:	${0##*/} -a 192.0.2.2 -d http://download.macromedia.com/dispatcher/download/dispatcher-apache2.4-linux-x86_64-4.3.2.tar.gz
    E.g.: dispatcher for publish instance:	${0##*/} -p 192.0.2.3 -d http://download.macromedia.com/dispatcher/download/dispatcher-apache2.4-linux-x86_64-4.3.2.tar.gz
EOT
}

##############################################################################

main() {
	# author: 4502; publish: 4503
	local AEM_PORT=${AEM_PORT:-4502}
	
	# temporary variable to read CLI option; also used for copying AEM Dispatcher configuration file
	# author | publish
	local AEM_AP_RUNMODE=${AEM_AP_RUNMODE:-}
	local AEM_ENDPOINT=${AEM_ENDPOINT:-}
	local DISPATCHER_TGZ_URL=${DISPATCHER_TGZ_URL:-}
	
	# Options
	while getopts "a:p:d:" option; do
		case "$option" in
			a) if [ -n "$AEM_AP_RUNMODE" ] && [ "$AEM_AP_RUNMODE" != author ]; then print_usage; exit 1; fi; AEM_ENDPOINT=$OPTARG; AEM_PORT=4502; AEM_AP_RUNMODE=author ;;
			p) if [ -n "$AEM_AP_RUNMODE" ] && [ "$AEM_AP_RUNMODE" != publish ]; then print_usage; exit 1; fi; AEM_ENDPOINT=$OPTARG; AEM_PORT=4503; AEM_AP_RUNMODE=publish ;;
			d) DISPATCHER_TGZ_URL=$OPTARG ;;
			*) print_usage; exit 1 ;;
		esac
	done
	shift $((OPTIND - 1))  # Shift off the options and optional --
	
	# Require author or publish mode, and remote AEM IP
	if [ -z "$AEM_AP_RUNMODE" ] || [ -z "$AEM_ENDPOINT" ] || [ -z "$DISPATCHER_TGZ_URL" ]; then
		print_usage
		exit 1
	fi
	
	# $# should be at least 1 (the command to execute), however it may be strictly
	# greater than 1 if the command itself has options.
	#if [ $# -eq 0 ]; then
	#	print_usage
	#	exit 1
	#fi
	
	echo "Installing Apache httpd & AEM dispatcher for $AEM_AP_RUNMODE instance at $AEM_ENDPOINT"

	httpd_install "$AEM_AP_RUNMODE" "$AEM_ENDPOINT" "$DISPATCHER_TGZ_URL"
	
	echo "AEM $AEM_AP_RUNMODE dispatcher installation complete!"
	echo "Please ensure this node is time-synchronized (NTP)."
	echo "Please de-activate any antivirus for ${HTTPD_HTDOCS} and ${HTTPD_LOGS} on this node!"
}
# In case file transfer did not copy over permissions bits...
find . -exec chmod a+rX,o-w "{}" \;
find . -name "*.sh" -exec chmod a+rx "{}" \;
. ./usr-local-bin/httpd-environment.sh
main "$@"
