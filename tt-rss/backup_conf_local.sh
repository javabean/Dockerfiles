#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

## copy conf dirs to enable populating empty volumes (see restore_conf.sh)
#tar czf /ttrss.tgz -C /var/www html

:
