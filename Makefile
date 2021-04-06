unexport IMG_NAME = cedrik/baseimage
unexport IMG_VERSION = 0.11.0.1


########################################################################
# START set versions here
# see also docker-compose's .env
########################################################################

include .env
#export $(shell sed 's/=.*//' .env)

DOCKER_APT_VERSION = 20.10.*
# url fragment
DOCKER_COMPOSE_VERSION = 1.28.6

DOCKER_FROM_IMAGE ?= ubuntu
DOCKER_FROM_VERSION ?= 18.04
DOCKER_FROM ?= $(DOCKER_FROM_IMAGE):$(DOCKER_FROM_VERSION)
#DOCKER_FROM = arm32v7/ubuntu:16.04

# Would have been much easier with Debian's redirector httpredir.debian.org...
#APT_MIRROR ?= mirrors.online.net
#APT_MIRROR ?= mirror.scaleway.com
#APT_MIRROR ?= mirror.cloud.online.net # internal network only, does not work for containers!
#APT_MIRROR ?= azure.archive.ubuntu.com
#APT_MIRROR ?= us-west1.gce.archive.ubuntu.com
APT_MIRROR ?= fr.archive.ubuntu.com
# arm
#APT_MIRROR ?= ports.ubuntu.com/ubuntu-ports
#APT_MIRROR ?= ftp.tu-chemnitz.de/pub/linux/ubuntu-ports
#APT_MIRROR ?= mirror.unej.ac.id/ubuntu

########################################################################
# END set versions here
########################################################################

docker_compose_build = http-proxy http-static tomcat dovecot email-relay mysql-cron owncloud nextcloud wordpress dokuwiki tiddlywiki openvpn web-accelerator transmission tt-rss sslh
.PHONY: $(docker_compose_build)


.PHONY: all
all: build

# one of the other, really...
export
.EXPORT_ALL_VARIABLES:

.PHONY: help
help: ## Display this help menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: pull
pull: ## pull base Docker images from Docker Hub
	docker image pull $(DOCKER_FROM)
	#docker-compose pull
	#docker image pull memcached:1.6-alpine
	docker image pull redis:5-alpine
	#docker image pull silverwind/droppy
	#docker image pull portainer/portainer-ce
	#docker image pull certbot/certbot
	#docker image pull traefik:$(TRAEFIK_VERSION)
	#docker image pull nextcloud:production-apache
	docker image pull node:lts-alpine
	#docker image pull python:3.8-slim
	#docker image pull tomat:9-jdk11-openjdk-slim
	docker image pull docker:20.10
	docker image pull php:7.4-apache

.PHONY: build
build: ## build all Docker images
build: $(docker_compose_build)

.PHONY: baseimage
baseimage: ## build Docker base image
baseimage: pull
	docker image build --build-arg BASE_IMAGE=$(DOCKER_FROM) --build-arg APT_MIRROR=$(APT_MIRROR) -t cedrik/baseimage:$(DOCKER_FROM_VERSION) --rm baseimage/image

.PHONY: httpd-base
httpd-base: ## build Docker base Apache httpd image
httpd-base: baseimage
	docker image build --build-arg MOD_MAXMINDDB_VERSION=$(MOD_MAXMINDDB_VERSION) -t cedrik/httpd-base --rm apache-base

.PHONY: php7-apache
php7-apache: ## build Docker base PHP 7 image (Apache httpd-based) with MySQL client
php7-apache:
	docker image build --build-arg MYSQL_VERSION=$(MYSQL_VERSION) -t cedrik/php7-apache --rm php7-apache


$(docker_compose_build): baseimage
	docker-compose build $@

http-proxy: httpd-base
owncloud wordpress dokuwiki tt-rss: php7-apache
#owncloud: memcached-owncloud redis-owncloud
owncloud wordpress: email-relay
dokuwiki: email-relay
openvpn: web-accelerator

########################################################################

.PHONY: tag_latest
tag_latest:
	docker image tag $(IMG_NAME):$(IMG_VERSION) $(IMG_NAME):latest

########################################################################

.PHONY: stats
stats: ## display running containers statistics
	docker container stats --no-stream $$(docker container ls --format='{{.Names}}')

.PHONY: ip
ip:
	@#docker container inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress }}' $(filter-out $@,$(MAKECMDGOALS))
	@#docker container inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress }}' $(NAME)
	docker container inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $$(docker container ls -f name=$(NAME) -q)

.PHONY: health
health: ## Print out the text of the last 5 checks. Use with:  NAME=<container_name>  make health
health:
	@#docker container inspect --format='{{json .State.Health}}' $(NAME)
	docker container inspect -f '{{ range .State.Health.Log }}{{ println "======\nStart:" .Start }}{{ .Output }}{{end}}' $(NAME)

