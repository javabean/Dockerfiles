#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

chmod +x baseimage/image/bin/*
find . \( -name '*.sh' -o -name 'runit*' -o -name '*.runit' \) -print0 | xargs -0 chmod +x
