unexport NAME = cedrik/baseimage
unexport VERSION = 0.9.18.1


########################################################################
# START set versions here
########################################################################

DOCKER_APT_VERSION = 1.10.*
# url fragment
DOCKER_COMPOSE_VERSION = 1.6.2
# url fragment
DOCKER_MACHINE_VERSION = v0.6.0

#COMPOSE_PROJECT_NAME = `basename`
#COMPOSE_FILE = docker-compose.yml

UBUNTU_VERSION  = 15.10

# Would have been much easier with Debian's redirector httpredir.debian.org...
#APT_MIRROR = mirrors.online.net
APT_MIRROR = cz.archive.ubuntu.com

MYSQL_VERSION   = 5.6

########################################################################
# END set versions here
########################################################################


docker_compose_build = http-proxy tomcat dovecot dnsmasq email-relay owncloud redis-owncloud memcached-owncloud mysql prestashop joomla openvpn letsencrypt
.PHONY: $(docker_compose_build)


.PHONY: all
all: build

# one of the other, really...
export
.EXPORT_ALL_VARIABLES:

.PHONY: pull
pull:
	docker pull ubuntu:$(UBUNTU_VERSION)

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

.PHONY: java
java: baseimage
	docker build -t cedrik/java --rm java


$(docker_compose_build): baseimage
	docker-compose build $@

tomcat: java
http-proxy: httpd-base
owncloud prestashop: php5-base
owncloud: memcached-owncloud redis-owncloud email-relay
prestashop: mysql
joomla: mysql email-relay

########################################################################

.PHONY: tag_latest
tag_latest:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

########################################################################

.PHONY: stats
stats:
	docker stats --no-stream $$(docker ps --format='{{.Names}}')

.PHONY: ip
ip:
	docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress }}' $@

########################################################################

.PHONY: new-certificates
new-certificates:
	# --dry-run --test-cert
	docker-compose run --rm letsencrypt certonly --non-interactive --dry-run \
		--webroot \
		-w /srv/http-proxy/polycarpe -d polycarpe.fr -d www.polycarpe.fr \
		-w /srv/owncloud/acme-challenge -d oc.cedrik.fr \
		-w /srv/prestashop/acme-challenge -d boutique.vingt-citadelles.fr -d boutique.piacercanto.org \
		-w /srv/joomla/acme-challenge -d beta.piacercanto.org \
		-w /opt/tomcat/instance-cedrik/webapps/cedrik.fr/ROOT -d www.cedrik.fr -d cedrik.fr -d wpad.cedrik.fr

.PHONY: renew-certificates
renew-certificates:
	# --dry-run --test-cert
	docker-compose run --rm letsencrypt renew --non-interactive --keep-until-expiring

########################################################################

.PHONY: clean
clean:
	# remove stopped containers
	# WARNING: be aware if you use data-only container, it will remove them also if you set "--volumes=true"
	docker ps --no-trunc -a -q -f "status=exited" | xargs --no-run-if-empty docker rm --volumes=false
	# remove untagged images
	docker images -f "dangling=true" -q | xargs --no-run-if-empty docker rmi
	docker network rm `docker network ls --filter type=custom --no-trunc -q`

.PHONY: distclean
distclean: clean
	# docker rmi "cedrik/*" "*_*"
	docker images --no-trunc -q "*_*" | xargs --no-run-if-empty docker rmi
	docker images --no-trunc -q "cedrik/*" | xargs --no-run-if-empty docker rmi

########################################################################