#%:
#	@:

########################################################################

.PHONY: clean
clean: ## remove stopped containers, unused volumes, untagged images, unused networks
clean:
	# See also Docker 1.13 `docker system df [-v]` / `docker system prune [--volumes] -f` == `docker container prune -f && docker volume prune -f && docker image prune -f && docker network prune -f`
	# remove stopped containers
	# WARNING: be aware if you use data-only container, it will remove them also if you set "--volumes=true"
	docker container ls --no-trunc -a -q -f "status=exited" | xargs --no-run-if-empty docker container rm --volumes=false
	# remove all unused volumes
	#docker volume ls -q | xargs --no-run-if-empty docker volume rm
	# remove local volumes
	#docker volume ls | awk '/^local/ { print $2 }' | xargs --no-run-if-empty docker volume rm
	# remove untagged images
	docker image ls -f "dangling=true" -q | xargs --no-run-if-empty docker image rm
	# delete and untag every image that is not a container
	# a little more heinous since "<none>" is the repo/tag for dangling images
	# sort is not necessary but is nice if you add a -tn1 to xargs so you can see each rm line
	#docker image ls | awk 'NR>1 { if ($1 == "<none>") print $3; else print $1":"$2 }' | sort | xargs --no-run-if-empty docker image rm
	# remove unused networks
	docker network ls --filter type=custom --no-trunc -q | xargs --no-run-if-empty docker network rm

.PHONY: prune
prune: ## synonymous for 'clean'; same as:  docker system prune -f
prune: clean

.PHONY: distclean
distclean: ## 'clean' + remove all built images
distclean: clean
	# See also Docker 1.13 `docker image prune -a -f`
	# docker image rm "cedrik/*" "*_*"
	docker image ls --no-trunc -q "*_*" | xargs --no-run-if-empty docker image rm
	docker image ls --no-trunc -q "cedrik/*" | xargs --no-run-if-empty docker image rm

########################################################################

