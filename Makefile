unexport IMG_NAME = cedrik/baseimage
unexport IMG_VERSION = 0.9.22.1


########################################################################
# START set versions here
# see also docker-compose's .env
########################################################################

DOCKER_APT_VERSION = 17.09.*
# url fragment
DOCKER_COMPOSE_VERSION = 1.16.1
# url fragment
DOCKER_MACHINE_VERSION = v0.12.2

DOCKER_FROM ?= ubuntu:16.04
#DOCKER_FROM = arm32v7/ubuntu:16.04

# Would have been much easier with Debian's redirector httpredir.debian.org...
#APT_MIRROR ?= mirrors.online.net
#APT_MIRROR ?= mirror.scaleway.com
#APT_MIRROR ?= mirror.cloud.online.net # internal network only, does not work for containers!
#APT_MIRROR ?= us-west1.gce.archive.ubuntu.com
APT_MIRROR ?= fr.archive.ubuntu.com
# arm
#APT_MIRROR ?= ports.ubuntu.com/ubuntu-ports
#APT_MIRROR ?= ftp.tu-chemnitz.de/pub/linux/ubuntu-ports
#APT_MIRROR ?= mirror.unej.ac.id/ubuntu

########################################################################
# END set versions here
########################################################################

include .env
#export $(shell sed 's/=.*//' .env)

docker_compose_build = consul http-proxy tomcat dovecot dnsmasq unbound email-relay mysql owncloud prestashop joomla wordpress dokuwiki tiddlywiki openvpn web-accelerator transmission netdata
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
	docker image pull memcached:1.4-alpine
	docker image pull redis:3-alpine
	docker image pull silverwind/droppy
	docker image pull portainer/portainer
	#docker image pull quay.io/letsencrypt/letsencrypt

.PHONY: build
build: ## build all Docker images
build: $(docker_compose_build)

.PHONY: baseimage
baseimage: ## build Docker base image
baseimage: pull
	docker image build --build-arg DOCKER_FROM=$(DOCKER_FROM) --build-arg APT_MIRROR=$(APT_MIRROR) -t cedrik/baseimage --rm baseimage/image

.PHONY: httpd-base
httpd-base: ## build Docker base Apache httpd image
httpd-base: baseimage
	docker image build -t cedrik/httpd-base --rm apache-base

.PHONY: php5-base
php5-base: ## build Docker base PHP 5.6 image (Apache httpd-based) with MySQL client
php5-base: httpd-base
	docker image build --build-arg MYSQL_VERSION=$(MYSQL_VERSION) -t cedrik/php5-base --rm php5-base

.PHONY: php7-base
php7-base: ## build Docker base PHP 7 image (Apache httpd-based) with MySQL client
php7-base: httpd-base
	docker image build --build-arg MYSQL_VERSION=$(MYSQL_VERSION) -t cedrik/php7-base --rm php7-base

.PHONY: java
java: ## build Docker base Java image
java: baseimage
	docker image build -t cedrik/java --rm java


$(docker_compose_build): baseimage
	docker-compose build $@

tomcat: java
http-proxy: httpd-base
owncloud joomla wordpress prestashop dokuwiki: php7-base
#owncloud: memcached-owncloud redis-owncloud
owncloud joomla wordpress prestashop: mysql email-relay
dokuwiki: email-relay
openvpn: dnsmasq web-accelerator
unbound: dnsmasq
dnsmasq unbound: consul

########################################################################

.PHONY: tag_latest
tag_latest:
	docker tag $(IMG_NAME):$(IMG_VERSION) $(IMG_NAME):latest

########################################################################

.PHONY: stats
stats: ## display running containers statistics
	docker stats --no-stream $$(docker ps --format='{{.Names}}')

.PHONY: ip
ip:
	@#docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress }}' $(filter-out $@,$(MAKECMDGOALS))
	docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress }}' $(NAME)

.PHONY: health
health: ## Print out the text of the last 5 checks. Use with:  NAME=<container_name>  make health
health:
	@#docker inspect --format='{{json .State.Health}}' $(NAME)
	docker inspect -f '{{ range .State.Health.Log }}{{ println "======\nStart:" .Start }}{{ .Output }}{{end}}' $(NAME)

#%:
#	@:

########################################################################

