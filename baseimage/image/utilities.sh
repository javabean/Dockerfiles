#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Often used tools.
# can also install "libcap-ng-utils" for "pscap" utility, for debugging required capabilities
# iproute2 (net-tools is deprecated)
$minimal_apt_get_install curl less vim-tiny psmisc
ln -s /usr/bin/vim.tiny /usr/bin/vim

## This tool runs a command as another user and sets $HOME.
cp /bd_build/bin/setuser /sbin/setuser