.PHONY: mkdirs
mkdirs:
	mkdir -p -m 0775 \
	/opt/http-proxy/conf-available /opt/http-proxy/conf-enabled /opt/http-proxy/conf-include /opt/http-proxy/mods-available /opt/http-proxy/mods-enabled /opt/http-proxy/sites-available /opt/http-proxy/sites-enabled /opt/http-proxy/tls \
	                       /srv/http-proxy        /srv/logs/http-proxy/apache2 \
	/opt/tomcat                                   /srv/logs/tomcat \
	/opt/owncloud/config /opt/owncloud/apps  /srv/owncloud/data     /srv/logs/owncloud/apache2 \
	/opt/prestashop                               /srv/logs/prestashop/apache2 \
	  /srv/prestashop/override /srv/prestashop/mails /srv/prestashop/img /srv/prestashop/modules /srv/prestashop/download /srv/prestashop/upload /srv/prestashop/config \
	/opt/mysql/docker-entrypoint-initdb.d         /srv/logs/mysql/mysql \
	  /srv/mysql/data /srv/mysql/backup \
	/opt/dnsmasq/dnsmasq.d                        /srv/logs/dnsmasq \
	/opt/dovecot           /srv/dovecot           /srv/logs/dovecot \
	/opt/email-relay/dkim/keys \
		/srv/joomla/administrator /srv/joomla/components /srv/joomla/images /srv/joomla/language \
		/srv/joomla/libraries /srv/joomla/media /srv/joomla/modules /srv/joomla/plugins \
		/srv/joomla/templates /srv/joomla/logs \
	                                              /srv/logs/joomla/apache2 \
	/opt/openvpn                                  /srv/logs/openvpn \
	/opt/letsencrypt       /srv/letsencrypt       /srv/logs/letsencrypt
	  /srv/owncloud/acme-challenge/.well-known/acme-challenge  /srv/prestashop/acme-challenge/.well-known/acme-challenge  /srv/joomla/acme-challenge/.well-known/acme-challenge

	sudo chmod g-rw,o-rwx /opt/http-proxy/tls
	#sudo chown root:ssl-cert /opt/http-proxy/tls
	sudo chown -R root: /opt/http-proxy/tls
	sudo chown -R 8080:8080 /opt/tomcat
	sudo chown -R www-data:www-data /opt/owncloud /srv/owncloud/data /srv/prestashop /srv/joomla
	if [ ! -f /srv/joomla/configuration.php ]; then touch /srv/joomla/configuration.php; chown www-data: /srv/joomla/configuration.php; fi
	# if [ "$(ls -A /opt/dovecot/*.pem)" ]; then
	if ls -A /opt/dovecot/*.pem > /dev/null 2>&1; then sudo chmod 0400 /opt/dovecot/*.pem; fi
	sudo chown -R mail:mail /srv/dovecot
	sudo chown root: /opt/email-relay

########################################################################

.PHONY: install-docker-compose
install-docker-compose:
	sudo curl -fsSLR -o /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/$(DOCKER_COMPOSE_VERSION)/docker-compose-`uname -s`-`uname -m`
	sudo chmod +x /usr/local/bin/docker-compose
	#sudo curl -fsSLR -o /etc/bash_completion.d/docker-compose https://raw.githubusercontent.com/docker/compose/$$(docker-compose version --short)/contrib/completion/bash/docker-compose
	sudo curl -fsSLR -o /etc/bash_completion.d/docker-compose https://raw.githubusercontent.com/docker/compose/$(DOCKER_COMPOSE_VERSION)/contrib/completion/bash/docker-compose
	sudo touch -r /usr/local/bin/docker-compose /etc/bash_completion.d/docker-compose

.PHONY: install-docker-machine
install-docker-machine:
	sudo curl -fsSLR -o /usr/local/bin/docker-machine https://github.com/docker/machine/releases/download/$(DOCKER_MACHINE_VERSION)/docker-machine-`uname -s`-`uname -m`
	sudo chmod +x /usr/local/bin/docker-machine
	sudo curl -fsSLR -o /etc/bash_completion.d/docker-machine-prompt https://github.com/docker/machine/raw/$(DOCKER_MACHINE_VERSION)/contrib/completion/bash/docker-machine-prompt.bash
	sudo curl -fsSLR -o /etc/bash_completion.d/docker-machine-wrapper https://github.com/docker/machine/raw/$(DOCKER_MACHINE_VERSION)/contrib/completion/bash/docker-machine-wrapper.bash
	sudo curl -fsSLR -o /etc/bash_completion.d/docker-machine https://github.com/docker/machine/raw/$(DOCKER_MACHINE_VERSION)/contrib/completion/bash/docker-machine.bash
	sudo touch -r /usr/local/bin/docker-machine /etc/bash_completion.d/docker-machine-prompt /etc/bash_completion.d/docker-machine-wrapper /etc/bash_completion.d/docker-machine
	# To enable the docker-machine shell prompt, add $(__docker_machine_ps1) to your PS1 setting in ~/.bashrc.
	# PS1='[\u@\h \W$(__docker_machine_ps1)]\$ '
	# PS1='[\u@\h \W$(__docker_machine_ps1 " [%s]")]\$ '

.PHONY: install-docker
install-docker:
	#curl -fsSL https://get.docker.com/gpg | sudo apt-key add -
	if [ ! -f /etc/apt/sources.list.d/docker.list ]; then \
		curl -sSL https://get.docker.com/ | sudo sh; \
		sudo usermod -aG docker `whoami`; \
	else \
		sudo apt-get install docker-engine=$(DOCKER_APT_VERSION); \
	fi

.PHONY: install
install: install-docker-compose install-docker mkdirs

.PHONY: uninstall
uninstall: distclean
	rm /usr/local/bin/docker-* /etc/bash_completion.d/docker-*
	apt-get purge -y docker-engine
	echo "Left over: config & data dirs: /opt /srv"
