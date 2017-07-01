#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)
rm -rf /var/www.bak
cp -a /var/www /var/www.bak