.PHONY: new-certificates
new-certificates: ## query new TLS certificates
	# --quiet --dry-run --test-cert
	docker-compose run --rm letsencrypt --authenticators certonly --non-interactive --dry-run \
		--webroot \
		-w /srv/owncloud/acme-challenge -d oc.cedrik.fr \
		-w /srv/prestashop/acme-challenge -d boutique.vingt-citadelles.fr -d boutique.piacercanto.org \
		-w /srv/wordpress/acme-challenge -d beta.piacercanto.org \
		-w /srv/droppy -d fichiers.piacercanto.org \
		-w /srv/dokuwiki/acme-challenge -d wiki.cedrik.fr \
		-w /opt/tomcat/instance-cedrik/webapps/cedrik.fr/ROOT -d www.cedrik.fr -d cedrik.fr -d wpad.cedrik.fr \
		-w /srv/portainer/acme-challenge -d portainer.cedrik.fr \
		-w /srv/http-proxy/polycarpe.fr -d polycarpe.fr -d www.polycarpe.fr \
		-w /srv/http-proxy/vingt-citadelles.fr -d vingt-citadelles.fr -d www.vingt-citadelles.fr \
		-w /srv/http-proxy/html/.well-known -d paris.cedrik.fr

.PHONY: renew-certificates
renew-certificates: ## renew TLS certificates
	# --quiet --dry-run --test-cert
	# --pre-hook "service nginx stop" --post-hook "docker container restart http-proxy"
	docker-compose run --rm letsencrypt --authenticators renew --non-interactive --keep-until-expiring

########################################################################