.PHONY: mkdirs
mkdirs: ## create required directories in  /opt  and  /srv
	mkdir -p -m 0775 \
	/opt/traefik \
	/opt/http-proxy/conf-available /opt/http-proxy/conf-enabled /opt/http-proxy/conf-include /opt/http-proxy/mods-available /opt/http-proxy/mods-enabled /opt/http-proxy/sites-available /opt/http-proxy/sites-enabled /opt/http-proxy/tls \
	                       /srv/http-proxy        /srv/logs/http-proxy/apache2 \
	/opt/tomcat                                   /srv/logs/tomcat \
	/opt/owncloud/config /opt/owncloud/apps  /srv/owncloud/data     /srv/logs/owncloud/apache2 \
	                                              /srv/redis-owncloud \
	/opt/nextcloud/config /opt/nextcloud/custom_apps /opt/nextcloud/themes  /srv/nextcloud/data     /srv/logs/nextcloud/apache2 \
	                                              /srv/redis-nextcloud \
	/opt/mysql/docker-entrypoint-initdb.d /opt/mysql/healthcheck.cnf /opt/mysql/mysql-init-complete \
	  /srv/mysql/data /srv/mysql/backup           /srv/logs/mysql/mysql \
	/opt/dovecot           /srv/dovecot           /srv/logs/dovecot \
	/opt/email-relay/dkim/keys                    /srv/logs/email-relay \
      /srv/dokuwiki/conf  /srv/dokuwiki/lib/plugins  /srv/dokuwiki/lib/tpl  /srv/dokuwiki/data \
                                                  /srv/logs/dokuwiki/apache2 \
      /srv/tiddlywiki  \
      /srv/wordpress/wp-content  /srv/wordpress/wp-includes-languages \
                                                  /srv/logs/wordpress/apache2 \
	/opt/openvpn                                  /srv/logs/openvpn \
	                                              /srv/logs/ziproxy \
	  /srv/transmission \
	  /srv/bitwarden \
	/opt/droppy \
	/opt/portainer/certs  /srv/portainer/data \
	/opt/icecaste  /srv/logs/icecast  /opt/darkice

	sudo touch /opt/traefik/acme.json /opt/traefik/htpasswd /opt/traefik/htdigest && sudo chmod 600 /opt/traefik/acme.json
	sudo chmod g-rw,o-rwx /opt/http-proxy/tls
	#sudo chown root:ssl-cert /opt/http-proxy/tls
	sudo chown -R root: /opt/http-proxy/tls
	sudo chown -R 8080:8080 /opt/tomcat
	#sudo chown -R 101:102 /srv/mysql/data /srv/mysql/backup /srv/logs/mysql/mysql
	sudo chown -R 999:999 /srv/mysql/data /srv/mysql/backup /srv/logs/mysql/mysql
	if [ ! -f /srv/wordpress/wp-config.php ]; then touch /srv/wordpress/wp-config.php; fi
	if [ ! -f /srv/wordpress/htaccess ]; then touch /srv/wordpress/htaccess; fi
	sudo chown -R www-data:www-data /opt/owncloud /srv/owncloud/data /srv/wordpress /srv/dokuwiki /srv/tiddlywiki /srv/tt-rss
	# if [ "$(ls -A /opt/dovecot/*.pem)" ]; then
	if ls -A /opt/dovecot/*.pem > /dev/null 2>&1; then sudo chmod 0400 /opt/dovecot/*.pem; fi
	# usd:gid 101:103 == dovecot
	sudo chown -R 101:103 /opt/dovecot
	sudo chown -R mail:mail /srv/dovecot
	#sudo chown -R opendkim:postfix /opt/email-relay
	sudo chown -R 103:104 /opt/email-relay
	sudo chown 101:102 /srv/transmission
	sudo chown 100:101 /srv/redis*
	sudo chown -R nobody:nogroup /srv/droppy /opt/droppy
	sudo touch /opt/icecast/htpasswd && sudo chown 100:101 /opt/icecast/htpasswd

########################################################################

.PHONY: check-config
check-config: ## check host configuration for Docker compatibility
	curl -fsSL https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh | bash

.PHONY: install-docker
install-docker: ## install Docker; this target also works for a Raspberry Pi
	#curl -fsSL https://get.docker.com/gpg | sudo apt-key add -
	#curl -fsSL https://download.docker.com/linux/centos|debian|fedora|ubuntu/gpg | sudo apt-key add -
	if [ ! -f /etc/apt/sources.list.d/docker.list ]; then \
		curl -fsSL https://get.docker.com/ | sudo sh; \
		sudo usermod -aG docker `whoami`; \
		sudo apt-get install nfs-common; \
	else \
		sudo apt-get install docker-ce=$(DOCKER_APT_VERSION); \
	fi

.PHONY: install-docker-compose
install-docker-compose: ## install docker-compose
	#pip install docker-compose
	sudo rm -f /usr/local/bin/docker-compose /etc/bash_completion.d/docker-compose
	sudo curl -fsSLR -o /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/$(DOCKER_COMPOSE_VERSION)/docker-compose-`uname -s`-`uname -m`
	sudo chmod +x /usr/local/bin/docker-compose
	#sudo curl -fsSLR -o /etc/bash_completion.d/docker-compose https://raw.githubusercontent.com/docker/compose/$$(docker-compose version --short)/contrib/completion/bash/docker-compose
	sudo curl -fsSLR -o /etc/bash_completion.d/docker-compose https://raw.githubusercontent.com/docker/compose/$(DOCKER_COMPOSE_VERSION)/contrib/completion/bash/docker-compose
	sudo touch -r /usr/local/bin/docker-compose /etc/bash_completion.d/docker-compose

.PHONY: install-docker-compose-rpi
install-docker-compose-rpi: ## install docker-compose on a Raspberry Pi
	#sudo apt-get -y install --no-install-recommends python3-yaml python3-pip  &&  sudo pip3 install docker-compose
	if [ ! -f /etc/apt/sources.list.d/Hypriot_Schatzkiste.list ]; then \
		sudo apt-get install apt-transport-https \
		sudo curl -fsSLR -o /etc/apt/sources.list.d/Hypriot_Schatzkiste.list "https://packagecloud.io/install/repositories/Hypriot/Schatzkiste/config_file.list?os=raspbian&dist=8&source=script" \
		curl -fsSL https://packagecloud.io/Hypriot/Schatzkiste/gpgkey | sudo apt-key add - \
		sudo usermod -aG docker `whoami`; \
	fi \
	sudo apt-get update && sudo apt-get install docker-compose=$(DOCKER_APT_VERSION); \
	sudo curl -fsSLR -o /etc/bash_completion.d/docker-compose https://raw.githubusercontent.com/docker/compose/$$(docker-compose version --short)/contrib/completion/bash/docker-compose
	sudo touch -r /usr/local/bin/docker-compose /etc/bash_completion.d/docker-compose

.PHONY: install
install: ## install docker + docker-compose & create required directories (see 'mkdirs')
install: install-docker-compose install-docker mkdirs

.PHONY: uninstall
uninstall: ## remove all traces of Docker save for data in  /opt  and  /srv
uninstall: distclean
	rm /usr/local/bin/docker-* /etc/bash_completion.d/docker-*
	#pip uninstall docker-compose
	sudo apt-get purge -y docker docker-engine docker.io docker-ce docker-hypriot docker-compose docker-machine
	#sudo rm -rf /var/lib/docker
	echo "Left over: config & data dirs: /opt /srv"
