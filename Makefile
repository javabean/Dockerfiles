unexport IMG_NAME = cedrik/baseimage
unexport IMG_VERSION = 0.9.19.1


########################################################################
# START set versions here
# see also docker-compose's .env
########################################################################

DOCKER_APT_VERSION = 1.12.*
# url fragment
DOCKER_COMPOSE_VERSION = 1.9.0
# url fragment
DOCKER_MACHINE_VERSION = v0.8.2

#COMPOSE_PROJECT_NAME = `basename`
#COMPOSE_FILE = docker-compose_1.yml:docker-compose_2.yml

UBUNTU_VERSION ?= 16.04

# Would have been much easier with Debian's redirector httpredir.debian.org...
#APT_MIRROR ?= mirrors.online.net
APT_MIRROR ?= cz.archive.ubuntu.com
# arm
#APT_MIRROR ?= ports.ubuntu.com/ubuntu-ports
#APT_MIRROR ?= ftp.tu-chemnitz.de/pub/linux/ubuntu-ports
#APT_MIRROR ?= mirror.unej.ac.id/ubuntu

MYSQL_VERSION = 5.6

########################################################################
# END set versions here
########################################################################


docker_compose_build = consul http-proxy tomcat dovecot dnsmasq unbound email-relay mysql owncloud redis-owncloud memcached-owncloud prestashop joomla wordpress dokuwiki tiddlywiki openvpn web-accelerator transmission netdata
.PHONY: $(docker_compose_build)


.PHONY: all
all: build

# one of the other, really...
export
.EXPORT_ALL_VARIABLES:

.PHONY: pull
pull:
	docker pull ubuntu:$(UBUNTU_VERSION)
	#docker pull quay.io/letsencrypt/letsencrypt

.PHONY: build
build: $(docker_compose_build)

.PHONY: baseimage
baseimage: pull
	docker build --build-arg APT_MIRROR=$(APT_MIRROR) -t cedrik/baseimage --rm baseimage/image

.PHONY: httpd-base
httpd-base: baseimage
	docker build -t cedrik/httpd-base --rm apache-base

.PHONY: php5-base
php5-base: httpd-base
	docker build --build-arg MYSQL_VERSION=$(MYSQL_VERSION) -t cedrik/php5-base --rm php5-base

.PHONY: php7-base
php7-base: httpd-base
	docker build --build-arg MYSQL_VERSION=$(MYSQL_VERSION) -t cedrik/php7-base --rm php7-base

.PHONY: java
java: baseimage
	docker build -t cedrik/java --rm java


$(docker_compose_build): baseimage
	docker-compose build $@

tomcat: java
http-proxy: httpd-base
prestashop: php5-base
owncloud joomla wordpress dokuwiki: php7-base
owncloud: memcached-owncloud redis-owncloud
owncloud joomla wordpress prestashop: mysql email-relay
dokuwiki: email-relay

########################################################################

.PHONY: tag_latest
tag_latest:
	docker tag $(IMG_NAME):$(IMG_VERSION) $(IMG_NAME):latest

########################################################################

.PHONY: stats
stats:
	docker stats --no-stream $$(docker ps --format='{{.Names}}')

.PHONY: ip
ip:
	@#docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress }}' $(filter-out $@,$(MAKECMDGOALS))
	docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress }}' $(NAME)

.PHONY: health
health:
	@# Print out the text of the last 5 checks
	docker inspect -f '{{ range .State.Health.Log }}{{ println "======\nStart:" .Start }}{{ .Output }}{{end}}' $(NAME)

#%:
#	@:

########################################################################

.PHONY: new-certificates
new-certificates:
	# --quiet --dry-run --test-cert
	docker-compose run --rm letsencrypt --authenticators certonly --non-interactive --dry-run \
		--webroot \
		-w /srv/http-proxy/polycarpe -d polycarpe.fr -d www.polycarpe.fr \
		-w /srv/owncloud/acme-challenge -d oc.cedrik.fr \
		-w /srv/prestashop/acme-challenge -d boutique.vingt-citadelles.fr -d boutique.piacercanto.org \
		-w /srv/joomla -d beta.piacercanto.org \
		-w /srv/dokuwiki/acme-challenge -d wiki.cedrik.fr \
		-w /opt/tomcat/instance-cedrik/webapps/cedrik.fr/ROOT -d www.cedrik.fr -d cedrik.fr -d wpad.cedrik.fr

.PHONY: renew-certificates
renew-certificates:
	# --quiet --dry-run --test-cert
	# --pre-hook "service nginx stop" --post-hook "docker restart http-proxy"
	docker-compose run --rm letsencrypt --authenticators renew --non-interactive --keep-until-expiring

########################################################################

