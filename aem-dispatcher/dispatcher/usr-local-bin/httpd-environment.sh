#!/bin/sh
set -e
set -u
#(set -o | grep -q pipefail) && set -o pipefail
#(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# Install dispatcher instance - Docker|CentOS-specific bits

##############################################################################
# Shell utilities
##############################################################################

# Usage:
# local reset_e=0 ; internal_is_shell_attribute_set "e" && set +e && reset_e=1
# ...
# [ "$reset_e" -eq 1 ] && set -e
internal_is_shell_attribute_set() { # attribute, like "e"
	# Alternative implementation (e.g. for set -x): [ ${-/x} != ${-} ] && tracing=1 || tracing=0
	#local search_attribute=$1
	case "$-" in
		*"$1"*) return 0 ;;
		*)      return 1 ;;
	esac
}

internal_is_shell_option_set() { # option, like "pipefail"
	# Note: bash-specific alternative: `test -o`
	local search_option=$1
	case $(set -o | grep "$search_option" | cut -f2) in
		on) return 0 ;;
		off) return 1 ;;
		*) echo "Error: unknown shell option value \"$search_option\"!" >&2; return 1 ;;
	esac
}

is_in_docker() {
	[ -f /.dockerenv ] || grep -q docker /proc/self/cgroup
}

##############################################################################

HTTPD_PREFIX=
HTTPD_HTDOCS=
HTTPD_LOGS=
HTTPD_CONF=
HTTPD_CONF_D=
HTTPD_CONF_MODULES_D=
HTTPD_MODULES=
HTTPD_USER=

##############################################################################

# If TLS is required: somehow manage to compile & install `mod_ssl`  
# If TLS is terminated before httpd, use mod_proxy (with X-Forwarded-Proto / X-SSL / X-Forwarded-SSL: on / …)
# and follow the steps at https://helpx.adobe.com/experience-manager/kb/AEM-redirecting-back-to-http-on-accessed-via-SSL-terminated-Load-Balancer.html
_httpd_install_pre_docker() {
	# 1. install Apache httpd
	# already installed as part of Docker base image!
	# Install required utilities
	apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests apt-utils
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests tar curl liblz4-tool gzip pigz xz-utils zstd
	mkdir "${HTTPD_CONF_MODULES_D}" "${HTTPD_CONF_D}"
	sed -i --follow-symlinks \
		-e 's/^\(Include .*httpd-ssl.conf\)/\1/' \
		-e 's/^#\(LoadModule .*mod_include.so\)/\1/' \
		-e 's/^#\(LoadModule .*mod_deflate.so\)/\1/' \
		-e 's/^#\(LoadModule .*mod_expires.so\)/\1/' \
		-e 's/^#\(LoadModule .*mod_remoteip.so\)/\1/' \
		-e 's/^\(LoadModule .*mod_autoindex.so\)/#\1/' \
		-e 's/^\(LoadModule .*mod_dir.so\)/#\1/' \
		-e 's/^#\(LoadModule .*mod_rewrite.so\)/\1/' \
		"${HTTPD_CONF}"/httpd.conf
	echo "IncludeOptional conf.modules.d/*.conf" >> "${HTTPD_CONF}"/httpd.conf
	echo "IncludeOptional conf.d/*.conf" >> "${HTTPD_CONF}"/httpd.conf
	rm -fv "${HTTPD_HTDOCS}"/index.html
}

_httpd_install_post_docker() {
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
}

_httpd_restart_docker() {
	apachectl graceful
}

_cron_add_docker() {
	local TEST_STRING="$1"
	local CRON_LINE="$2"
	[ -f /usr/local/etc/cron/cron-commands.txt ] || touch /usr/local/etc/cron/cron-commands.txt
	if ! grep -q "${TEST_STRING}" /usr/local/etc/cron-commands.txt; then
		echo "${CRON_LINE}" | flock /usr/local/etc/cron/cron-commands.txt tee -a /usr/local/etc/cron/cron-commands.txt
	fi
}

##############################################################################

# If TLS is required: `yum install mod_ssl`  
# If TLS is terminated before httpd, use mod_proxy (with X-Forwarded-Proto / X-SSL / X-Forwarded-SSL: on / …)
# and follow the steps at https://helpx.adobe.com/experience-manager/kb/AEM-redirecting-back-to-http-on-accessed-via-SSL-terminated-Load-Balancer.html
_httpd_install_pre_centos() {
	# 1. install Apache httpd
	yum install -q -y httpd httpd-tools tar curl lz4 gzip pigz bzip2 xz
	rm -fv \
		"${HTTPD_CONF_MODULES_D}"/00-dav.conf "${HTTPD_CONF_MODULES_D}"/00-lua.conf "${HTTPD_CONF_MODULES_D}"/01-cgi.conf "${HTTPD_CONF_MODULES_D}"/00-proxy.conf \
		"${HTTPD_CONF_D}"/welcome.conf "${HTTPD_CONF_D}"/autoindex.conf
}

_httpd_install_post_centos() {
	systemctl enable httpd
	systemctl restart httpd
}

_httpd_restart_centos() {
	if [ -x "$(command -v systemctl)" ]; then
		systemctl restart httpd
	else
		apachectl graceful
	fi
}

_cron_add_centos() {
	local TEST_STRING="$1"
	local CRON_LINE="$2"
	# must use root crontab, since apache user is cron-disabled
	if ! crontab -u root -l 2> /dev/null | grep -q "${TEST_STRING}"; then
		# min[0-59] hour[0-23] dom[1-31] month[1-12] dow[0-7]  command
		crontab -u root -l 2> /dev/null | ( cat; echo "*/5  *  *  *  * ${CRON_LINE}" ) | crontab -u root -
	fi
}

##############################################################################

httpd_install_pre() {
	if is_in_docker; then
		_httpd_install_pre_docker "$@"
	else
		_httpd_install_pre_centos "$@"
	fi
}

httpd_install_post() {
	if is_in_docker; then
		_httpd_install_post_docker "$@"
	else
		_httpd_install_post_centos "$@"
	fi
}

httpd_restart() {
	if is_in_docker; then
		_httpd_restart_docker "$@"
	else
		_httpd_restart_centos "$@"
	fi
}

cron_add() {
	if is_in_docker; then
		_cron_add_docker "$@"
	else
		_cron_add_centos "$@"
	fi
}

_httpd_environment_main() {
	if is_in_docker; then
		HTTPD_PREFIX="${HTTPD_PREFIX:-/usr/local/apache2}"
		HTTPD_HTDOCS="${HTTPD_PREFIX}/htdocs"
		HTTPD_LOGS="${HTTPD_PREFIX}/logs"
		HTTPD_CONF="${HTTPD_PREFIX}/conf"
		HTTPD_CONF_D="${HTTPD_PREFIX}/conf.d"
		HTTPD_CONF_MODULES_D="${HTTPD_PREFIX}/conf.modules.d"
		HTTPD_MODULES="${HTTPD_PREFIX}/modules"
		HTTPD_USER=www-data
	else
		HTTPD_PREFIX="${HTTPD_PREFIX:-/etc/httpd}"
		HTTPD_HTDOCS="/var/www/html"
		HTTPD_LOGS="${HTTPD_PREFIX}/logs"
		HTTPD_CONF="${HTTPD_PREFIX}/conf"
		HTTPD_CONF_D="${HTTPD_PREFIX}/conf.d"
		HTTPD_CONF_MODULES_D="${HTTPD_PREFIX}/conf.modules.d"
		HTTPD_MODULES="${HTTPD_PREFIX}/modules"
		HTTPD_USER=apache
	fi
}
_httpd_environment_main
