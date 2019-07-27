#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# docker exec -ti nextcloud bash

cd /var/www/html
sudo -u www-data php occ upgrade
sudo -u www-data php occ app:enable calendar
sudo -u www-data php occ app:enable contacts
sudo -u www-data php occ app:enable tasks
sudo -u www-data php occ app:enable notes
sudo -u www-data php occ app:enable news
sudo -u www-data php occ app:enable qownnotesapi
#sudo -u www-data php occ maintenance:mode --off
# If this does not work properly, try the repair function:
#sudo -u www-data php occ maintenance:repair
# Occasionally, files do not show up after a upgrade. A rescan of the files can help:
#sudo -u www-data php occ files:scan --all
# cleanup filecache: tidies up the server’s file cache by deleting all file entries that have no matching entries in the storage table
#sudo -u www-data php occ files:cleanup
# It might happen that we add from time to time new indices to already existing database tables, for example to improve performance. In order to check your database for missing indices run following command:
#sudo -u www-data php occ db:add-missing-indices
# removes the deleted files
#sudo -u www-data php occ trashbin:cleanup
# delete file versions
#sudo -u www-data php occ versions:cleanup
