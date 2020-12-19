#!/bin/bash
#set -u
set -e -o pipefail -o posix
#shopt -s failglob
#set -x

/usr/local/bin/wait_for.sh mysqladmin --silent --wait=9 --connect_timeout 10 -h "${WORDPRESS_DB_HOST:-mysql}" -u "${WORDPRESS_DB_USER:-wordpress}" -p"${WORDPRESS_DB_PASSWORD:-wordpress}" ping

# copy backup of conf dirs if mounted volume is empty

# if [ ! "$(ls -U "/var/www/html/wp-content/")" ]; then
if ! ls -U /var/www/html/wp-content/* > /dev/null 2>&1; then
	tar xzf /var/www/wp-content.tgz -C /var/www/html
fi

# if [ ! "$(ls -U "/var/www/html/wp-includes/languages/")" ]; then
if ! ls -U /var/www/html/wp-includes/languages/* > /dev/null 2>&1; then
	[ -f /var/www/wp-includes-languages.tgz ] && tar xzf /var/www/wp-includes-languages.tgz -C /var/www/html
fi

for f in wp-config.php .htaccess robots.txt ; do
	if [ ! -f "/var/www/html/${f}" ] && [ -f "/var/www/html/${f}.bak" ]; then
		cp -a "/var/www/html/${f}.bak" "/var/www/html/${f}"
	fi
done


# First run
if [ ! -s /var/www/html/wp-config.php ]; then
	: "${WORDPRESS_DB_HOST:=mysql}"
	# if we're linked to MySQL and thus have credentials already, let's use them
	: ${WORDPRESS_DB_USER:=${MYSQL_ENV_MYSQL_USER:-root}}
	if [ "$WORDPRESS_DB_USER" = 'root' ]; then
		: ${WORDPRESS_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
	fi
	: ${WORDPRESS_DB_PASSWORD:=$MYSQL_ENV_MYSQL_PASSWORD}
	: ${WORDPRESS_DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE:-wordpress}}

	if [ -z "$WORDPRESS_DB_PASSWORD" ]; then
		echo >&2 'error: missing required WORDPRESS_DB_PASSWORD environment variable'
		echo >&2 '  Did you forget to -e WORDPRESS_DB_PASSWORD=... ?'
		echo >&2
		echo >&2 '  (Also of interest might be WORDPRESS_DB_USER and WORDPRESS_DB_NAME.)'
		exit 1
	fi

	cd /var/www/html

		if [ ! -s .htaccess ]; then
			# NOTE: The "Indexes" option is disabled in the php:apache base image
			cat > .htaccess <<-'EOF'
				# https://wordpress.org/support/article/hardening-wordpress/#securing-wp-config-php
				<Files wp-config.php>
				    Require all denied
				</Files>
				<Files debug.log>
					Require all denied
				</Files>

				# Block the include-only files.
				# https://wordpress.org/support/article/hardening-wordpress/#securing-wp-includes
				# Note that this won't work well on Multisite, as RewriteRule ^wp-includes/[^/]+\.php$ - [F,L] would prevent the ms-files.php file from generating images. Omitting that line will allow the code to work, but offers less security.
				<IfModule mod_rewrite.c>
					RewriteEngine On
					RewriteBase /
					RewriteRule ^wp-admin/includes/ - [F,L]
					RewriteRule !^wp-includes/ - [S=3]
					#RewriteRule ^wp-includes/[^/]+\.php$ - [F,L]
					RewriteRule ^wp-includes/js/tinymce/langs/.+\.php - [F,L]
					RewriteRule ^wp-includes/theme-compat/ - [F,L]
				</IfModule>

				# BEGIN WordPress
				<IfModule mod_rewrite.c>
				RewriteEngine On
				RewriteBase /
				RewriteRule ^index\.php$ - [L]
				RewriteCond %{REQUEST_FILENAME} !-f
				RewriteCond %{REQUEST_FILENAME} !-d
				RewriteRule . /index.php [L]
				</IfModule>
				# END WordPress
			EOF
			chown www-data:www-data .htaccess
		fi

	# TODO handle WordPress upgrades magically in the same way, but only if wp-includes/version.php's $wp_version is less than /usr/src/wordpress/wp-includes/version.php's $wp_version

	# version 4.4.1 decided to switch to windows line endings, that breaks our seds and awks
	# https://github.com/docker-library/wordpress/issues/116
	# https://github.com/WordPress/WordPress/commit/1acedc542fba2482bab88ec70d4bea4b997a92e4
	sed -ri 's/\r\n|\r/\n/g' wp-config-*.php
	[ -s wp-config.php ] && sed -ri 's/\r\n|\r/\n/g' wp-config.php

	if [ ! -s wp-config.php ]; then
		awk '/^\/\*.*stop editing.*\*\/$/ && c == 0 { c = 1; system("cat") } { print }' wp-config-sample.php > wp-config.php <<'EOPHP'
// If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact
// see also http://codex.wordpress.org/Administration_Over_SSL#Using_a_Reverse_Proxy
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
	$_SERVER['HTTPS'] = 'on';
}
EOPHP
		chown www-data:www-data wp-config.php
	fi

	# see http://stackoverflow.com/a/2705678/433558
	sed_escape_lhs() {
		echo "$@" | sed 's/[]\/$*.^|[]/\\&/g'
	}
	sed_escape_rhs() {
		echo "$@" | sed 's/[\/&]/\\&/g'
	}
	php_escape() {
		php -r 'var_export(('$2') $argv[1]);' "$1"
	}
	set_config() {
		key="$1"
		value="$2"
		var_type="${3:-string}"
		start="(['\"])$(sed_escape_lhs "$key")\2\s*,"
		end="\);"
		if [ "${key:0:1}" = '$' ]; then
			start="^(\s*)$(sed_escape_lhs "$key")\s*="
			end=";"
		fi
		sed -ri "s/($start\s*).*($end)$/\1$(sed_escape_rhs "$(php_escape "$value" "$var_type")")\3/" wp-config.php
	}

	set_config 'DB_HOST' "$WORDPRESS_DB_HOST"
	set_config 'DB_USER' "$WORDPRESS_DB_USER"
	set_config 'DB_PASSWORD' "$WORDPRESS_DB_PASSWORD"
	set_config 'DB_NAME' "$WORDPRESS_DB_NAME"

	# allow any of these "Authentication Unique Keys and Salts." to be specified via
	# environment variables with a "WORDPRESS_" prefix (ie, "WORDPRESS_AUTH_KEY")
	UNIQUES=(
		AUTH_KEY
		SECURE_AUTH_KEY
		LOGGED_IN_KEY
		NONCE_KEY
		AUTH_SALT
		SECURE_AUTH_SALT
		LOGGED_IN_SALT
		NONCE_SALT
	)
	for unique in "${UNIQUES[@]}"; do
		eval unique_value=\$WORDPRESS_$unique
		if [ "$unique_value" ]; then
			set_config "$unique" "$unique_value"
		else
			# if not specified, let's generate a random value
			current_set="$(sed -rn "s/define\((([\'\"])$unique\2\s*,\s*)(['\"])(.*)\3\);/\4/p" wp-config.php)"
			if [ "$current_set" = 'put your unique phrase here' ]; then
				set_config "$unique" "$(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1)"
			fi
		fi
	done

	if [ "$WORDPRESS_TABLE_PREFIX" ]; then
		set_config '$table_prefix' "$WORDPRESS_TABLE_PREFIX"
	fi

	if [ "$WORDPRESS_DEBUG" ]; then
		set_config 'WP_DEBUG' 1 boolean
	fi

	TERM=dumb php -- "$WORDPRESS_DB_HOST" "$WORDPRESS_DB_USER" "$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" <<'EOPHP'
<?php
// database might not exist, so let's try creating it (just to be safe)
$stderr = fopen('php://stderr', 'w');
// https://codex.wordpress.org/Editing_wp-config.php#MySQL_Alternate_Port
//   "hostname:port"
// https://codex.wordpress.org/Editing_wp-config.php#MySQL_Sockets_or_Pipes
//   "hostname:unix-socket-path"
list($host, $socket) = explode(':', $argv[1], 2);
$port = 0;
if (is_numeric($socket)) {
	$port = (int) $socket;
	$socket = null;
}
$user = $argv[2];
$pass = $argv[3];
$dbName = $argv[4];
$maxTries = 10;
do {
	$mysql = new mysqli($host, $user, $pass, '', $port, $socket);
	if ($mysql->connect_error) {
		fwrite($stderr, "\n" . 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
		--$maxTries;
		if ($maxTries <= 0) {
			exit(1);
		}
		sleep(3);
	}
} while ($mysql->connect_error);
if (!$mysql->query('CREATE DATABASE IF NOT EXISTS `' . $mysql->real_escape_string($dbName) . '`')) {
	fwrite($stderr, "\n" . 'MySQL "CREATE DATABASE" Error: ' . $mysql->error . "\n");
	$mysql->close();
	exit(1);
}
$mysql->close();
EOPHP

fi

# now that we're definitely done writing configuration, let's clear out the relevant envrionment variables (so that stray "phpinfo()" calls don't leak secrets from our code)
for e in "${envs[@]}"; do
	unset "$e"
done