.PHONY: clean
clean: ## remove stopped containers, unused volumes, untagged images, unused networks
clean:
	# See also Docker 1.13 `docker system df [-v]` / `docker system prune [--volumes] -f` == `docker container prune -f && docker volume prune -f && docker image prune -f && docker network prune -f`
	# remove stopped containers
	# WARNING: be aware if you use data-only container, it will remove them also if you set "--volumes=true"
	docker container ps --no-trunc -a -q -f "status=exited" | xargs --no-run-if-empty docker container rm --volumes=false
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
	/opt/consul/config     /srv/consul/data \
	/opt/http-proxy/conf-available /opt/http-proxy/conf-enabled /opt/http-proxy/conf-include /opt/http-proxy/mods-available /opt/http-proxy/mods-enabled /opt/http-proxy/sites-available /opt/http-proxy/sites-enabled /opt/http-proxy/tls \
	                       /srv/http-proxy        /srv/logs/http-proxy/apache2 \
	/opt/tomcat                                   /srv/logs/tomcat \
	/opt/owncloud/config /opt/owncloud/apps  /srv/owncloud/data     /srv/logs/owncloud/apache2 \
	                                              /srv/redis-owncloud \
	/opt/prestashop                               /srv/logs/prestashop/apache2 \
	  /srv/prestashop/override /srv/prestashop/mails /srv/prestashop/img /srv/prestashop/modules /srv/prestashop/download /srv/prestashop/upload /srv/prestashop/config \
	/opt/mysql/docker-entrypoint-initdb.d /opt/mysql/healthcheck.cnf /opt/mysql/mysql-init-complete \
	  /srv/mysql/data /srv/mysql/backup           /srv/logs/mysql/mysql \
	/opt/dnsmasq/dnsmasq.d                        /srv/logs/dnsmasq \
	/opt/unbound                                  /srv/logs/unbound \
	/opt/dovecot           /srv/dovecot           /srv/logs/dovecot \
	/opt/email-relay/dkim/keys                    /srv/logs/email-relay \
		            /srv/joomla/.well-known/acme-challenge  /srv/logs/joomla/apache2 \
      /srv/dokuwiki/conf  /srv/dokuwiki/lib/plugins  /srv/dokuwiki/lib/tpl  /srv/dokuwiki/data \
                                                  /srv/logs/dokuwiki/apache2 \
      /srv/tiddlywiki  \
      /srv/wordpress/wp-content  /srv/wordpress/wp-includes-languages \
                                                  /srv/logs/wordpress/apache2 \
	/opt/openvpn                                  /srv/logs/openvpn \
	                                              /srv/logs/ziproxy \
	  /srv/transmission \
	/opt/letsencrypt       /srv/letsencrypt       /srv/logs/letsencrypt \
	  /srv/owncloud/acme-challenge/.well-known/acme-challenge  /srv/prestashop/acme-challenge/.well-known/acme-challenge  /srv/joomla/acme-challenge/.well-known/acme-challenge  /srv/wordpress/acme-challenge/.well-known /srv/dokuwiki/acme-challenge/.well-known \
	/opt/droppy  /srv/droppy/.well-known/acme-challenge \
	/opt/portainer/certs  /srv/portainer/acme-challenge/.well-known  /srv/portainer/data \
	/opt/netdata

	sudo chown -R 8300:8300 /opt/consul /srv/consul
	sudo chmod g-rw,o-rwx /opt/http-proxy/tls
	#sudo chown root:ssl-cert /opt/http-proxy/tls
	sudo chown -R root: /opt/http-proxy/tls
	sudo chown -R 8080:8080 /opt/tomcat
	if [ ! -f /srv/joomla/configuration.php ]; then touch /srv/joomla/configuration.php; chown www-data: /srv/joomla/configuration.php; fi
	sudo chown -R www-data:www-data /opt/owncloud /srv/owncloud/data /srv/prestashop /srv/joomla /srv/wordpress /srv/dokuwiki /srv/tiddlywiki
	# if [ "$(ls -A /opt/dovecot/*.pem)" ]; then
	if ls -A /opt/dovecot/*.pem > /dev/null 2>&1; then sudo chmod 0400 /opt/dovecot/*.pem; fi
	# usd:gid 105:108 == dovecot
	sudo chown -R 105:108 /opt/dovecot
	sudo chown -R mail:mail /srv/dovecot
	#sudo chown -R opendkim:postfix /opt/email-relay
	sudo chown -R 106:108 /opt/email-relay
	sudo chown 105:107 /srv/transmission
	sudo chown 999:999 /opt/netdata
	sudo chown 105:107 /srv/redis*
	sudo chown -R nobody:nogroup /srv/droppy /opt/droppy

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
	else \
		sudo apt-get install docker-ce=$(DOCKER_APT_VERSION); \
	fi

.PHONY: install-docker-rpi
install-docker-rpi: ## deprecated; install Docker on a Raspberry Pi
	if [ ! -f /etc/apt/sources.list.d/Hypriot_Schatzkiste.list ]; then \
		sudo apt-get install apt-transport-https \
		sudo curl -fRL -o /etc/apt/sources.list.d/Hypriot_Schatzkiste.list "https://packagecloud.io/install/repositories/Hypriot/Schatzkiste/config_file.list?os=raspbian&dist=8&source=script" \
		curl -fsSL https://packagecloud.io/Hypriot/Schatzkiste/gpgkey | sudo apt-key add - \
		sudo usermod -aG docker `whoami`; \
	fi
#	echo "overlay" | sudo tee -a /etc/modules \
	sudo apt-get update && sudo apt-get install docker-hypriot=$(DOCKER_APT_VERSION)
	sudo systemctl enable docker

.PHONY: install-docker-compose
install-docker-compose: ## install docker-compose
	#pip install docker-compose
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

.PHONY: install-docker-machine
install-docker-machine: ## install docker-machine
	mkdir -p ~/.docker/machine
	[ -f ~/.docker/machine/no-error-report ] || touch ~/.docker/machine/no-error-report
	sudo curl -fsSLR -o /usr/local/bin/docker-machine https://github.com/docker/machine/releases/download/$(DOCKER_MACHINE_VERSION)/docker-machine-`uname -s`-`uname -m`
	sudo chmod +x /usr/local/bin/docker-machine
	sudo curl -fsSLR -o /etc/bash_completion.d/docker-machine-prompt https://github.com/docker/machine/raw/$(DOCKER_MACHINE_VERSION)/contrib/completion/bash/docker-machine-prompt.bash
	sudo curl -fsSLR -o /etc/bash_completion.d/docker-machine-wrapper https://github.com/docker/machine/raw/$(DOCKER_MACHINE_VERSION)/contrib/completion/bash/docker-machine-wrapper.bash
	sudo curl -fsSLR -o /etc/bash_completion.d/docker-machine https://github.com/docker/machine/raw/$(DOCKER_MACHINE_VERSION)/contrib/completion/bash/docker-machine.bash
	sudo touch -r /usr/local/bin/docker-machine /etc/bash_completion.d/docker-machine-prompt /etc/bash_completion.d/docker-machine-wrapper /etc/bash_completion.d/docker-machine
	# To enable the docker-machine shell prompt, add $(__docker_machine_ps1) to your PS1 setting in ~/.bashrc.
	# PS1='[\u@\h \W$(__docker_machine_ps1)]\$ '
	# PS1='[\u@\h \W$(__docker_machine_ps1 " [%s]")]\$ '

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
