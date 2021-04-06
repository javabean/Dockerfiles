#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# https://www.dokuwiki.org/install:upgrade
# https://www.dokuwiki.org/changes

DOKUWIKI_VERSION="${DOKUWIKI_VERSION:-stable}"
STRIP_LANGS_KEEP="${STRIP_LANGS_KEEP:-}"

echo "Upgrading DokuWiki to version: ${DOKUWIKI_VERSION}"
echo "https://www.dokuwiki.org/changes"

cd /var/www
tar czf dokuwiki-backup.tar.gz html
cd /var/www/html
curl -fsSL https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}.tgz | sudo -u www-data tar xz -C /var/www/html/ --strip-components=1
chown www-data:www-data -R /var/www/html/
chmod +x /var/www/html/bin/*.php
find /var/www/html -name '_dummy' -delete
grep -Ev '^($|#)' data/deleted.files | xargs --no-run-if-empty -n 1 rm -vfr
# purge cache
[ -f conf/local.php ] && touch conf/local.php
rm -fv data/cache/messages.txt
# sudo -u www-data ./bin/indexer.php -c
if [ -n "${STRIP_LANGS_KEEP}" ]; then
	/var/www/html/bin/striplangs.php -k "${STRIP_LANGS_KEEP}"
fi