.PHONY: clean
clean:
	# See also Docker 1.13 `docker system df [-v]` / `docker system prune -f` == `docker container prune -f && docker volume prune -f && docker image prune -f && docker network prune -f`
	# remove stopped containers
	# WARNING: be aware if you use data-only container, it will remove them also if you set "--volumes=true"
	docker ps --no-trunc -a -q -f "status=exited" | xargs --no-run-if-empty docker rm --volumes=false
	# remove all unused volumes
	#docker volume ls -q | xargs --no-run-if-empty docker volume rm
	# remove local volumes
	#docker volume ls | awk '/^local/ { print $2 }' | xargs --no-run-if-empty docker volume rm
	# remove untagged images
	docker images -f "dangling=true" -q | xargs --no-run-if-empty docker rmi
	# delete and untag every image that is not a container
	# a little more heinous since "<none>" is the repo/tag for dangling images
	# sort is not necessary but is nice if you add a -tn1 to xargs so you can see each rm line
	#docker images | awk 'NR>1 { if ($1 == "<none>") print $3; else print $1":"$2 }' | sort | xargs --no-run-if-empty docker rmi
	# remove unused networks
	docker network ls --filter type=custom --no-trunc -q | xargs --no-run-if-empty docker network rm

.PHONY: prune
prune: clean

.PHONY: distclean
distclean: clean
	# See also Docker 1.13 `docker image prune -a -f`
	# docker rmi "cedrik/*" "*_*"
	docker images --no-trunc -q "*_*" | xargs --no-run-if-empty docker rmi
	docker images --no-trunc -q "cedrik/*" | xargs --no-run-if-empty docker rmi

########################################################################

.PHONY: mkdirs
mkdirs:
	mkdir -p -m 0775 \
	/opt/consul/config     /srv/consul/data \
	/opt/http-proxy/conf-available /opt/http-proxy/conf-enabled /opt/http-proxy/conf-include /opt/http-proxy/mods-available /opt/http-proxy/mods-enabled /opt/http-proxy/sites-available /opt/http-proxy/sites-enabled /opt/http-proxy/tls \
	                       /srv/http-proxy        /srv/logs/http-proxy/apache2 \
	/opt/tomcat                                   /srv/logs/tomcat \
	/opt/owncloud/config /opt/owncloud/apps  /srv/owncloud/data     /srv/logs/owncloud/apache2 \
	/opt/prestashop                               /srv/logs/prestashop/apache2 \
	  /srv/prestashop/override /srv/prestashop/mails /srv/prestashop/img /srv/prestashop/modules /srv/prestashop/download /srv/prestashop/upload /srv/prestashop/config \
	/opt/mysql/docker-entrypoint-initdb.d         /srv/logs/mysql/mysql \
	  /srv/mysql/data /srv/mysql/backup \
	/opt/dnsmasq/dnsmasq.d                        /srv/logs/dnsmasq \
	/opt/unbound                                  /srv/logs/unbound \
	/opt/dovecot           /srv/dovecot           /srv/logs/dovecot \
	/opt/email-relay/dkim/keys \
		                   /srv/joomla            /srv/logs/joomla/apache2 \
      /srv/dokuwiki/conf  /srv/dokuwiki/lib/plugins  /srv/dokuwiki/data \
                                                  /srv/logs/dokuwiki/apache2 \
      /srv/tiddlywiki  \
      /srv/wordpress/wp-content  /srv/wordpress/wp-includes-languages \
                                                  /srv/logs/wordpress/apache2 \
	/opt/openvpn                                  /srv/logs/openvpn \
	                                              /srv/logs/ziproxy \
	/opt/letsencrypt       /srv/letsencrypt       /srv/logs/letsencrypt \
	  /srv/owncloud/acme-challenge/.well-known/acme-challenge  /srv/prestashop/acme-challenge/.well-known/acme-challenge  /srv/joomla/acme-challenge/.well-known/acme-challenge  /srv/wordpress/acme-challenge/.well-known /srv/dokuwiki/acme-challenge/.well-known \
	  /srv/transmission \
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
	sudo chown -R mail:mail /srv/dovecot
	sudo chown root: /opt/email-relay
	sudo chown 105:107 /srv/transmission
	sudo chown 999:999 /opt/netdata

########################################################################

.PHONY: install-docker
install-docker:
	#curl -fsSL https://get.docker.com/gpg | sudo apt-key add -
	if [ ! -f /etc/apt/sources.list.d/docker.list ]; then \
		curl -fsSL https://get.docker.com/ | sudo sh; \
		sudo usermod -aG docker `whoami`; \
	else \
		sudo apt-get install docker-engine=$(DOCKER_APT_VERSION); \
	fi

.PHONY: install-docker-rpi
install-docker-rpi:
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
install-docker-compose:
	sudo curl -fsSLR -o /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/$(DOCKER_COMPOSE_VERSION)/docker-compose-`uname -s`-`uname -m`
	sudo chmod +x /usr/local/bin/docker-compose
	#sudo curl -fsSLR -o /etc/bash_completion.d/docker-compose https://raw.githubusercontent.com/docker/compose/$$(docker-compose version --short)/contrib/completion/bash/docker-compose
	sudo curl -fsSLR -o /etc/bash_completion.d/docker-compose https://raw.githubusercontent.com/docker/compose/$(DOCKER_COMPOSE_VERSION)/contrib/completion/bash/docker-compose
	sudo touch -r /usr/local/bin/docker-compose /etc/bash_completion.d/docker-compose

.PHONY: install-docker-compose-rpi
install-docker-compose-rpi:
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
install-docker-machine:
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
install: install-docker-compose install-docker mkdirs

.PHONY: uninstall
uninstall: distclean
	rm /usr/local/bin/docker-* /etc/bash_completion.d/docker-*
	apt-get purge -y docker-engine docker-hypriot docker-compose docker-machine
	echo "Left over: config & data dirs: /opt /srv"
