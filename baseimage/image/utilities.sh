#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Often used tools.
# can also install "libcap-ng-utils" for "pscap" utility, for debugging required capabilities
# iproute2 (net-tools is deprecated)
# bind9-host dnsutils iproute2 iputils-ping telnet
$minimal_apt_get_install curl less vim-tiny psmisc xz-utils
ln -s /usr/bin/vim.tiny /usr/bin/vim

## This tool runs a command as another user and sets $HOME.
cp -a /bd_build/bin/setuser /sbin/setuser

# sudo replacements: setuser / chpst (runit) / gosu <https://github.com/tianon/gosu> / su-exec <https://github.com/ncopa/su-exec>
# Note that you can also: chroot --skip-chdir --userspec=<user> / <cmd>
#if [ -z "${GOSU_VERSION}" -o "${GOSU_VERSION}" = "latest" ]; then
#	TAG_NAME="$(curl -fsSL https://api.github.com/repos/tianon/gosu/releases/latest | jq --raw-output '.tag_name')"
#	echo "Downloading gosu $TAG_NAME"
#	curl -ORL $(curl -fsSL https://api.github.com/repos/tianon/gosu/releases/latest | jq --raw-output ".assets[] | select(.name == \"gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')\") | .browser_download_url")
#else
#	curl -o /usr/local/bin/gosu -fsSLR "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')"
#fi
#chmod +x /usr/local/bin/gosu
cp -a /bd_build/bin/su-exec.$(dpkg --print-architecture | awk -F- '{ print $NF }') /usr/local/bin/su-exec
ln -s /usr/local/bin/su-exec /usr/local/bin/gosu

cp -a /bd_build/bin/wait_for.sh /usr/local/bin/
