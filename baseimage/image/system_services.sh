#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Install init process.
cp /bd_build/bin/my_init /sbin/
mkdir -p /etc/my_init.d
mkdir -p /etc/container_environment
touch /etc/container_environment.sh
touch /etc/container_environment.json
chmod 700 /etc/container_environment

$minimal_apt_get_install curl
#curl -o /usr/local/bin/tini -fsSLR https://github.com/krallin/tini/releases/download/v0.9.0/tini-static
curl -o /usr/local/bin/tini -fsSLR https://github.com/krallin/tini/releases/download/v0.9.0/tini
chmod +x /usr/local/bin/tini
curl -o /usr/local/bin/dumb-init -fssLR https://github.com/Yelp/dumb-init/releases/download/v1.0.2/dumb-init_1.0.2_amd64
chmod +x /usr/local/bin/dumb-init
#curl -o /usr/local/bin/gosu -fssLR "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)"
#chmod +x /usr/local/bin/gosu

groupadd -g 8377 docker_env
chown :docker_env /etc/container_environment.sh /etc/container_environment.json
chmod 640 /etc/container_environment.sh /etc/container_environment.json
ln -s /etc/container_environment.sh /etc/profile.d/

## Install runit.
$minimal_apt_get_install runit

## Install a syslog daemon and logrotate.
[ "$DISABLE_SYSLOG" -eq 0 ] && /bd_build/services/syslog-ng/syslog-ng.sh || true

## Install the SSH server.
[ "$DISABLE_SSH" -eq 0 ] && /bd_build/services/sshd/sshd.sh || true

## Install cron daemon.
[ "$DISABLE_CRON" -eq 0 ] && /bd_build/services/cron/cron.sh || true


## Create a user for the web app.
addgroup --gid 9999 app
adduser --uid 9999 --gid 9999 --disabled-password --gecos "Application" app
usermod -L app
usermod -a -G docker_env app
mkdir -p /home/app/.ssh
chmod 700 /home/app/.ssh
chown app:app /home/app/.ssh

