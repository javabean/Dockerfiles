#!/bin/bash
set -eu -o pipefail -o posix
#shopt -s failglob
#set -x
source /bd_build/buildconfig
set -x

apt-get clean
rm -rf /bd_build
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*

rm -f /etc/ssh/ssh_host_*
