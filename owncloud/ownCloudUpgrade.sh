#!/bin/sh

# docker exec -ti owncloud bash

cd /var/www/owncloud
sudo -u www-data php occ upgrade
sudo -u www-data php occ app:enable calendar
sudo -u www-data php occ app:enable contacts
sudo -u www-data php occ app:enable tasks
sudo -u www-data php occ app:enable notes
sudo -u www-data php occ app:enable news
#sudo -u www-data php occ maintenance:mode --off
# If this does not work properly, try the repair function:
#sudo -u www-data php occ maintenance:repair
# Occasionally, files do not show up after a upgrade. A rescan of the files can help:
#sudo -u www-data php console.php files:scan --all
